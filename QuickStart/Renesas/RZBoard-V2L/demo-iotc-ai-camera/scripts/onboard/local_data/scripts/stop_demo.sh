#!/bin/bash

LOG_FILE="/usr/iotc/local/logs/stop_demo.log"
RUNNING_MODEL_FILE="/usr/iotc/local/data/running_model"

echo "$(date): Stopping demos" >> "$LOG_FILE"

# Write "none" to running_model file
echo -n "none" > "$RUNNING_MODEL_FILE" && \
    echo "$(date): Cleared running_model file" >> "$LOG_FILE" || \
    { echo "$(date): Error: Unable to clear running_model file" >> "$LOG_FILE"; exit 1; }

# Demo executables
declare -a demo_executables=(
    "sample_app_hrnet_cam"
    "sample_app_hrnet_pre-tinyyolov2_cam"
    "sample_app_resnet50_cam"
    "sample_app_tinyyolov2_cam"
)

kill_processes() {
    local signal=$1
    local description=$2

    for exec_name in "${demo_executables[@]}"; do
        pids=$(pgrep -f "$exec_name")
        if [ -n "$pids" ]; then
            echo "$(date): $description $exec_name (PIDs: $pids)" >> "$LOG_FILE"
            kill "$signal" $pids
            sleep 2  # Wait briefly to allow processes to terminate
            # Verify if processes have stopped
            for pid in $pids; do
                if ps -p "$pid" > /dev/null; then
                    echo "$(date): PID $pid did not terminate with signal $signal." >> "$LOG_FILE"
                    # Only use SIGKILL if the first attempt was SIGTERM
                    if [ "$signal" != "-9" ]; then
                        kill -9 "$pid"
                        echo "$(date): PID $pid forcefully terminated." >> "$LOG_FILE"
                    fi
                else
                    echo "$(date): PID $pid terminated successfully." >> "$LOG_FILE"
                fi
            done
        else
            echo "$(date): No running processes found for $exec_name." >> "$LOG_FILE"
        fi
    done
}

# First attempt graceful stop with SIGTERM
kill_processes "-15" "Attempting graceful stop for"

# No explicit sleep needed here; handled in function already

# Final verification
still_running=false
for exec_name in "${demo_executables[@]}"; do
    if pgrep -f "$exec_name" > /dev/null; then
        echo "$(date): Warning: $exec_name still running after forced stop!" >> "$LOG_FILE"
        still_running=true
    fi
done

if [ "$still_running" = false ]; then
    echo "$(date): All demo processes stopped successfully." >> "$LOG_FILE"
else
    echo "$(date): Warning: Some processes failed to terminate completely." >> "$LOG_FILE"
fi
