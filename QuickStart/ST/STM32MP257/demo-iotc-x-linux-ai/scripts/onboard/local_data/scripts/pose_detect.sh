#!/bin/sh

# Write the value "image-s3" to the file /usr/iotc/local.backup/data/running_model
echo -n "image-video" > /usr/iotc/local/data/running-model

SCRIPT_PATH="/usr/local/x-linux-ai/pose-estimationn/launch_python_pose_estimation.sh"
nohup $SCRIPT_PATH > /usr/iotc/local/data/image_classification_video.log 2>&1 &