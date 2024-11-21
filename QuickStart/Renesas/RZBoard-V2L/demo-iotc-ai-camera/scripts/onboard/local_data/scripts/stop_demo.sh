#!/bin/bash

LOG_FILE="/usr/iotc/local/logs/stop_demo.log"
echo "$(date): Stopping demos" >> $LOG_FILE

# Write "none" to running_model file
echo -n "none" > /usr/iotc/local/data/running_model
echo "$(date): Cleared running_model file" >> $LOG_FILE

# Demo patterns
declare -a demo_patterns=("hrnet_cam" "hrnet_pre-tinyyolov2_cam" "resnet50_cam" "tinyyolov2_cam")

kill_processes() {
    local signal=$1
    local description=$2
    for pattern in "${demo_patterns[@]}"; do
        pids=$(pgrep -f "$pattern" | grep -v "$(pgrep -f iotc-application)")
        if [ ! -z "$pids" ]; then
            echo "$(date): $description for processes matching pattern: $pattern" >> $LOG_FILE
            for pid in $pids; do
                echo "$(date): Sending $signal to PID: $pid" >> $LOG_FILE
                kill $signal $pid
                if ps -p $pid > /dev/null; then
                    echo "$(date): PID $pid did not terminate. Forcing termination." >> $LOG_FILE
                    kill -9 $pid
                fi
            done
        else
            echo "$(date): No running processes found for pattern: $pattern" >> $LOG_FILE
        fi
    done
}

# Graceful stop
kill_processes "-15" "Attempting graceful stop (SIGTERM)"
sleep 5

# Forceful stop if necessary
kill_processes "-9" "Forcefully stopping (SIGKILL)"

# Final verification
for pattern in "${demo_patterns[@]}"; do
    if pgrep -f "$pattern" >/dev/null; then
        echo "$(date): Warning: Process $pattern is still running after forced stop!" >> $LOG_FILE
    fi
done

