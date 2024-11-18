#!/bin/bash

# Stop any running demos before starting a new one
/usr/iotc/local/scripts/stop_demo.sh

# Write the value "demoB" to the file /usr/iotc/local/data/running_model
echo -n "demoB" > /usr/iotc/local/data/running_model

# Execute the Tiny YOLOv2 object classification with bounding boxes
cd "/home/root/app_demos/app_tinyyolov2_cam/exe/"
nohup ./sample_app_tinyyolov2_cam > /dev/null 2>&1 &

