#!/bin/bash

# Log file for tracking script actions
LOG_FILE="/usr/iotc/local/logs/run_demo.log"

# Stop any running demos before starting a new one
echo "$(date): Stopping existing demos before starting Demo C (ResNet50)" >> $LOG_FILE
/usr/iotc/local/scripts/stop_demo.sh

# Write the value "demoC" to the running_model file
MODEL="demoC"
echo -n "$MODEL" > /usr/iotc/local/data/running_model
echo "$(date): Running model set to $MODEL" >> $LOG_FILE

# Execute the ResNet50 object classification without bounding boxes
DEMO_PATH="/home/root/app_demos/app_resnet50_cam/exe/"
cd "$DEMO_PATH" || { echo "$(date): Failed to change directory to $DEMO_PATH" >> $LOG_FILE; exit 1; }
nohup ./sample_app_resnet50_cam > /dev/null 2>&1 &
if [ $? -eq 0 ]; then
    echo "$(date): ResNet50 demo launched successfully" >> $LOG_FILE
else
    echo "$(date): Failed to launch ResNet50 demo" >> $LOG_FILE
fi
