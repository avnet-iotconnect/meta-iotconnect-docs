#!/bin/bash

# Stop any running demos before starting a new one
/usr/iotc/local/scripts/stop_demo.sh

# Write the value "demoD" to the file /usr/iotc/local/data/running_model
echo -n "demoD" > /usr/iotc/local/data/running_model

# Execute the HRNet + Tiny YOLOv2 for multi-person detection and pose estimation in the background
cd "/home/root/app_demos/app_hrnet_pre-tinyyolov2_cam/exe/"
nohup ./sample_app_hrnet_pre-tinyyolov2_cam > /dev/null 2>&1 &

