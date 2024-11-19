#!/bin/bash

# Function to check if SSH is running on the target device
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

setup_iotconnect_service() {
    echo "Setting up IoTConnect as a systemd service on the target device..."
    
    SERVICE_CONFIG="[Unit]
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
PermissionsStartOnly=true
PrivateDevices=no
ProtectSystem=off
ProtectHome=no
CapabilityBoundingSet=CAP_SYS_ADMIN CAP_DAC_OVERRIDE CAP_SYS_RAWIO

[Install]
WantedBy=multi-user.target"

    # Create the service configuration on the target device
    ssh $TARGET_USER@$TARGET_IP "echo \"$SERVICE_CONFIG\" > /etc/systemd/system/iotconnect.service"
    
    # Reload systemd, enable, and start the service
    ssh $TARGET_USER@$TARGET_IP "systemctl daemon-reload && systemctl enable iotconnect.service && systemctl start iotconnect.service"
    
    # Check the status of the service
    ssh $TARGET_USER@$TARGET_IP "systemctl status iotconnect.service --no-pager"
    
    echo "IoTConnect service has been set up and started with root-level permissions."
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

# Function to clean up old SSH host keys
cleanup_ssh_keys() {
    echo "Cleaning up old SSH host keys for the target device..."
    ssh-keygen -R "$TARGET_IP" > /dev/null 2>&1
    echo "Old SSH host keys removed for $TARGET_IP."
}

# Prompt the user for the target IP address and username
read -p "Enter the target IP address: " TARGET_IP
read -p "Enter the username for the target device (default: root): " TARGET_USER
TARGET_USER=${TARGET_USER:-root}

cleanup_ssh_keys
check_ssh_service
generate_ssh_keys
copy_ssh_key_to_target

# Prompt for paths and convert them to Unix format if necessary
read -p "Enter the full path and filename for iotcDeviceConfig.json [default: ./iotcDeviceConfig.json]: " DEVICE_CONFIG
DEVICE_CONFIG=${DEVICE_CONFIG:-iotcDeviceConfig.json}
DEVICE_CONFIG=$(cygpath -u "$DEVICE_CONFIG" 2>/dev/null || echo "$DEVICE_CONFIG")

read -p "Enter the full path and filename for the certificates zip file [default: ./RZBoardV2L-certificates.zip]: " CERT_ZIP
CERT_ZIP=${CERT_ZIP:-RZBoardV2L-certificates.zip}
CERT_ZIP=$(cygpath -u "$CERT_ZIP" 2>/dev/null || echo "$CERT_ZIP")

# Define constants
CONFIG="local_data/config.json"
TARGET_DIR="/tmp/ota-payload"

# Extract values from iotcDeviceConfig.json
DUID=$(grep '"uid"' "$DEVICE_CONFIG" | awk -F'"' '{print $4}')
CPID=$(grep '"cpid"' "$DEVICE_CONFIG" | awk -F'"' '{print $4}')
ENV=$(grep '"env"' "$DEVICE_CONFIG" | awk -F'"' '{print $4}')
DISCOVERY_URL=$(grep '"disc"' "$DEVICE_CONFIG" | awk -F'"' '{print $4}')
UNIQUE_ID="${DUID}-${CPID}"

# Update config.json
sed -i "s/\"duid\": \".*\"/\"duid\": \"$DUID\"/" "$CONFIG"
sed -i "s/\"cpid\": \".*\"/\"cpid\": \"$CPID\"/" "$CONFIG"
sed -i "s/\"env\": \".*\"/\"env\": \"$ENV\"/" "$CONFIG"
sed -i "s|\"discovery_url\": \".*\"|\"discovery_url\": \"$DISCOVERY_URL\"|" "$CONFIG"

# Add extended attributes to config.json
jq '.device.attributes += [
      { "name": "cpu_usage", "private_data": "/usr/iotc/local/data/cpu_usage", "private_data_type": "ascii" },
      { "name": "mem_usage", "private_data": "/usr/iotc/local/data/mem_usage", "private_data_type": "ascii" },
      { "name": "running_model", "private_data": "/usr/iotc/local/data/running_model", "private_data_type": "ascii" },
      { "name": "script_version", "private_data": "/usr/iotc/local/data/script_version", "private_data_type": "ascii" }
    ]' "$CONFIG" > "$CONFIG.tmp" && mv "$CONFIG.tmp" "$CONFIG"

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


echo "Updated config.json contents:"
cat "$CONFIG"

# Ensure proper permissions locally
chmod -R u+rwx,g+rwx,o+rwx ./

check_and_install_psutil() {
    # Check if psutil is already installed
    python3 -c "import psutil" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "psutil is already installed."
    else
        echo "psutil is not installed. Installing now..."
        pip3 install psutil
        if [ $? -eq 0 ]; then
            echo "psutil installed successfully."
        else
            echo "Failed to install psutil. Exiting."
            exit 1
        fi
    fi
}

# Run the function to ensure psutil is installed
check_and_install_psutil


# Transfer files to the target device
scp -r ./ $TARGET_USER@$TARGET_IP:$TARGET_DIR
scp "$CONFIG" $TARGET_USER@$TARGET_IP:/usr/iotc/local/config.json

# Write the unique ID to the target device
ssh $TARGET_USER@$TARGET_IP "echo -n '$UNIQUE_ID' > /usr/iotc/local/data/unique_id"

# Ensure permissions on the target
ssh $TARGET_USER@$TARGET_IP "chmod -R u+rw,g+rw,o+rw /usr/iotc/local/data"
ssh $TARGET_USER@$TARGET_IP "chmod -R u+rwx,g+rwx,o+rwx /usr/iotc/local/scripts"

# Install dependencies
ssh $TARGET_USER@$TARGET_IP "python3 -m pip install requests"

# Call the function to set up the systemd service
setup_iotconnect_service

echo "IoTConnect service has been set up and started on the target device."
