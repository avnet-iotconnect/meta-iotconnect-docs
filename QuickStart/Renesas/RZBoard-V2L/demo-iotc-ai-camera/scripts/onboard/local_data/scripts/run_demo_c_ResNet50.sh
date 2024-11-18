#!/bin/bash

# Stop any running demos before starting a new one
/usr/iotc/local/scripts/stop_demo.sh

# Write the value "demoC to the file /usr/iotc/local/data/running_model
echo -n "demoC" > /usr/iotc/local/data/running_model

# Execute the ResNet50 object classification without bounding boxes
cd "/home/root/app_demos/app_resnet50_cam/exe/"
nohup ./sample_app_resnet50_cam > /dev/null 2>&1 &
