# OTA Update Tutorial

This tutorial explains how to create and install an Over-The-Air (OTA) update using the provided folder structure and `install.sh` script. The OTA process ensures that the device’s application and local data are updated safely and reliably.

## OTA Payload Folder Structure

The OTA payload consists of a specific folder structure, which is cosmpressed into a `.tar.gz` file and uploaded to the device. The folder structure is as follows:
```
ota-payload-template/
├── install.sh
├── application
├  ├── model
├  └── scripts
├── local_data
│   └── certs
└── README
```
## Key Components:

- **`install.sh`**: The script responsible for installing the OTA update on the device.
- **`application/`**: This folder contains new or updated application files. These will be installed in `/usr/iotc/bin/iotc-python-sdk`.
- **`local_data/`**: This folder contains local data such as configuration files or certificates. These will be installed in `/usr/iotc/local`.

## OTA Example Payload

An example payload might look like this:
```
ota-payload-template/
├── application
├  ├── model
├  ├── scripts
├  ├  └── get_mem_usage.sh
├  └── telemetry_demo.py 
├── install.sh 
├── local_data
├  ├── certs 
├  ├  └── device.key
├  └── config.json
└── README
```

### This payload would:

- Update `application/telemetry_demo.py`, replacing the current Python file.
- Add a new script `get_mem_usage.sh` to the device.
- Update the local configuration (`local_data/config.json`) and certificate (`local_data/certs/device.key`).

## Creating the OTA Payload

### Modify the template:

- Place your new or updated files into the appropriate directories (`application/` or `local_data/`).

### Construct the payload:

- Navigate to the root of the folder and run:

```bash
./construct_payload.sh
```
This will create a ota-payload.tar.gz file, which is ready to be uploaded to the device.

## Deploy the OTA Payload using IoTConnect
IoTConnect users to manage firmware based on hardware and software versioning. A walk-through of this feature and process is documented [here](https://help.iotconnect.io/documentation/ota-firmware-updates-management/firmware-management/).


## `install.sh` Script Explanation

The `install.sh` script is responsible for handling the installation of the OTA update. Below is a breakdown of its key components:

### 1. Defining Directories

- **`SCRIPT_DIR`**: The directory where the script is located.
- **Payload Directories**:
  - `application_payload_dir`: New application files from the OTA payload.
  - `local_data_payload_dir`: New local data files from the OTA payload.
- **Installed Directories**:
  - `application_installed_dir`: Current application files on the device.
  - `local_data_installed_dir`: Current local data on the device.
- **Backup Directories**:
  - `application_backup_dir`: Backup location for the current application files.
  - `local_data_backup_dir`: Backup location for the current local data files.

### 2. Backup Process

The script creates backups of the current installed files before applying the OTA update:

If a backup directory already exists, it is removed:

```
if [ -d "$backup_dir" ]; then
    echo "Removing existing backup... at $backup_dir"
    rm -r "$backup_dir"
fi
```
### 3. Modify Paths in Backups

After creating the backup, the script updates any paths in configuration files to point to the new backup directory:

```
find "$backup_dir" -type f -print | while read -r file; do
    sed -i "s|$installed_dir|$backup_dir|g" "$file"
```

### 4. Installing the OTA Payload

The OTA payload is installed by copying the new application and data files from the OTA payload to the corresponding directories on the device:

```
cp -va $payload_dir. $to_install_dir
```

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
