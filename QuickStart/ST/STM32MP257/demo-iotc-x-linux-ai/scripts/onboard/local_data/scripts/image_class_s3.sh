#!/bin/sh

# Write the value "image-s3" to the file /usr/iotc/local.backup/data/running_model
echo "image-s3" > /usr/iotc/local/data/running-model

SCRIPT_PATH="/usr/local/x-linux-ai/image-classification/launch_python_s3_image_classification.sh"
nohup $SCRIPT_PATH > /usr/iotc/local/data/image_classification_s3.log 2>&1 &~
~
~
~
