#!/bin/bash

LOG_FILE="/usr/iotc/local/logs/stop_demo.log"
RUNNING_MODEL_FILE="/usr/iotc/local/data/running_model"

echo "$(date): Stopping demos" >> $LOG_FILE

# Write "none" to running_model file
if echo -n "none" > $RUNNING_MODEL_FILE; then
    echo "$(date): Cleared running_model file" >> $LOG_FILE
else
    echo "$(date): Error: Unable to clear running_model file" >> $LOG_FILE
    exit 1
fi

# Demo patterns
declare -a demo_patterns=("hrnet_cam" "hrnet_pre-tinyyolov2_cam" "resnet50_cam" "tinyyolov2_cam")

kill_processes() {
    local signal=$1
    local description=$2
    local retry_count=3
    local retry_delay=2

    for pattern in "${demo_patterns[@]}"; do
        pids=$(pgrep -f "$pattern" | grep -v "$(pgrep -f iotc-application)")
        if [ ! -z "$pids" ]; then
            echo "$(date): $description for processes matching pattern: $pattern" >> $LOG_FILE
            for pid in $pids; do
                echo "$(date): Sending $signal to PID: $pid" >> $LOG_FILE
                kill $signal $pid
                for ((i = 0; i < retry_count; i++)); do
                    if ! ps -p $pid > /dev/null; then
                        echo "$(date): PID $pid terminated successfully." >> $LOG_FILE
                        break
                    fi
                    echo "$(date): Waiting for PID $pid to terminate..." >> $LOG_FILE
                    sleep $retry_delay
                done

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

# Reset USB camera (if applicable)
USB_DEVICE_PATH="/sys/bus/usb/devices/2-1.3/authorized"
if [ -e "$USB_DEVICE_PATH" ]; then
    echo "$(date): Resetting USB camera..." >> $LOG_FILE
    echo 0 > "$USB_DEVICE_PATH"
    sleep 1
    echo 1 > "$USB_DEVICE_PATH"
    echo "$(date): USB camera reset completed." >> $LOG_FILE
else
    echo "$(date): Warning: USB device path $USB_DEVICE_PATH not found. Skipping USB reset." >> $LOG_FILE
fi

# Final verification
process_running=false
for pattern in "${demo_patterns[@]}"; do
    if pgrep -f "$pattern" >/dev/null; then
        echo "$(date): Warning: Process $pattern is still running after forced stop!" >> $LOG_FILE
        process_running=true
    fi
done

if [ "$process_running" = false ]; then
    echo "$(date): All demo processes stopped successfully." >> $LOG_FILE
else
    echo "$(date): Warning: Some processes failed to terminate completely." >> $LOG_FILE
fi


