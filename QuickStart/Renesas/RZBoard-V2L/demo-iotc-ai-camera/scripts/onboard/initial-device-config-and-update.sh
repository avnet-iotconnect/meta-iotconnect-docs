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

# Define source and target directories
CONFIG="local_data/config.json"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_DIR="/tmp/ota-payload"

APPLICATION_PAYLOAD_DIR="$SCRIPT_DIR/application"
LOCAL_DATA_PAYLOAD_DIR="$SCRIPT_DIR/local_data"
CERTS_PAYLOAD_DIR="$LOCAL_DATA_PAYLOAD_DIR/certs"

APPLICATION_INSTALLED_DIR="/usr/iotc/bin/iotc-python-sdk"
LOCAL_DATA_INSTALLED_DIR="/usr/iotc/local"
CERTS_INSTALLED_DIR="$LOCAL_DATA_INSTALLED_DIR/certs"

# Function to transfer and validate OTA payload
transfer_ota_payload() {
    echo "Transferring OTA payload to target device..."
    
    # Transfer only required directories, ensuring structure
    scp -r "$SCRIPT_DIR/application" "$TARGET_USER@$TARGET_IP:/tmp/ota-payload/"
    scp -r "$SCRIPT_DIR/local_data" "$TARGET_USER@$TARGET_IP:/tmp/ota-payload/"
    
    # Validate structure on the target
    ssh $TARGET_USER@$TARGET_IP "ls -R /tmp/ota-payload"
    
    # Check for certificate folder existence
    ssh $TARGET_USER@$TARGET_IP "mkdir -p /tmp/ota-payload/local_data/certs"
    ssh $TARGET_USER@$TARGET_IP "ls /tmp/ota-payload/local_data/certs"
    
    if [ $? -ne 0 ]; then
        echo "Error: Certificates folder or files missing on target."
        exit 1
    fi
}

prepare_certificates() {
    echo "Updating config.json and organizing certificates in the certs folder..."
    
    # Ensure the certs directory exists
    mkdir -p "$CERTS_PAYLOAD_DIR"
    
    # Extract certificates from the ZIP file
    if [ -f "$CERT_ZIP" ]; then
        echo "Extracting certificates from $CERT_ZIP..."
        unzip -o "$CERT_ZIP" -d "$CERTS_PAYLOAD_DIR"
        if [ $? -ne 0 ]; then
            echo "Error: Failed to extract certificates from $CERT_ZIP"
            exit 1
        fi
    else
        echo "Warning: $CERT_ZIP not found. Skipping extraction."
    fi

    # Move any loose .crt and .pem files in the script directory to the certs folder
    for cert in "$SCRIPT_DIR"/*.crt "$SCRIPT_DIR"/*.pem; do
        if [ -f "$cert" ]; then
            cp -v "$cert" "$CERTS_PAYLOAD_DIR/"
            echo "Moved $cert to $CERTS_PAYLOAD_DIR"
        fi
    done
    
    # Extract values from iotcDeviceConfig.json
    DUID=$(grep '"uid"' "$DEVICE_CONFIG" | awk -F'"' '{print $4}')
    CPID=$(grep '"cpid"' "$DEVICE_CONFIG" | awk -F'"' '{print $4}')
    ENV=$(grep '"env"' "$DEVICE_CONFIG" | awk -F'"' '{print $4}')
    DISCOVERY_URL=$(grep '"disc"' "$DEVICE_CONFIG" | awk -F'"' '{print $4}')


    # Update config.json
    sed -i "s/\"duid\": \".*\"/\"duid\": \"$DUID\"/" "$CONFIG"
    sed -i "s/\"cpid\": \".*\"/\"cpid\": \"$CPID\"/" "$CONFIG"
    sed -i "s/\"env\": \".*\"/\"env\": \"$ENV\"/" "$CONFIG"
    sed -i "s|\"discovery_url\": \".*\"|\"discovery_url\": \"$DISCOVERY_URL\"|" "$CONFIG"
    sed -i "s|\"sdk_ver\": \".*\"|\"sdk_ver\": \"2.1\"|" "$CONFIG"
    sed -i "s|\"connection_type\": \".*\"|\"connection_type\": \"IOTC_CT_AWS\"|" "$CONFIG"
    sed -i "s|\"iotc_server_cert\": \".*\"|\"iotc_server_cert\": \"/etc/ssl/certs/Amazon_Root_CA_1.pem\"|" "$CONFIG"
    sed -i "s|\"sdk_id\": \".*\"|\"sdk_id\": \"<SDK_ID_PLACEHOLDER>\"|" "$CONFIG"  # Replace placeholder if needed     
    

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

    # Update the config.json paths for the certificates
    sed -i "s|\"client_key\": \".*\"|\"client_key\": \"/usr/iotc/local/certs/$CERT_KEY\"|" "$CONFIG"
    sed -i "s|\"client_cert\": \".*\"|\"client_cert\": \"/usr/iotc/local/certs/$CERT_FILE\"|" "$CONFIG"

    echo "Configuration and certificates updated successfully."

    echo "Updated config.json contents:"
    cat "$CONFIG"

    # Ensure proper permissions locally
    chmod -R u+rwx,g+rwx,o+rwx ./
}

# Function to update a directory
update_directory() {
    local payload_dir="$1"
    local target_dir="$2"

    ssh $TARGET_USER@$TARGET_IP "[ -d $payload_dir ]"
    if [ $? -eq 0 ]; then
        ssh $TARGET_USER@$TARGET_IP "mkdir -p $target_dir"
        ssh $TARGET_USER@$TARGET_IP "cp -va $payload_dir/* $target_dir/"
        echo "Updated $target_dir with files from $payload_dir"
    else
        echo "Warning: Payload directory $payload_dir not found on target, skipping update."
    fi
}

# Organize certificates before transfer
prepare_certificates

# Transfer the payload to the target
transfer_ota_payload

# Update application files
update_directory "$TARGET_DIR/application" "$APPLICATION_INSTALLED_DIR"

# Update certificates
update_directory "$TARGET_DIR/local_data/certs" "$CERTS_INSTALLED_DIR"

# Update local data
update_directory "$TARGET_DIR/local_data" "$LOCAL_DATA_INSTALLED_DIR"

# Final success message
echo "All OTA payload files processed successfully."

# Ensure proper permissions on the target
ssh $TARGET_USER@$TARGET_IP "chmod -R u+rw,g+rw,o+rw /usr/iotc/local/"
ssh $TARGET_USER@$TARGET_IP "chmod -R u+rwx,g+rwx,o+rwx /usr/iotc/local/scripts"

# Install dependencies on the target
ssh $TARGET_USER@$TARGET_IP "python3 -m pip install requests psutil"

# Call the function to set up the IoTConnect systemd service
setup_iotconnect_service

echo "IoTConnect service has been set up and started on the target device."

# Note for systemd management
cat <<EOF

================================================================================
Systemd Management Commands for iotconnect.service:

Start the service:
    systemctl start iotconnect.service

Stop the service:
    systemctl stop iotconnect.service

Check the status of the service:
    systemctl status iotconnect.service

View the logs for the service:
    journalctl -u iotconnect.service

Reload systemd and restart the service after changes:
    systemctl daemon-reload
    systemctl restart iotconnect.service
================================================================================

EOF


# Prompt to open an SSH session
read -p "Do you want to open an SSH session to $TARGET_IP now? (yes/no): " OPEN_SSH
if [[ "$OPEN_SSH" =~ ^[Yy][Ee][Ss]$ || "$OPEN_SSH" =~ ^[Yy]$ ]]; then
    echo "Starting SSH session to $TARGET_IP..."
    ssh $TARGET_USER@$TARGET_IP
else
    echo "SSH session skipped. You can connect later using:"
    echo "    ssh $TARGET_USER@$TARGET_IP"
fi
