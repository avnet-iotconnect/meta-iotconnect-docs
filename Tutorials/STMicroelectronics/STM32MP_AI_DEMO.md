# IoTConnect AI Classification Script Documentation
This documentation describes the setup and usage of scripts used for AI classification on STM32MP2 devices integrated with IoTConnect. These scripts are designed to enable remote execution via the IoTConnect platform and run AI models such as MobileNet for image classification.

## Table of Contents
- Prerequisites
- Directory Structure
- Script Configuration
- Creating IoTConnect Commands
- Handling Commands on the Device
- Running AI Classification
- Troubleshooting

## Prerequisites
Before proceeding, ensure you have the following:
- STM32MP2 device with Linux OS.
- IoTConnect platform access (CPID, DUID, etc.).
- IoTConnect Python SDK installed on the device.
- AI classification scripts and models (such as MobileNet) stored on the device.
- Proper permissions and setup for sudo or user-level script execution.

## Directory Structure
Your project directory should follow a structure similar to the following:

```
/usr/iotc-c/app/
├── scripts/
│   ├── launch_ai_classification.sh
│   ├── memory_usage.sh
│   └── other_script.sh
├── models/
│   └── mobilenet_v2_1.0_224_int8_per_tensor.tflite
└── resources/
    └── config_board.sh
```

- scripts/: Contains shell scripts that can be triggered remotely from IoTConnect.
- models/: Pre-trained AI models for classification (e.g., MobileNet in TensorFlow Lite format).
- resources/: Additional configuration scripts or resources.

## Script Configuration
### AI Classification Script (launch_ai_classification.sh)
This script runs an AI classification using a MobileNet model and Python inference script. Make sure the script has executable permissions.

Example content for launch_ai_classification.sh:
```
#!/bin/bash
# AI classification script for STM32MP2

MODEL_PATH="/usr/local/x-linux-ai/image-classification/models/mobilenet/mobilenet_v2_1.0_224_int8_per_tensor.tflite"
SCRIPT_PATH="/usr/local/x-linux-ai/image-classification/stai_mpu_image_classification.py"

# Run Python AI classification
python3 $SCRIPT_PATH -m $MODEL_PATH
```
- MODEL_PATH: The path to the pre-trained model.
- SCRIPT_PATH: The Python script that performs inference using the model.

Make the script executable:
```
chmod +x /usr/iotc-c/app/scripts/launch_ai_classification.sh
```
### Memory Usage Script (memory_usage.sh)
A utility script to track memory usage per user on the device:
```
#!/bin/bash

total_mem=0
printf "%-10s%-10s\n" User MemUsage'(%)'

while read u m; do
    [[ $old_user != $u ]] && { printf "%-10s%-0.1f\n" $old_user $total_mem; total_mem=0; }
    total_mem="$(echo $m + $total_mem | bc)"
    old_user=$u
done < <(ps --no-headers -eo user,%mem | sort -k1)

#EOF
```

This can be useful for tracking resource consumption during AI classification.

## Creating IoTConnect Commands
To trigger a script remotely via IoTConnect, you need to create a command in the IoTConnect platform.

### Step-by-Step Command Creation
1) Log in to IoTConnect and navigate to the Commands section.
2) Create a new command, for example:

	- Command Name: "launch_ai_classification"
	- Command Payload:
```
{
  "command": "launch_ai_classification",
  "script": "/usr/iotc-c/app/scripts/launch_ai_classification.sh"
}
```
3) Save the command and assign it to your device.
4) You can also create additional commands to run other scripts, such as monitoring memory usage:
	- Command Name: "memory_usage"
	- Command Payload:
```
{
  "command": "memory_usage",
  "script": "/usr/iotc-c/app/scripts/memory_usage.sh"
}
```

## Handling Commands on the Device
The device needs to be configured to listen for incoming commands and run the specified scripts. Below is an example of Python code that can be used on the device to handle commands.

### Example Python Script (iot_command_handler.py)
```
import subprocess
from iotconnect import IoTConnectSDK

# Initialize IoTConnect SDK
iotc = IoTConnectSDK(device_id="<YOUR_DEVICE_ID>", client_key="<YOUR_CLIENT_KEY>")

def on_command_received(command):
    print(f"Received command: {command}")
    if 'command' in command and 'script' in command:
        script_path = command['script']
        try:
            subprocess.run(script_path, check=True)
            print(f"Successfully executed: {script_path}")
        except subprocess.CalledProcessError as e:
            print(f"Error executing script: {str(e)}")
    else:
        print("Unknown command or missing script path.")

# Set the command handler
iotc.on_command_received = on_command_received

# Start listening for commands
iotc.connect()
```

### How It Works
	- The device listens for commands from IoTConnect.
	- When a command is received, the script path is extracted from the payload, and the script is executed using subprocess.run().

## Running AI Classification
Once the setup is complete:

1) Send a command from IoTConnect:
	- Command: "launch_ai_classification"
	- Payload:
```
{
  "command": "launch_ai_classification",
  "script": "/usr/iotc-c/app/scripts/launch_ai_classification.sh"
}
```
2) Monitor device logs to ensure the AI classification is running.
3) Verify the output of the AI classification either through logs or by checking the system’s output on a display if configured.

## Troubleshooting
### Common Issues:
1) Connection Errors:
	- Ensure the device's credentials (DUID, CPID, certificates) are correctly configured.
	- Verify that the IoTConnect Python SDK is correctly installed.
2) Permission Denied:
	- Ensure the scripts have executable permissions:
```
chmod +x /usr/iotc-c/app/scripts/*.sh
```
3) Script Not Running:
	- Verify that the script path in the IoTConnect command matches the script’s location on the device.
	- Check the device logs for error messages related to subprocess.run.
