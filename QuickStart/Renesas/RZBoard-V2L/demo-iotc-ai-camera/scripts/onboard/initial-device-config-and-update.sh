#!/bin/bash

# Function to check if SSH is running on the RZBoard and start it if necessary
check_ssh_service() {
    echo "Checking if SSH is running on the target device..."
    ssh $TARGET_USER@$TARGET_IP "ps aux | grep sshd" &>/dev/null

    if [ $? -ne 0 ]; then
        echo "SSH is not running. Starting SSH service..."
        ssh $TARGET_USER@$TARGET_IP "sudo systemctl start sshd"
    else
        echo "SSH is already running on the target device."
    fi
}

# Function to generate SSH keys if they don't exist
generate_ssh_keys() {
    echo "Checking if SSH keys exist..."
    if [ ! -f "$HOME/.ssh/id_rsa" ]; then
        echo "No SSH keys found. Generating SSH key pair..."
        ssh-keygen -t rsa -b 4096 -f "$HOME/.ssh/id_rsa" -N ""
        echo "SSH key pair generated."
    else
        echo "SSH key pair already exists."
    fi
}

# Function to copy SSH key to the target device
copy_ssh_key_to_target() {
    echo "Copying SSH public key to the target device..."

    # Ensure .ssh directory exists and set permissions
    ssh $TARGET_USER@$TARGET_IP "mkdir -p ~/.ssh && chmod 700 ~/.ssh"
    
    # Copy public key using SCP
    scp ~/.ssh/id_rsa.pub $TARGET_USER@$TARGET_IP:~/.ssh/authorized_keys

    if [ $? -eq 0 ]; then
        echo "SSH public key copied successfully."
        ssh $TARGET_USER@$TARGET_IP "chmod 600 ~/.ssh/authorized_keys"
        echo "Permissions set on authorized_keys file."
    else
        echo "Failed to copy SSH key. Ensure that the device is accessible."
        exit 1
    fi
}

# Function to ensure the correct permissions on the /tmp/ota-payload/local_data/data directory
set_permissions() {
    echo "Ensuring correct permissions for /tmp/ota-payload/local_data/data..."
    ssh $TARGET_USER@$TARGET_IP "chmod -R u+rw,g+rw,o+rw /tmp/ota-payload/local_data/data/*"
    if [ $? -eq 0 ]; then
        echo "Permissions set correctly on /tmp/ota-payload/local_data/data/*."
    else
        echo "Failed to set permissions. Exiting."
        exit 1
    fi
}

# Main script execution
echo "Starting SSH key setup and connection..."

# Function to clean up old host keys
cleanup_ssh_keys() {
    echo "Cleaning up old SSH host keys for the target device..."
    ssh-keygen -R "$TARGET_IP" > /dev/null 2>&1
    echo "Old SSH host keys removed for $TARGET_IP."
}

# Prompt the user for the target IP address
read -p "Enter the target IP address: " TARGET_IP
cleanup_ssh_keys
read -p "Enter the username for the target device (default: root): " TARGET_USER
TARGET_USER=${TARGET_USER:-root}

# Check SSH service status on the target device and start it if necessary
check_ssh_service

# Ensure SSH keys exist, otherwise generate them
generate_ssh_keys

# Copy SSH public key to the target device
copy_ssh_key_to_target

echo "SSH setup completed successfully. You can now SSH into the target device without a password."

# Prompt for paths and convert them to Unix format if necessary
read -p "Enter the full path and filename for iotcDeviceConfig.json [default: ./iotcDeviceConfig.json]: " DEVICE_CONFIG
DEVICE_CONFIG=${DEVICE_CONFIG:-iotcDeviceConfig.json}
DEVICE_CONFIG=$(cygpath -u "$DEVICE_CONFIG" 2>/dev/null || echo "$DEVICE_CONFIG")

read -p "Enter the full path and filename for the certificates zip file [default: ./RZBoardV2L-certificates.zip]: " CERT_ZIP
CERT_ZIP=${CERT_ZIP:-RZBoardV2L-certificates.zip}
CERT_ZIP=$(cygpath -u "$CERT_ZIP" 2>/dev/null || echo "$CERT_ZIP")

# Define constants
TARGET_DIR="/tmp/ota-payload"  # Temporary directory on the target

# Paths to local files and directories
CONFIG="local_data/config.json"
CERTS_DIR="local_data/certs"

# Extract values from iotcDeviceConfig.json
DUID=$(grep '"uid"' "$DEVICE_CONFIG" | awk -F'"' '{print $4}')
CPID=$(grep '"cpid"' "$DEVICE_CONFIG" | awk -F'"' '{print $4}')
ENV=$(grep '"env"' "$DEVICE_CONFIG" | awk -F'"' '{print $4}')
DISCOVERY_URL=$(grep '"disc"' "$DEVICE_CONFIG" | awk -F'"' '{print $4}')
# Concatenate DUID and CPID with a hyphen and store in unique_id variable
dunique_id="${DUID}-${CPID}"

# Update config.json with the extracted values and default values for sdk_ver and connection_type
sed -i "s/\"duid\": \".*\"/\"duid\": \"$DUID\"/" "$CONFIG"
sed -i "s/\"cpid\": \".*\"/\"cpid\": \"$CPID\"/" "$CONFIG"
sed -i "s/\"env\": \".*\"/\"env\": \"$ENV\"/" "$CONFIG"
sed -i "s|\"discovery_url\": \".*\"|\"discovery_url\": \"$DISCOVERY_URL\"|" "$CONFIG"
sed -i "s|\"sdk_ver\": \".*\"|\"sdk_ver\": \"2.1\"|" "$CONFIG"
sed -i "s|\"connection_type\": \".*\"|\"connection_type\": \"IOTC_CT_AWS\"|" "$CONFIG"
sed -i "s|\"iotc_server_cert\": \".*\"|\"iotc_server_cert\": \"/etc/ssl/certs/Amazon_Root_CA_1.pem\"|" "$CONFIG"
sed -i "s|\"sdk_id\": \".*\"|\"sdk_id\": \"<SDK_ID_PLACEHOLDER>\"|" "$CONFIG"  # Replace placeholder if needed

# Add device configuration with telemetry attributes to config.json
jq '. + {
  "device": {
    "commands_list_path": "/usr/iotc/local/scripts",
    "attributes": [
      { "name": "unique_id", "private_data": "/usr/iotc/local/data/unique_id", "private_data_type": "ascii" },
      { "name": "version", "private_data": "/usr/iotc/local/data/version", "private_data_type": "ascii" },
      { "name": "cpu_usage", "private_data": "/usr/iotc/local/data/cpu_usage", "private_data_type": "decimal" },
      { "name": "mem_usage", "private_data": "/usr/iotc/local/data/mem_usage", "private_data_type": "decimal" },
      { "name": "running_model", "private_data": "/usr/iotc/local/data/running_model", "private_data_type": "ascii" },
      { "name": "script_version", "private_data": "/usr/iotc/local/data/script_version", "private_data_type": "ascii" }
    ]
  }
}' "$CONFIG" > "$CONFIG.tmp" && mv "$CONFIG.tmp" "$CONFIG"

# Verify that the certificate zip file exists
if [ ! -f "$CERT_ZIP" ]; then
  echo "Error: Certificate zip file '$CERT_ZIP' not found."
  exit 1
fi

# Dynamically find certificate files within the ZIP archive
CERT_KEY=$(unzip -l "$CERT_ZIP" | grep -o "pk_.*.pem" | head -1)
CERT_FILE=$(unzip -l "$CERT_ZIP" | grep -o "cert_.*.crt" | head -1)

if [ -z "$CERT_KEY" ] || [ -z "$CERT_FILE" ]; then
  echo "Error: Certificate files not found in '$CERT_ZIP'."
  exit 1
fi

# Extract the certificate files to the certs directory
unzip -j "$CERT_ZIP" "$CERT_KEY" "$CERT_FILE" -d "$CERTS_DIR"
if [ $? -ne 0 ]; then
  echo "Error: Failed to extract certificates from '$CERT_ZIP'."
  exit 1
fi

# Update the config.json paths for the certificates
sed -i "s|\"client_key\": \".*\"|\"client_key\": \"/usr/iotc/local/certs/$CERT_KEY\"|" "$CONFIG"
sed -i "s|\"client_cert\": \".*\"|\"client_cert\": \"/usr/iotc/local/certs/$CERT_FILE\"|" "$CONFIG"

echo "Configuration and certificates updated successfully."

# Create the target directory on the remote device
echo "Creating directory on target device..."
ssh $TARGET_USER@$TARGET_IP "mkdir -p ${TARGET_DIR}"

# Transfer the files to the target device
echo "Transferring files to ${TARGET_USER}@${TARGET_IP}:${TARGET_DIR}..."
scp -r application local_data x-linux-ai install.sh ${TARGET_USER}@${TARGET_IP}:${TARGET_DIR}/

# Set executable permissions for the install script on the target device
echo "Setting executable permissions for install.sh on target device..."
ssh $TARGET_USER@$TARGET_IP "chmod +x ${TARGET_DIR}/install.sh"

# Set permissions for the /tmp/ota-payload/local_data/data/ directory
set_permissions

# Run the installation script on the target
echo "Running installation script on the target..."
ssh $TARGET_USER@$TARGET_IP "/bin/sh ${TARGET_DIR}/install.sh"

echo "OTA update completed successfully."

# Set read and write permissions for all files in /usr/iotc/local/data
ssh $TARGET_USER@$TARGET_IP "chmod -R u+rw,g+rw,o+rw /usr/iotc/local/data/*"
echo "Read and write permissions set on /usr/iotc/local/data/*"

# Make all scripts in /usr/iotc/local/scripts executable
ssh $TARGET_USER@$TARGET_IP "find /usr/iotc/local/scripts -type f -exec chmod +x {} \;"
echo "Executable permissions set on all files within /usr/iotc/local/scripts and its subdirectories"

# Install the requests library for 'root' user
echo "Installing 'requests' package for 'root' user..."
ssh $TARGET_USER@$TARGET_IP "python3 -m pip install requests"

echo "'requests' package installed for 'root' user."

# Set up IoTConnect to run at startup on target device
echo "Setting up IoTConnect to run at startup on target device..."
ssh $TARGET_USER@$TARGET_IP "echo \"[Unit]
Description=IoTConnect Service
After=network.target

[Service]
ExecStart=/home/root/iotc-application.sh
WorkingDirectory=/home/root
StandardOutput=journal
StandardError=journal
Restart=on-failure
RestartSec=5
User=root

[Install]
WantedBy=multi-user.target\" > /etc/systemd/system/iotconnect.service"

# Enable and start the IoTConnect service on the target device
ssh $TARGET_USER@$TARGET_IP "systemctl daemon-reload && systemctl enable iotconnect.service && systemctl start iotconnect.service"

echo "IoTConnect service has been set up and started on the target device."
