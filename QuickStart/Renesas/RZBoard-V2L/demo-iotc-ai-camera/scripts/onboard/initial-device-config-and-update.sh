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

# Function to transfer and validate OTA payload
transfer_ota_payload() {
    echo "Transferring OTA payload to target device..."
    
    # Ensure the payload directory exists on the target
    ssh $TARGET_USER@$TARGET_IP "mkdir -p /tmp/ota-payload"

    # Transfer directories with validation
    if [ -d "$SCRIPT_DIR/application" ]; then
        scp -r "$SCRIPT_DIR/application" $TARGET_USER@$TARGET_IP:/tmp/ota-payload/
    else
        echo "Warning: Local application directory not found, skipping."
    fi

    if [ -d "$SCRIPT_DIR/local_data" ]; then
        scp -r "$SCRIPT_DIR/local_data" $TARGET_USER@$TARGET_IP:/tmp/ota-payload/
    else
        echo "Warning: Local local_data directory not found, skipping."
    fi

    # Validate transfer on target
    ssh $TARGET_USER@$TARGET_IP "ls -R /tmp/ota-payload || echo 'Payload transfer validation failed.'"
}

# Function to setup IoTConnect Credentials - certs and config.json
prepare_iotc_creds() {
    echo "Updating config.json and organizing certificates in the certs folder..."
    
    # Ensure the certs directory exists
    CERTS_PAYLOAD_DIR="$SCRIPT_DIR/local_data/certs"
    echo "CERTS_PAYLOAD_DIR: $CERTS_PAYLOAD_DIR"
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
        echo "Error: $CERT_ZIP not found. Exiting."
        exit 1
    fi

    # Dynamically determine the certificate and key filenames
    CERT_FILE=$(find "$CERTS_PAYLOAD_DIR" -type f -name "*.crt" | head -n 1 | xargs -n1 basename)
    CERT_KEY=$(find "$CERTS_PAYLOAD_DIR" -type f -name "*.pem" | head -n 1 | xargs -n1 basename)

    if [ -z "$CERT_FILE" ] || [ -z "$CERT_KEY" ]; then
        echo "Error: Could not find .crt or .pem files in the extracted certs."
        exit 1
    fi

    echo "Detected certificate file: $CERT_FILE"
    echo "Detected key file: $CERT_KEY"
    
    # Update the config.json paths for the certificates
    echo "Updating config.json paths for certificates..."
    sed -i "s|\"client_key\": \".*\"|\"client_key\": \"/usr/iotc/local/certs/$CERT_KEY\"|" "$CONFIG"
    sed -i "s|\"client_cert\": \".*\"|\"client_cert\": \"/usr/iotc/local/certs/$CERT_FILE\"|" "$CONFIG"

    echo "Configuration and certificates updated successfully."

    # Extract values from iotcDeviceConfig.json
    DUID=$(grep '"uid"' "$DEVICE_CONFIG" | awk -F'"' '{print $4}')
    CPID=$(grep '"cpid"' "$DEVICE_CONFIG" | awk -F'"' '{print $4}')
    ENV=$(grep '"env"' "$DEVICE_CONFIG" | awk -F'"' '{print $4}')
    DISCOVERY_URL=$(grep '"disc"' "$DEVICE_CONFIG" | awk -F'"' '{print $4}')

    # Update additional fields in config.json
    sed -i "s/\"duid\": \".*\"/\"duid\": \"$DUID\"/" "$CONFIG"
    sed -i "s/\"cpid\": \".*\"/\"cpid\": \"$CPID\"/" "$CONFIG"
    sed -i "s/\"env\": \".*\"/\"env\": \"$ENV\"/" "$CONFIG"
    sed -i "s|\"discovery_url\": \".*\"|\"discovery_url\": \"$DISCOVERY_URL\"|" "$CONFIG"
    sed -i "s|\"sdk_ver\": \".*\"|\"sdk_ver\": \"2.1\"|" "$CONFIG"
    sed -i "s|\"connection_type\": \".*\"|\"connection_type\": \"IOTC_CT_AWS\"|" "$CONFIG"
    sed -i "s|\"iotc_server_cert\": \".*\"|\"iotc_server_cert\": \"/etc/ssl/certs/Amazon_Root_CA_1.pem\"|" "$CONFIG"
    sed -i "s|\"sdk_id\": \".*\"|\"sdk_id\": \"<SDK_ID_PLACEHOLDER>\"|" "$CONFIG"

    # Add extended attributes to config.json
    jq '.device.attributes += [
          { "name": "cpu_usage", "private_data": "/usr/iotc/local/data/cpu_usage", "private_data_type": "ascii" },
          { "name": "mem_usage", "private_data": "/usr/iotc/local/data/mem_usage", "private_data_type": "ascii" },
          { "name": "running_model", "private_data": "/usr/iotc/local/data/running_model", "private_data_type": "ascii" },
          { "name": "script_version", "private_data": "/usr/iotc/local/data/script_version", "private_data_type": "ascii" }
        ]' "$CONFIG" > "$CONFIG.tmp" && mv "$CONFIG.tmp" "$CONFIG"

    echo "Updated config.json contents:"
    cat "$CONFIG"

    # Ensure proper permissions locally
    chmod -R u+rwx,g+rwx,o+rwx ./
}

# Function to validate target's state
validate_target_state() {
    echo "Validating target directories on $TARGET_IP..."
    ssh $TARGET_USER@$TARGET_IP "ls -R /usr/iotc/bin/iotc-python-sdk/"
    ssh $TARGET_USER@$TARGET_IP "ls -R /usr/iotc/local/"
}

# Function to setup Wi-Fi
setup_wifi() {
    echo "Would you like to set up Wi-Fi on the target device? (yes/no)"
    read -r WIFI_SETUP_CHOICE

    if [[ "$WIFI_SETUP_CHOICE" =~ ^(yes|y)$ ]]; then
        echo "Starting Wi-Fi setup..."
        # Bring up the Wi-Fi interface
        ssh $TARGET_USER@$TARGET_IP "ifconfig mlan0 up"

        # Scan for available networks
        echo "Scanning for available Wi-Fi networks..."
        ssh $TARGET_USER@$TARGET_IP "iwlist mlan0 scan | grep SSID"

        # Prompt for SSID and password
        read -p "Enter the Wi-Fi SSID to connect to: " SSID
        read -sp "Enter the Wi-Fi password: " SSID_PASSWD
        echo

        # Add SSID and password to wpa_supplicant.conf
        echo "Configuring Wi-Fi credentials on the target device..."
        ssh $TARGET_USER@$TARGET_IP "wpa_passphrase \"$SSID\" \"$SSID_PASSWD\" >> /etc/wpa_supplicant.conf"

        # Start the Wi-Fi connection
        echo "Starting Wi-Fi connection..."
        ssh $TARGET_USER@$TARGET_IP "wpa_supplicant -B -i mlan0 -c /etc/wpa_supplicant.conf"
        ssh $TARGET_USER@$TARGET_IP "udhcpc -i mlan0 -n -R"

        echo "Ensuring Wi-Fi persists across reboots..."
        ssh $TARGET_USER@$TARGET_IP "systemctl enable wpa_supplicant"
        ssh $TARGET_USER@$TARGET_IP "echo -e 'auto mlan0\niface mlan0 inet dhcp\n    wpa-conf /etc/wpa_supplicant.conf' >> /etc/network/interfaces"

        echo "Wi-Fi setup completed. Checking connection status..."
        ssh $TARGET_USER@$TARGET_IP "ifconfig mlan0"

        echo "Wi-Fi setup complete. If there are any issues, verify the SSID and password."
        ssh $TARGET_USER@$TARGET_IP "chmod +x /usr//change_wifi.sh"

        # Final success message
        echo "All setup steps completed successfully!"
    else
        echo "Wi-Fi setup skipped."
    fi
}

# Function to update directories on the target
update_directory() {
    local target_dir="$1"
    local payload_dir="$2"

    # Ensure the target directory exists
    ssh $TARGET_USER@$TARGET_IP "mkdir -p $target_dir"

    # Transfer files if the payload directory exists
    if [ -d "$payload_dir" ]; then
        echo "Updating $target_dir with files from $payload_dir..."
        scp -r "$payload_dir/"* $TARGET_USER@$TARGET_IP:"$target_dir/" || {
            echo "Error: Failed to update $target_dir"
            exit 1
        }
        echo "Update complete."
    else
        echo "Warning: Payload directory $payload_dir not found locally, skipping update."
    fi
}

# Transfer the payload to the target (if required for initial setup)
transfer_ota_payload() {
    echo "Transferring OTA payload to target device..."
    
    # Ensure the payload directory exists on the target
    ssh $TARGET_USER@$TARGET_IP "mkdir -p /tmp/ota-payload"

    # Transfer directories with validation
    if [ -d "$SCRIPT_DIR/application" ]; then
        scp -r "$SCRIPT_DIR/application" $TARGET_USER@$TARGET_IP:/tmp/ota-payload/
    else
        echo "Warning: Local application directory not found, skipping."
    fi

    if [ -d "$SCRIPT_DIR/local_data" ]; then
        scp -r "$SCRIPT_DIR/local_data" $TARGET_USER@$TARGET_IP:/tmp/ota-payload/
    else
        echo "Warning: Local local_data directory not found, skipping."
    fi

    # Validate transfer and ensure critical subdirectories exist
    ssh $TARGET_USER@$TARGET_IP "mkdir -p /tmp/ota-payload/local_data/certs && ls -R /tmp/ota-payload" || {
        echo "Error: Payload transfer or validation failed."
        exit 1
    }
}

# Function to copy and execute a script on the target device
copy_and_execute_script() {
    local target_path="$1"
    local script_path="$2"
    
    echo "Copying $script_path to $TARGET_USER@$TARGET_IP:$target_path..."
    
    # Copy the script to the target
    scp "$script_path" "$TARGET_USER@$TARGET_IP:$target_path"
    
    if [ $? -eq 0 ]; then
        echo "Script $script_path copied successfully."
        
        # Make the script executable on the target
        ssh "$TARGET_USER@$TARGET_IP" "chmod +x $target_path/install.sh"
        
        # Execute the script on the target
        echo "Executing the script on the target..."
        ssh "$TARGET_USER@$TARGET_IP" "$target_path/install.sh"
    else
        echo "Error: Failed to copy $script_path to the target."
        exit 1
    fi
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

APPLICATION_INSTALLED_DIR="/usr/iotc/bin/iotc-python-sdk"
LOCAL_DATA_INSTALLED_DIR="/usr/iotc/local"
CERTS_INSTALLED_DIR="$LOCAL_DATA_INSTALLED_DIR/certs"
CERTS_PAYLOAD_DIR="$SCRIPT_DIR/local_data/certs"

# Setup IoTConnect Credentials - certs and config.json
prepare_iotc_creds

# Transfer the payload to the target
transfer_ota_payload

# Update files on the target
update_directory "/tmp/ota-payload/application" "$SCRIPT_DIR/application"
update_directory "/tmp/ota-payload/local_data" "$SCRIPT_DIR/local_data"
update_directory "/tmp/ota-payload/local_data/certs" "$SCRIPT_DIR/local_data/certs"

# Final success message
echo "All OTA payload files processed successfully."

# Ensure proper permissions on the target
ssh $TARGET_USER@$TARGET_IP "chmod -R u+rw,g+rw,o+rw /usr/iotc/local/"
ssh $TARGET_USER@$TARGET_IP "chmod -R u+rwx,g+rwx,o+rwx /usr/iotc/local/scripts"

# Install dependencies on the target
ssh $TARGET_USER@$TARGET_IP "python3 -m pip install requests psutil"

# Call the ota install function with the appropriate paths
copy_and_execute_script "/tmp/ota-payload" "$SCRIPT_DIR/install.sh"

validate_target_state

# Note for users
cat <<EOF

================================================================================
IoTConnect
    To Start IoTConnect Application:
        From host: ssh $TARGET_USER@$TARGET_IP "bash ~/iotc-application.sh"
        From target: ~/iotc-application.sh

    If you encounter a permission error, change permissions with:
        From host: ssh $TARGET_USER@$TARGET_IP "chmod +x ~/iotc-application.sh"
        From target:  chmod +x ~/iotc-application.sh

    To Stop the Application:
        Use Ctrl+C in the terminal running the application.

Setup WiFi
    From host: ssh <user>@<target_ip> "bash /usr/iotc/local/scripts/setup_wifi.sh"
    From target:  /usr/iotc/local/scripts/setup_wifi.sh

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
