#!/bin/bash

# Write the value "none" to the file /usr/iotc/local/data/running_model
echo -n "none" > /usr/iotc/local/data/running_model

# Define the patterns for the demo processes
declare -a demo_patterns=("hrnet_cam" "hrnet_pre-tinyyolov2_cam" "resnet50_cam" "tinyyolov2_cam")

# Function to kill processes based on pattern, excluding IoTConnect
kill_processes() {
    local signal=$1
    local description=$2
    for pattern in "${demo_patterns[@]}"; do
        pids=$(ps aux | grep "$pattern" | grep -v "grep" | grep -v "iotc-application" | awk '{print $2}')
        if [ ! -z "$pids" ]; then
            echo "$description for processes matching pattern: $pattern"
            for pid in $pids; do
                echo "Sending $signal to PID: $pid"
                kill $signal $pid
            done
        else
            echo "No running processes found for pattern: $pattern"
        fi
    done
}

# First, try to gracefully stop the demos with SIGTERM
kill_processes "-15" "Attempting graceful stop (SIGTERM)"

# Wait a few seconds for graceful shutdown (increase time if necessary)
sleep 5

# Check if any processes are still running, and force kill them with SIGKILL
kill_processes "-9" "Forcefully stopping (SIGKILL)"

