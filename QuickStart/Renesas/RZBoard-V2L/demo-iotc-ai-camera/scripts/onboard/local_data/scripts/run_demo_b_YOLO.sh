#!/bin/bash

# Log file for tracking script actions
LOG_FILE="/usr/iotc/local/logs/run_demo.log"

# Stop any running demos before starting a new one
echo "$(date): Stopping existing demos before starting Demo B (YOLOv2)" >> $LOG_FILE
/usr/iotc/local/scripts/stop_demo.sh

# Write the value "demoB" to the running_model file
MODEL="demoB"
echo -n "$MODEL" > /usr/iotc/local/data/running_model
echo "$(date): Running model set to $MODEL" >> $LOG_FILE

# Execute the Tiny YOLOv2 object classification with bounding boxes
DEMO_PATH="/home/root/app_demos/app_tinyyolov2_cam/exe/"
cd "$DEMO_PATH" || { echo "$(date): Failed to change directory to $DEMO_PATH" >> $LOG_FILE; exit 1; }
nohup ./sample_app_tinyyolov2_cam > /dev/null 2>&1 &
if [ $? -eq 0 ]; then
    echo "$(date): Tiny YOLOv2 demo launched successfully" >> $LOG_FILE
else
    echo "$(date): Failed to launch Tiny YOLOv2 demo" >> $LOG_FILE
fi

