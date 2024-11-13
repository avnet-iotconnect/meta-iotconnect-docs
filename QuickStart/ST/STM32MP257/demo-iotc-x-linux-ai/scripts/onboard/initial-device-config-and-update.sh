#!/bin/bash

# Prompt the user for the target IP address
read -p "Enter the target IP address: " TARGET_IP

# Prompt for paths and convert them to Unix format if necessary
read -p "Enter the full path and filename for iotcDeviceConfig.json [default: ./iotcDeviceConfig.json]: " DEVICE_CONFIG
DEVICE_CONFIG=${DEVICE_CONFIG:-iotcDeviceConfig.json}
DEVICE_CONFIG=$(cygpath -u "$DEVICE_CONFIG" 2>/dev/null || echo "$DEVICE_CONFIG")

read -p "Enter the full path and filename for the certificates zip file [default: ./STM32MP257-certificates.zip]: " CERT_ZIP
CERT_ZIP=${CERT_ZIP:-STM32MP257-certificates.zip}
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
# Concatenate DUID and CPID with a hyphen and store in unique_id variable
unique_id="${DUID}-${CPID}"

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
      { "name": "unique_id", "private_data": "/usr/iotc/local/data/unique_id", "private_data_type": "ascii" },
      { "name": "version", "private_data": "/usr/iotc/local/data/version", "private_data_type": "ascii" },
      { "name": "runningmodel", "private_data": "/usr/iotc/local/data/running-model", "private_data_type": "ascii" },
      { "name": "classification", "private_data": "/usr/iotc/local/data/classification", "private_data_type": "ascii" },
      { "name": "confidence", "private_data": "/usr/iotc/local/data/confidence", "private_data_type": "ascii" },
      { "name": "threshold", "private_data": "/usr/iotc/local/data/set-conf-level", "private_data_type": "ascii" },
      { "name": "total_classifications", "private_data": "/usr/iotc/local/data/total_classifications", "private_data_type": "ascii" },
      { "name": "unique_classifications", "private_data": "/usr/iotc/local/data/unique_classifications", "private_data_type": "ascii" },
      { "name": "most_common_classification", "private_data": "/usr/iotc/local/data/most_common_classification", "private_data_type": "ascii" },
      { "name": "avg_confidence", "private_data": "/usr/iotc/local/data/avg_confidence", "private_data_type": "ascii" },
      { "name": "max_confidence", "private_data": "/usr/iotc/local/data/max_confidence", "private_data_type": "ascii" },
      { "name": "min_confidence", "private_data": "/usr/iotc/local/data/min_confidence", "private_data_type": "ascii" },
      { "name": "total_mem", "private_data": "/usr/iotc/local/data/total_mem", "private_data_type": "ascii" },
      { "name": "systemd_mem", "private_data": "/usr/iotc/local/data/systemd_mem", "private_data_type": "ascii" },
      { "name": "root_mem", "private_data": "/usr/iotc/local/data/root_mem", "private_data_type": "ascii" },
      { "name": "weston_mem", "private_data": "/usr/iotc/local/data/weston_mem", "private_data_type": "ascii" }
    ]
  }
}' "$CONFIG" > "$CONFIG.tmp" && mv "$CONFIG.tmp" "$CONFIG"

# Write unique_id to /usr/iotc/local/data/unique_id without a newline
echo -n "$unique_id" > /usr/iotc/local/data/unique_id

# Continue with the rest of the onboarding tasks
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

# Create the systemd service file for IoTConnect on the target device
echo "Setting up IoTConnect to run at startup on target device..."
ssh ${TARGET_USER}@${TARGET_IP} "echo \"[Unit]
Description=IoTConnect Service
After=network.target

[Service]
ExecStart=/root/iotc-application.sh
WorkingDirectory=/usr/iotc/local/scripts
StandardOutput=journal
StandardError=journal
Restart=on-failure
RestartSec=5
User=root

[Install]
WantedBy=multi-user.target\" > /etc/systemd/system/iotconnect.service"

# Enable and start the IoTConnect service on the target device
ssh ${TARGET_USER}@${TARGET_IP} "systemctl daemon-reload && systemctl enable iotconnect.service && systemctl start iotconnect.service"

echo "IoTConnect service has been set up and started on the target device."
