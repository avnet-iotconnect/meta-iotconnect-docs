#!/bin/sh

# Write the value "image-s3" to the file /usr/iotc/local.backup/data/running_model
echo -n "image-s3" > /usr/iotc/local/data/running-model

SCRIPT_PATH="/usr/local/x-linux-ai/image-classification/launch_python_s3_image_classification.sh"
nohup $SCRIPT_PATH > /usr/iotc/local/data/image_classification_s3.log 2>&1 &


#!/bin/bash

# Define the application paths
app_name="iotc-python-demo.py"
app_dir="/usr/iotc/bin/iotc-python-sdk/"
config_dir="/usr/iotc/local/"
config_name="config.json"

# Full paths
app_path="${app_dir}${app_name}"
config_path="${config_dir}${config_name}"

# Stop any running instances of iotc-python-demo.py
echo "Checking for running instances of $app_name..."
pkill -f $app_name

# Wait briefly to ensure the process is terminated
sleep 2

# Start the application
echo "Starting $app_name..."
/usr/bin/python3 -u "$app_path" "$config_path"

