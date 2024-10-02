# IoTConnect AI Classification on STM32MP1/MP2 Devices (X-Linux-AI)
This document provides details specific to using IoTConnect for running AI classification demos on STM32MP1 and MP2 devices, which utilize the X-Linux-AI package.

## Overview
STM32MP1 and MP2 devices running X-Linux-AI can perform AI classification using pre-trained models such as MobileNet. These AI tasks can be triggered remotely from the IoTConnect platform using cloud-to-device commands.

## Prerequisites
Before proceeding, ensure you have:

An STM32MP1 or MP2 device running the X-Linux-AI package.
IoTConnect platform access with the necessary credentials (CPID, DUID, etc.).
AI classification scripts and models (such as MobileNet) installed on the device.
The IoTConnect Python SDK installed on the device.
Directory Structure
Ensure your project has a structure similar to this:

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
- scripts/: Contains shell scripts that are remotely triggered from IoTConnect.
- models/: Contains pre-trained AI models like MobileNet.
- resources/: Stores configuration files like config_board.sh.

## AI Classification Script
The primary AI classification script is launch_ai_classification.sh, which runs an AI model inference using Python. Ensure the script has executable permissions.

### Script Example:
```
#!/bin/bash
# AI classification script for STM32MP2
MODEL_PATH="/usr/local/x-linux-ai/image-classification/models/mobilenet/mobilenet_v2_1.0_224_int8_per_tensor.tflite"
SCRIPT_PATH="/usr/local/x-linux-ai/image-classification/stai_mpu_image_classification.py"
### Run Python AI classification
python3 $SCRIPT_PATH -m $MODEL_PATH
```
- MODEL_PATH: Points to the pre-trained model.
- SCRIPT_PATH: The Python script that performs inference using the model.

### Make the script executable:
```
chmod +x /usr/iotc-c/app/scripts/launch_ai_classification.sh
```
### Deploying and Running the AI Classification
1) Create IoTConnect Command
To run the AI classification script remotely, create a command in IoTConnect:
- Command Name: launch_ai_classification
- Command Payload:
```
{
  "command": "launch_ai_classification",
  "script": "/usr/iotc-c/app/scripts/launch_ai_classification.sh"
}
```
2) Assign the Command to Your Device
Once the command is created, assign it to your STM32MP1/MP2 device. The device will listen for the command and execute the classification script when received.

3) Run AI Classification
Send the command from the IoTConnect platform and monitor the device logs for successful execution of the AI classification.

## Monitoring and Troubleshooting
Memory Usage Monitoring: The memory_usage.sh script can be used to track memory consumption during the classification process.
Device Logs: Monitor logs on the device to ensure the classification is running as expected. For permission errors, verify that scripts have the necessary executable permissions.
Example Command Handler (on Device)
The following Python script can be used to handle incoming commands from IoTConnect and execute the AI classification:
```
import subprocess
from iotconnect import IoTConnectSDK

iotc = IoTConnectSDK(device_id="DEVICE_ID", client_key="CLIENT_KEY")

def on_command_received(command):
    script_path = command.get('script')
    if script_path:
        subprocess.run(script_path, shell=True)

iotc.on_command_received = on_command_received
iotc.connect()
```
## Troubleshooting
- Command Not Executing: Ensure that the script path provided in the command payload is correct and that the script is executable.
- Memory Issues: If the device is running out of memory, check usage with memory_usage.sh or other monitoring tools.
