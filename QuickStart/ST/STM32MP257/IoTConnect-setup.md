# STM32MP257 IoTConnect Setup Guide

This guide outlines the steps to configure your STM32MP257 device for IoTConnect. You’ll create an account, set up device templates, register the device, and configure the `config.json` file for secure connectivity.

---

## Table of Contents

1. [IoTConnect Account Setup](#iotconnect-account-setup)
2. [Template Import and Device Registration](#template-import-and-device-registration)
3. [Obtaining Certificates and Credentials](#obtaining-certificates-and-credentials)
4. [Editing the config.json File](#editing-the-configjson-file)
5. [Connecting the Device to IoTConnect](#connecting-the-device-to-iotconnect)
6. [Troubleshooting](#troubleshooting)

---

### 1. IoTConnect Account Setup

1. **Create an Account**:
   - Go to [IoTConnect Registration](https://iotconnect.io/) and sign up for a free 2-month subscription.
   - Complete the registration process to receive your unique CPID (Company ID), which is essential for device connectivity.

2. **Sign In**:
   - After registration, log in to IoTConnect.
   - Locate your CPID in the account details; this will be used later in the `config.json` setup.

---

### 2. Template Import and Device Registration

1. **Create a Device Template**:
   - Download the device template file: [STM32MP2-AI_template.json](./device-templates/stm32mp2ai_template.JSON) 
   - In IoTConnect, navigate to the **Device** icon in the left menu and select **Templates**.
   - Click **Create Template** and then **Import**.
   - Upload the `stm32mp2ai_template.JSON` file and save it.

2. **Register the Device**:
   - Go to the **Device** menu and select **Create Device**.
   - Fill in the following details:
     - **Unique ID**: STM32MP157F (or another unique identifier).
     - **Display Name**: STM32MP157F (or preferred name).
     - **Entity**: Choose your entity.
     - **Template**: Select the `stm32mp2ai_template` you just imported.
   - Save the device, then access **Connection Info** to download the certificate package by clicking the certificate icon.

---

### 3. Obtaining Certificates and Credentials

1. **Download and Extract the Certificate Package**:
   - After creating the device, download the certificate package, which includes:
     - `device.key`: Private key for the device.
     - `DeviceCertificate.pem`: Public certificate for the device.

2. **Retrieve CPID, Discovery URL, and Environment**:
   - Go to **Settings > Key Vault** in the IoTConnect dashboard to find the following details:
     - **CPID** (Company ID)
     - **Environment**
     - **Discovery URL**

---

### 4. Editing the config.json File

To connect the STM32MP257 to IoTConnect, update the `config.json` file on your device with your device ID, CPID, environment, and certificate paths.

1. **SSH into the Board**:
   - Obtain the board’s IP address and use SSH to access the device. You can find the board's IP address by selecting the Netdata app on the board's GUI.
     ```bash
     ssh root@<board_ip>
     ```
   - Default credentials:
     - Username: `root`

2. **Locate and Edit config.json**:
   - Navigate to the `config.json` file:
     ```bash
     cd /usr/iotc/local/
     ```
   - Open `config.json` with a text editor:
     ```bash
     vi config.json
     ```
   - Update the fields as follows:
     ```json
     {
         "sdk_ver": "2.1",
         "duid": "STM32MP157F",  // Device Unique ID
         "cpid": "your-cpid-here",  // CPID from IoTConnect Key Vault
         "env": "your-environment-here",  // env from IoTConnect Key Vault
         "discovery_url": "https://your-discovery-url-here",  // Discovery URL from IoTConnect Key Vault
         "iotc_server_cert": "/path/to/RootCA.pem", // Discovery URL from IoTConnect Key Vault's "Root CA Authorities" tab
         "auth": {
             "auth_type": "IOTC_AT_X509",
             "params": {
                 "client_key": "/path/to/device.key",
                 "client_cert": "/path/to/DeviceCertificate.pem"
             }
         }
     }
     ```
   - Save and close the file (in `vi`, press `ESC`, then type `:wq`).

---

### 5. Connecting the Device to IoTConnect

1. **Run the Connection Script**:
   - After updating the `config.json`, navigate to the root directory:
     ```bash
     cd /
     ```
   - Execute the connection script:
     ```bash
     ./connect_to_iotc.sh
     ```
   - This script will initiate the connection based on your `config.json` settings.

2. **Verify Connection**:
   - Log into the IoTConnect portal and go to the **Live Data** tab to confirm that telemetry data is being received from the STM32MP257.

---

### 6. Troubleshooting

If you encounter issues, consider the following steps:

- **Check config.json**: Verify all fields, particularly the CPID, discovery URL, and file paths for certificates.
- **Network Connection**: Ensure the device has a stable internet connection.
- **Examine Logs**:
   ```bash
   sudo journalctl -u iotconnect
