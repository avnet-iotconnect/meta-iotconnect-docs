# OTA Update Tutorial for STMicroelectronics X-Linux-AI Package

This tutorial explains how to create and install an Over-The-Air (OTA) update using the provided folder structure and `install.sh` script. The OTA process ensures that the device’s application and local data are updated safely and reliably.

## OTA Payload Folder Structure

The OTA payload consists of a specific folder structure, which is compressed into a `.tar.gz` file and uploaded to the device. The folder structure is as follows:
```
ota-payload-template/
├── install.sh
├── application/
├── local_data/
│ ├── certs/
│ ├── classification
│ ├── confidence
│ ├── running-model
│ ├── set-conf-level
│ ├── version
│ ├── temp
│ ├── scripts/
│ ├── x-linux-ai/
│ │ ├── image-classification/
│ │ │ ├── stai_mpu_S3_image_classification.py
│ │ │ ├── launch_python_s3_image_classification.sh
│ │ │ ├── models/
│ │ │ │ ├── mobilenet/
│ │ │ │ │ ├── model_files
│ │ │ │ └── testdata/
└── README.md
```
### Key Components:

- `install.sh`: The script responsible for installing the OTA update on the device.
- `application/`: Contains new or updated application files. These will be installed in `/usr/iotc/bin/iotc-python-sdk`.
- `local_data/`: Contains local data such as configuration files or certificates. These will be installed in `/usr/iotc/local`.

## OTA Example Payload

An example payload might look like this:
```
ota-payload-template/
├── application/
│ ├── telemetry_demo.py
├── local_data/
│ ├── certs/
│ ├── classification
│ ├── confidence
│ ├── running-model
│ ├── set-conf-level
│ ├── version
│ ├── temp
│ ├── scripts/
│ ├── control_led.sh
│ ├── get_mem_usage.sh
│ ├── image_class_live.sh
│ ├── stop_video.sh
│ ├── object_detect_live.sh
│ ├── object_detect_s3.sh
│ ├── image_class_s3.sh
│ ├── stop_image_classification.sh
│ ├── sametic_seg.sh
│ └── pose_detect.sh
│ ├── x-linux-ai/
│ │ ├── image-classification/
│ │ │ ├── stai_mpu_S3_image_classification.py
│ │ │ ├── launch_python_s3_image_classification.sh
│ │ │ ├── models/
│ │ │ │ ├── mobilenet/
│ │ │ │ │ ├── model_files
│ │ │ │ └── testdata/
└── install.sh
```

This payload would:

- Update `application/telemetry_demo.py`, replacing the current Python file.
- Add new scripts to the device.
- Update the local configuration (local_data/config.json) and other files like `classification`, `confidence`, and `version`.

## Creating the OTA Payload

### Step 1: Modify the Template

Place your new or updated files into the appropriate directories (`application/` or `local_data/`).

### Step 2: Construct the Payload

Navigate to the root of the folder and run:

```bash
tar -czvf ota-payload.tar.gz ota-payload-template/
```
This will create a ota-payload.tar.gz file, which is ready to be uploaded to the device.

### Step 3: Deploy the OTA Payload using IoTConnect
IoTConnect allows users to manage firmware updates. Upload the ota-payload.tar.gz file through the IoTConnect platform for OTA deployment.

  ---
  
## install.sh Script Explanation
The install.sh script is responsible for handling the installation of the OTA update. Below is a breakdown of its key components:

### 1. Defining Directories
SCRIPT_DIR: The directory where the script is located.
Payload Directories:
application_payload_dir: New application files from the OTA payload.
local_data_payload_dir: New local data files from the OTA payload.
Installed Directories:
application_installed_dir: Current application files on the device.
local_data_installed_dir: Current local data on the device.
Backup Directories:
backup_dir: Backup location for the current application and local data files.
### 2. Backup Process
The script creates backups of the current installed files before applying the OTA update:
```
if [ -d "$backup_dir" ]; then
    echo "Removing existing backup... at $backup_dir"
    rm -r "$backup_dir"
fi
```
### 3. Installing the OTA Payload
The OTA payload is installed by copying the new application and data files from the OTA payload to the corresponding directories on the device:
```
cp -va $payload_dir/* $to_install_dir/
```
### 4. Custom File Updates
Custom files outside the regular /usr/iotc/local structure are updated, such as:

/usr/local/x-linux-ai/image-classification/
/usr/local/x-linux-ai/image-classification/models/mobilenet/
### 5. Completion Check
The script checks if the installation was successful:
```
if [ $? -eq 0 ]; then
    echo "install.sh completed successfully."
else
    >&2 echo "install.sh encountered errors."
    exit 1
fi
```
  ---
  
## OTA Handler Details
Below is an example of how the OTA handler manages the update process in the IoT platform:
```
class OtaHandler:
    # Omitted for brevity, refer to the provided OTA handler code.
```
This will initiate the OTA process, download the payload, extract it, and run install.sh. The handler monitors for success and logs the output.
 ---
## Files to Update in OTA
You need to ensure that the following files are included in the OTA update process:
- /usr/iotc/local/data/classification
- /usr/iotc/local/data/confidence
- /usr/iotc/local/data/running-model
- /usr/iotc/local/data/set-conf-level
- /usr/iotc/local/data/version
- /usr/iotc/local/data/temp
- /usr/local/x-linux-ai/image-classification/stai_mpu_S3_image_classification.py
- /usr/local/x-linux-ai/image-classification/launch_python_s3_image_classification.sh
- /usr/local/x-linux-ai/image-classification/models/mobilenet/
- /usr/local/x-linux-ai/image-classification/models/mobilenet/testdata/


