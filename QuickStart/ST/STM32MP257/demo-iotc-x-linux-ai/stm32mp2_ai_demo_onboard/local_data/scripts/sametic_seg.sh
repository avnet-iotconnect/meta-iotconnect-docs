#!/bin/sh

# Write the value "image-s3" to the file /usr/iotc/local.backup/data/running_model
echo "semantic-video" > /usr/iotc/local/data/running-model

SCRIPT_PATH="/usr/local/x-linux-ai/semantic-segmentation/launch_python_semantic_segmentation.sh"
nohup $SCRIPT_PATH > /usr/iotc/local/data/image_classification_video.log 2>&1 &
~
~
~
~
