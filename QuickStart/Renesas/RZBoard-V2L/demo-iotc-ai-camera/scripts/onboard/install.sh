#!/bin/bash

# Define source directories for the OTA payload (located in /tmp/ota-payload)
SCRIPT_DIR="/tmp/ota-payload"
APPLICATION_PAYLOAD_DIR="$SCRIPT_DIR/application"
LOCAL_DATA_PAYLOAD_DIR="$SCRIPT_DIR/local_data"
DATA_PAYLOAD_DIR="$LOCAL_DATA_PAYLOAD_DIR/data"  # Data folder in the payload
CONFIG_FILE="$LOCAL_DATA_PAYLOAD_DIR/config.json"  # Path to config.json
CERTS_PAYLOAD_DIR="$LOCAL_DATA_PAYLOAD_DIR/certs"  # Certs directory
SCRIPTS_PAYLOAD_DIR="$LOCAL_DATA_PAYLOAD_DIR/scripts"  # Scripts directory

# Define target directories for installation in /usr/iotc
APPLICATION_INSTALLED_DIR="/usr/iotc/bin/iotc-python-sdk"
LOCAL_DATA_INSTALLED_DIR="/usr/iotc/local"
CERTS_INSTALLED_DIR="/usr/iotc/local/certs"
SCRIPTS_INSTALLED_DIR="/usr/iotc/local/scripts"

# Backup directory
BACKUP_DIR="/tmp/.ota/backup"

# Create necessary directories if they don't exist
mkdir -p "$BACKUP_DIR"
mkdir -p "$LOCAL_DATA_INSTALLED_DIR"
mkdir -p "$CERTS_INSTALLED_DIR"
mkdir -p "$SCRIPTS_INSTALLED_DIR"

# Backup existing files in the target directories
cp -va "$APPLICATION_INSTALLED_DIR"/* "$BACKUP_DIR/" 2>/dev/null
cp -va "$LOCAL_DATA_INSTALLED_DIR"/* "$BACKUP_DIR/" 2>/dev/null

# Function to update a directory
update_directory() {
    local payload_dir="$1"
    local target_dir="$2"

    if [ -d "$payload_dir" ]; then
        mkdir -p "$target_dir"  # Ensure target directory exists
        cp -va "$payload_dir"/* "$target_dir/"
        echo "Updated $target_dir with files from $payload_dir"
    else
        echo "Warning: Payload directory $payload_dir not found, skipping update."
    fi
}

# Update application files
update_directory "$APPLICATION_PAYLOAD_DIR" "$APPLICATION_INSTALLED_DIR"

# Update data files in /usr/iotc/local/data
update_directory "$DATA_PAYLOAD_DIR" "$LOCAL_DATA_INSTALLED_DIR/data"

# Update scripts in /usr/iotc/local/scripts
update_directory "$SCRIPTS_PAYLOAD_DIR" "$SCRIPTS_INSTALLED_DIR"

# Copy config.json to /usr/iotc/local/config.json
if [ -f "$CONFIG_FILE" ]; then
    cp -v "$CONFIG_FILE" "$LOCAL_DATA_INSTALLED_DIR/config.json"
    echo "Updated config.json in $LOCAL_DATA_INSTALLED_DIR"
else
    echo "Error: config.json not found in $LOCAL_DATA_PAYLOAD_DIR"
    exit 1
fi

# Copy certificates to /usr/iotc/local/certs
if [ -d "$CERTS_PAYLOAD_DIR" ]; then
    mkdir -p "$CERTS_INSTALLED_DIR"
    cp -va "$CERTS_PAYLOAD_DIR"/* "$CERTS_INSTALLED_DIR/"
    echo "Copied certificates to $CERTS_INSTALLED_DIR"
else
    echo "Error: Certs directory not found in $LOCAL_DATA_PAYLOAD_DIR"
    exit 1
fi

# Final success message
if [ $? -eq 0 ]; then
    echo "install.sh completed successfully."
else
    >&2 echo "install.sh encountered errors."
    exit 1
fi