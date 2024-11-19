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
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_DIR="/tmp/ota-payload"

APPLICATION_PAYLOAD_DIR="$SCRIPT_DIR/application"
LOCAL_DATA_PAYLOAD_DIR="$SCRIPT_DIR/local_data"
CERTS_PAYLOAD_DIR="$LOCAL_DATA_PAYLOAD_DIR/certs"

APPLICATION_INSTALLED_DIR="/usr/iotc/bin/iotc-python-sdk"
LOCAL_DATA_INSTALLED_DIR="/usr/iotc/local"
CERTS_INSTALLED_DIR="$LOCAL_DATA_INSTALLED_DIR/certs"

# Ensure certs directory exists
mkdir -p "$CERTS_PAYLOAD_DIR"

# Move .crt and .pem files to the certs directory
for cert in "$SCRIPT_DIR"/*.crt "$SCRIPT_DIR"/*.pem; do
    if [ -f "$cert" ]; then
        cp -v "$cert" "$CERTS_PAYLOAD_DIR/"
        echo "Moved $cert to $CERTS_PAYLOAD_DIR"
    fi
done

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

# Move certificates locally before transfer
prepare_certificates() {
    echo "Organizing certificates in the certs folder..."
    mkdir -p "$CERTS_PAYLOAD_DIR"
    for cert in "$SCRIPT_DIR"/*.crt "$SCRIPT_DIR"/*.pem; do
        if [ -f "$cert" ]; then
            cp -v "$cert" "$CERTS_PAYLOAD_DIR/"
            echo "Moved $cert to $CERTS_PAYLOAD_DIR"
        fi
    done
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
