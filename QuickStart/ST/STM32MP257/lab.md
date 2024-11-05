# STM32MP257x-EV1 Evaluation Kit Quickstart Guide

## Table of Contents
1. [Starter Package Content](#1-starter-package-content)
2. [Hardware Assembly](#2-hardware-assembly)
3. [Installing Required Tools](#3-installing-required-tools)
4. [Flashing the Custom Image](#4-flashing-the-custom-image)
5. [Running the Initial Device Setup Script](#5-running-the-initial-device-setup-script)
6. [Using IoTConnect and Testing AI Demos](#6-using-iotconnect-and-testing-ai-demos)

---

## 1. Starter Package Content

### Required Materials
- **STM32MP257F-EV1 Evaluation Board**
- **MicroSD Card** (minimum 16GB)
- **USB Type-C Cables**
- **Power Supply** (5V, 3A)

### Optional Materials
- **7” LVDS WSVGA Display with Touch Panel (B-LVDS7-WSVGA)**
- **Camera Module Bundle (B-CAMS-IMX)**
---

## 2. Hardware Assembly
 <details> <summary>Reference Image</summary>
   
![](https://wiki.stmicroelectronics.cn/stm32mpu/nsfr_img_auth.php/thumb/d/d7/STM32MP257x-EV1_connections.jpg/800px-STM32MP257x-EV1_connections.jpg)

 </details>
 
### Minimal Setup
1. Provide WAN access by connecting an Ethernet cable to port labeled #2 on Reference Image
2. Provide Power and Debug Access by connecting a USB C cable from your host to the target port labeled #1 on Reference Image
   -  If your Host cannot provide 3A power over it's USB port, change the header position above the power receptical labeled #6 on the reference image and use an external 5V/3A power supply
3. Provide SD-Card Flash programming over DFU connecting a USB C cable from your host to the target port labeled #4 on Reference Image.
---

## 3. Installing Required Tools
1. **Download and Install STM32CubeProgrammer**: [ST's website](https://www.st.com/en/development-tools/stm32cubeprog.html).
2. **Install USB Serial Link Drivers**:
   - For Linux, install `libusb1.0`.
   - For Windows, install the STM32CubeProgrammer DFU driver.

---

## 4. Flashing the Custom Image

### 4.1 Download the Custom Image
Download the custom TAR file [here](https://iotconnect-sdk-images.s3.amazonaws.com/MPU/hardknott/rz/rzboard-iotc-demo.zip).

### 4.2 Flashing Instructions
1. **Set Boot Switches**: Configure the board to boot from UART/USB.
  <details> <summary>Reference Image</summary>
  
   ![](https://wiki.stmicroelectronics.cn/stm32mpu/nsfr_img_auth.php/thumb/d/d8/STM32MP257x-EV1_boot_switches_UART_USB_mode.jpg/450px-STM32MP257x-EV1_boot_switches_UART_USB_mode.jpg)
 
   </details>
 
2. **Use STM32CubeProgrammer to Flash**:
   ```bash
   STM32_Programmer_CLI -c port=usb1 -w <path_to_flash_layout_file>

   
3. **Set Boot Switches**: Once flashing completes, configure the board to boot from SDCARD.
  <details> <summary>Reference Image</summary>
  
   ![](https://wiki.stmicroelectronics.cn/stm32mpu/nsfr_img_auth.php/thumb/1/11/STM32MP257x-EV1_boot_switches_microSD_card.jpg/450px-STM32MP257x-EV1_boot_switches_microSD_card.jpg)
 
   </details>

4. **Reboot**:  press the reset button to boot with the new system.

6. Running the Initial Device Setup Script

The initial-device.sh script automates much of the setup, including configuring config.json, transferring files, and setting up certificates.
5.1 Initial Device Script Overview

The script organizes files into specific directories on the device, including:
Configuration Files

    config.json: Configures device-specific details like CPID, DUID, environment, and server certificate paths.
    certs/: Contains device certificates for secure connection.
        pk_mcl-STM32AI2.pem: Private key for device authentication.
        cert_mcl-STM32AI2.crt: Public certificate for the device.

Application and AI Demo Scripts

    application: IoTConnect Python SDK and support scripts.
        iotc-python-sdk: Core SDK for IoTConnect interaction.
        iotc-python-demo.py: Example script to demonstrate data exchange.
    x-linux-ai: AI demo scripts and model data.
        image-classification:
            Scripts to launch MobileNetV2 model for image classification.
            Test data for classification.
        object-detection:
            Scripts for object detection using pre-trained models.
        pose-estimation:
            Scripts for human pose estimation.
        semantic-segmentation:
            Scripts for semantic segmentation tasks.

Local Data Files

    local_data: Stores runtime data and command information.
        data:
            classification: Stores classification results.
            confidence: Records model confidence scores.
            running-model: Tracks the active AI model.
            set-conf-level: Configures confidence thresholds.
            version: Holds version information.
        scripts:
            Command scripts to control and monitor device functions, such as starting/stopping models, controlling LEDs, and checking memory usage.

5.2 Running the Script

    Download or Transfer the initial-device.sh Script:
        Place the script in your working directory.

    Run the Script:

    bash

    ./initial-device.sh

    Follow the Prompts:
        The script will prompt you for details like the target IP address, paths to iotcDeviceConfig.json, and the certificate zip file.
        It will automatically:
            Configure device-specific settings in config.json.
            Transfer necessary files (application data, local data, AI models) to the target directories on the device.
            Run the installation script remotely on the device to finalize setup.

    Script Completion:
        After completion, your device should be fully configured and ready for IoTConnect.
        If any issues arise, the script provides feedback to help with troubleshooting.

6. Using IoTConnect and Testing AI Demos
6.1 Set Up IoTConnect

    Create an IoTConnect Account: Register here.
    Import Device Template:
        Download STM32MP2-AI_template.json and import it in IoTConnect under Templates.
    Register Device:
        Use the Device menu to register, then download the device's certificates and place them in the appropriate directory.

6.2 IoTConnect Dashboard

    Import Dashboard Template:
        Download the dashboard JSON template and import it into IoTConnect.
    Assign Device to Dashboard: Select your device to display live telemetry and AI demo outputs.

6.3 Testing AI Demos

Once the board is connected:

    Use Control Panel: Send commands through the Control Panel to start/stop AI demos (e.g., image classification, object detection).
    Monitor AI Outputs: View demo results in the AI Model Results widget on the dashboard.
