#!/bin/bash

# Path to the Python script
SCRIPT_PATH="/usr/iotc/local/scripts/classification_metrics.py"

# Check if the script exists
if [ -f "$SCRIPT_PATH" ]; then
    echo "Starting classification metrics script..."
    # Run the Python script in the background without logging output
    nohup python3 "$SCRIPT_PATH" >/dev/null 2>&1 &
    echo "Script launched successfully and running in the background."
else
    echo "Error: Script not found at $SCRIPT_PATH"
fi
