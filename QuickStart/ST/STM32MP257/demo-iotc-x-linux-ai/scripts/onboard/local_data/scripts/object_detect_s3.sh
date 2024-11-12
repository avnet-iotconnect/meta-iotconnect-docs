#!/bin/sh

# Write the value "image-s3" to the file /usr/iotc/local.backup/data/running_model
echo -n "object-is3" > /usr/iotc/local/data/running-model

# Path to the script you want to launch
SCRIPT_PATH="/usr/local/x-linux/object-detection/aunch_python_object_detection_S3.sh"
nohup $SCRIPT_PATH > /usr/iotc/local/data/image_classification.log 2>&1 &
