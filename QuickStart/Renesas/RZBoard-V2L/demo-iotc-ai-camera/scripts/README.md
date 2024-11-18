# `initial-device-config-and-update.sh` Script Overview

The `initial-device-config-and-update.sh` script automates the configuration and deployment of the IoTConnect application on the STM32MP257x-EV1 Evaluation Kit. It streamlines the setup process by handling configuration updates, certificate management, file transfers, and necessary installations.

## Prerequisites

- **IoTConnect Account**: Ensure you have an active IoTConnect account.
- **Configuration File**: Obtain the `iotcDeviceConfig.json` file from your IoTConnect portal.
- **Certificate Archive**: Download the `STM32MP257-certificates.zip` containing the necessary certificate files.
- **Network Connectivity**: Verify that the STM32MP257x-EV1 board is connected to the same network as your host machine.

## Script Workflow

1. **User Prompts**:
   - **Target IP Address**: The script prompts for the IP address of the target device.
   - **Configuration File Path**: Prompts for the path to `iotcDeviceConfig.json`. If not provided, defaults to `./iotcDeviceConfig.json`.
   - **Certificate ZIP File Path**: Prompts for the path to the certificate ZIP file. If not provided, defaults to `./STM32MP257-certificates.zip`.

2. **Configuration Updates**:
   - Extracts `uid`, `cpid`, `env`, and `disc` from `iotcDeviceConfig.json`.
   - Updates corresponding fields in `config.json`.
   - Adds device attributes to `config.json`, specifying paths to various data files on the target device.

3. **Certificate Management**:
   - Verifies the existence of the certificate ZIP file.
   - Extracts the private key and certificate files from the ZIP archive.
   - Updates the paths to these certificates in `config.json`.

4. **Remote Deployment**:
   - Creates a temporary directory (`/tmp/ota-payload`) on the target device.
   - Transfers application files, local data, and the installation script to the target device.
   - Sets executable permissions for the installation script and executes it on the target device.

5. **Post-Deployment Setup**:
   - Copies the `labels_imagenet_2012.txt` file to the appropriate directory on the target device.
   - Sets read and write permissions for all files in `/usr/iotc/local/data`.
   - Makes all scripts in `/usr/iotc/local/scripts` executable.
   - Installs the `requests` Python package for both 'root' and 'weston' users on the target device.
   - Initiates the IoTConnect program on the target device.

## Usage Instructions

1. **Execute the Script**: Run the script in a Unix-like environment. If using Windows, consider using Git Bash or the Windows Subsystem for Linux (WSL).
2. **Provide Inputs**: When prompted, enter the target device's IP address and the paths to the `iotcDeviceConfig.json` and certificate ZIP files. Default values are provided and can be accepted by pressing Enter.
3. **Monitor the Process**: The script will display progress messages. Upon successful completion, the IoTConnect application will be deployed and initiated on the target device.

## Error Handling

The script includes basic error handling to check for the existence of files and successful execution of commands. If an error occurs during the process, an appropriate message is displayed, and the script exits with a non-zero status.

## Notes

- **Path Conversion**: The script uses `cygpath` to convert Windows-style paths to Unix format when necessary. This is particularly useful when running the script in a Windows environment.
- **Permissions**: Ensure that the user executing the script has the necessary permissions to read the configuration and certificate files and to execute SSH and SCP commands.
- **Dependencies**: The target device should have SSH and SCP services running and accessible. Additionally, Python and the `pip` package manager should be installed on the target device to facilitate the installation of the `requests` library.