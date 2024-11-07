#!/bin/bash

# Prompt the user for the target IP address
read -p "Enter the target IP address: " TARGET_IP

# Prompt for paths and convert them to Unix format if necessary
read -p "Enter the full path to iotcDeviceConfig.json [iotcDeviceConfig.json]: " DEVICE_CONFIG
DEVICE_CONFIG=${DEVICE_CONFIG:-iotcDeviceConfig.json}
DEVICE_CONFIG=$(cygpath -u "$DEVICE_CONFIG" 2>/dev/null || echo "$DEVICE_CONFIG")

read -p "Enter the full path to the certificate zip file: " CERT_ZIP
CERT_ZIP=$(cygpath -u "$CERT_ZIP" 2>/dev/null || echo "$CERT_ZIP")

# Define constants
TARGET_USER="root"
TARGET_DIR="/tmp/ota-payload"  # Temporary directory on the target

# Paths to local files and directories
CONFIG="local_data/config.json"
CERTS_DIR="local_data/certs"

# Extract values from iotcDeviceConfig.json
DUID=$(grep '"uid"' "$DEVICE_CONFIG" | awk -F'"' '{print $4}')
CPID=$(grep '"cpid"' "$DEVICE_CONFIG" | awk -F'"' '{print $4}')
ENV=$(grep '"env"' "$DEVICE_CONFIG" | awk -F'"' '{print $4}')
DISCOVERY_URL=$(grep '"disc"' "$DEVICE_CONFIG" | awk -F'"' '{print $4}')

# Update config.json with the extracted values and default values for sdk_ver and connection_type
sed -i "s/\"duid\": \".*\"/\"duid\": \"$DUID\"/" "$CONFIG"
sed -i "s/\"cpid\": \".*\"/\"cpid\": \"$CPID\"/" "$CONFIG"
sed -i "s/\"env\": \".*\"/\"env\": \"$ENV\"/" "$CONFIG"
sed -i "s|\"discovery_url\": \".*\"|\"discovery_url\": \"$DISCOVERY_URL\"|" "$CONFIG"
sed -i "s|\"sdk_ver\": \".*\"|\"sdk_ver\": \"2.1\"|" "$CONFIG"
sed -i "s|\"connection_type\": \".*\"|\"connection_type\": \"IOTC_CT_AWS\"|" "$CONFIG"
sed -i "s|\"iotc_server_cert\": \".*\"|\"iotc_server_cert\": \"/etc/ssl/certs/Amazon_Root_CA_1.pem\"|" "$CONFIG"
sed -i "s|\"sdk_id\": \".*\"|\"sdk_id\": \"<SDK_ID_PLACEHOLDER>\"|" "$CONFIG"  # Replace placeholder if needed

# Add device configuration with attributes to config.json
jq '. + {
  "device": {
    "commands_list_path": "/usr/iotc/local/scripts",
    "attributes": [
      { "name": "version", "private_data": "/usr/iotc/local/data/version", "private_data_type": "ascii" },
      { "name": "runningmodel", "private_data": "/usr/iotc/local/data/running-model", "private_data_type": "ascii" },
      { "name": "threshold", "private_data": "/usr/iotc/local/data/set-conf-level", "private_data_type": "ascii" },
      { "name": "classification", "private_data": "/usr/iotc/local/data/classification", "private_data_type": "ascii" },
      { "name": "confidence", "private_data": "/usr/iotc/local/data/confidence", "private_data_type": "ascii" },
      { "name": "accel", "private_data": "/usr/iotc/local/data/script-version", "private_data_type": "ascii" }
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

# Step 1: Create the target directory on the remote device
echo "Creating directory on target device..."
ssh ${TARGET_USER}@${TARGET_IP} "mkdir -p ${TARGET_DIR}"

# Step 2: Transfer the entire payload directory to the target, excluding unnecessary files
echo "Transferring files to ${TARGET_USER}@${TARGET_IP}:${TARGET_DIR}..."
scp -r application local_data x-linux-ai install.sh ${TARGET_USER}@${TARGET_IP}:${TARGET_DIR}/

# Step 3: Run the installation script on the target and set permissions
echo "Setting executable permissions for install.sh on target device..."
ssh ${TARGET_USER}@${TARGET_IP} "chmod +x ${TARGET_DIR}/install.sh"
echo "Running installation script on the target..."
ssh ${TARGET_USER}@${TARGET_IP} "/bin/sh ${TARGET_DIR}/install.sh"

# Step 4: Set file permissions and install requirements
if [ $? -eq 0 ]; then
    echo "OTA update completed successfully."
    
    # Copy the labels file on the target device
    echo "Copying labels_imagenet_2012.txt to labels_imagenet_2012 on the target device..."
    ssh ${TARGET_USER}@${TARGET_IP} "cp /usr/local/x-linux-ai/image-classification/labels_imagenet_2012.txt /usr/local/x-linux-ai/image-classification/labels_imagenet_2012"
    echo "Labels file copied successfully."

    # Set read and write permissions for all files in /usr/iotc/local/data
    ssh ${TARGET_USER}@${TARGET_IP} "chmod -R u+rw,g+rw,o+rw /usr/iotc/local/data/*"
    echo "Read and write permissions set on /usr/iotc/local/data/*"

    # Make all scripts in /usr/iotc/local/scripts executable
    ssh ${TARGET_USER}@${TARGET_IP} "find /usr/iotc/local/scripts -type f -exec chmod +x {} \;"
    echo "Executable permissions set on all files within /usr/iotc/local/scripts and its subdirectories"
    
    # Install the requests library for both 'weston' and 'root' users
    echo "Installing 'requests' package for 'root' and 'weston' users..."
    ssh ${TARGET_USER}@${TARGET_IP} "python3 -m pip install requests"
    ssh ${TARGET_USER}@${TARGET_IP} "su -l weston -c 'python3 -m pip install --user requests'"
    echo "'requests' package installed for both 'root' and 'weston' users."

    # Execute the IoTConnect program
    echo "Starting IoTConnect program..."
    ssh ${TARGET_USER}@${TARGET_IP} "~/iotc-application.sh"
else
    echo "OTA update failed." >&2
    exit 1
fi