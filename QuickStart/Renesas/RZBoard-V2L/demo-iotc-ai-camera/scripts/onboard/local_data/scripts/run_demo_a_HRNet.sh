#!/bin/bash

# Stop any running demos before starting a new one
/usr/iotc/local/scripts/stop_demo.sh

# Write the value "demoA" to the file /usr/iotc/local/data/running_model
echo -n "demoA" > /usr/iotc/local/data/running_model

# Execute the HRNet demo in the background
cd "/home/root/app_demos/app_hrnet_cam/exe/"
nohup ./sample_app_hrnet_cam > /dev/null 2>&1 &
	
