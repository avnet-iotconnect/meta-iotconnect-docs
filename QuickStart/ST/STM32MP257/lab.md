# STM32MP257x-EV1 Evaluation Kit AI Demos Quickstart Guide

## 1. Starter Package Content

### Required Hardware
- **STM32MP257F-EV1 Evaluation Board**
- **MicroSD Card** (minimum 16GB)
- **USB Type-C Cables**
- **Power Supply** (5V, 3A)

### Optional Materials
- **7” LVDS WSVGA Display with Touch Panel (B-LVDS7-WSVGA)**
- **Camera Module Bundle (B-CAMS-IMX)**

---

## 2. Hardware Assembly

<details>
<summary>Reference Image</summary>
<img src="https://wiki.stmicroelectronics.cn/stm32mpu/nsfr_img_auth.php/thumb/d/d7/STM32MP257x-EV1_connections.jpg/800px-STM32MP257x-EV1_connections.jpg" alt="STM32MP257x-EV1 Connections">
</details>

### Minimal Setup
1. Provide WAN access by connecting an Ethernet cable to port labeled #2 in the reference image.
2. Provide Power and Debug Access by connecting a USB-C cable from your host to the target port labeled #1 in the reference image.
   - If your host cannot provide 3A power over its USB port, adjust the header above the power receptacle labeled #6 in the reference image and use an external 5V/3A power supply.
3. Provide SD-Card Flash programming over DFU by connecting a USB-C cable from your host to the target port labeled #4 in the reference image.

---

## 3. Installing Required Tools
1. Create a MyST Account.
2. **Download and Install STM32CubeProgrammer V2.17** from [ST's website](https://www.st.com/en/development-tools/stm32cubeprog.html).
3. **Install USB Serial Link Drivers**:
   - For Linux, install `libusb1.0`.
   - For Windows, install the STM32CubeProgrammer DFU driver.

---

## 4. Flashing the Custom Image

### 4.1 Download the Custom Image
Download the custom TAR file [here](https://iotconnect-sdk-images.s3.amazonaws.com/MPU/hardknott/rz/rzboard-iotc-demo.zip).

### 4.2 Flashing Instructions
1. **Set Boot Switches**: Configure the board to boot from UART/USB.

<details>
<summary>Reference Image</summary>
<img src="https://wiki.stmicroelectronics.cn/stm32mpu/nsfr_img_auth.php/thumb/d/d8/STM32MP257x-EV1_boot_switches_UART_USB_mode.jpg/450px-STM32MP257x-EV1_boot_switches_UART_USB_mode.jpg" alt="UART USB Mode Boot Switches">
</details>

2. **Use STM32CubeProgrammer to Flash**:
   - File: `..\STimage\flashlayout_st-image-ai\optee\FlashLayout_sdcard_stm32mp257f-ev1-optee.tsv`
   - Folder: `..\STimage`

3. **Set Boot Switches**: After flashing, configure the board to boot from the SD card.

<details>
<summary>Reference Image</summary>
<img src="https://wiki.stmicroelectronics.cn/stm32mpu/nsfr_img_auth.php/thumb/1/11/STM32MP257x-EV1_boot_switches_microSD_card.jpg/450px-STM32MP257x-EV1_boot_switches_microSD_card.jpg" alt="SD Card Boot Switches">
</details>

4. **Reboot**: Press the reset button to boot with the new system.

---

## 5. Set Up Device in IoTConnect

1. **Create an IoTConnect Account**: Register [here](https://www.iotconnect.io).
2. **Import Device Template**: Download `STM32MP2-AI_template.json` and import it in IoTConnect under Templates.
3. **Register Device**: Use the Device menu to register, then download the device's certificates and place them in the appropriate directory.

---

## 6. Running the Initial Device Setup Script

The `initial-device.sh` script automates much of the setup, including configuring `config.json`, transferring files, and setting up certificates.

### 6.1 Initial Device Script Overview
The script organizes files into specific directories on the device, including:

- **Configuration Files**
  - `config.json`: Configures device-specific details like CPID, DUID, environment, and server certificate paths.
  - `Certs/`: Contains device certificates for secure connection.

- **Application and AI Demo Scripts**: IoTConnect Python SDK and support scripts.
  - `iotc-python-sdk`: Core SDK for IoTConnect interaction.
  - `iotc-python-demo.py`: Example script to demonstrate data exchange.
  - `x-linux-ai`: AI demo scripts and model data.
    - `image-classification`: Scripts for launching MobileNetV2 model for image classification.
    - `object-detection`: Scripts for object detection using pre-trained models.
    - `pose-estimation`: Scripts for human pose estimation.
    - `semantic-segmentation`: Scripts for semantic segmentation tasks.

- **Local Data Files**
  - `local_data`: Stores runtime data and command information.
  - `data/classification`: Stores classification results.
    - `confidence`: Records model confidence scores.
    - `running-model`: Tracks the active AI model.
    - `set-conf-level`: Configures confidence thresholds.
    - `version`: Holds version information.
  - `scripts`: Command scripts to control and monitor device functions, such as starting/stopping models, controlling LEDs, and checking memory usage.

### 6.2 Running the Script

1. **Download or Transfer the `initial-device.sh` Script**: Place the script in your working directory.
2. **Run the Script**:
   ```bash
   ./initial-device.sh
3. **Follow the Prompts**: The script will prompt you for details like the target IP address, paths to `iotcDeviceConfig.json`, and the certificate zip file.
   - The script will automatically:
     - Configure device-specific settings in `config.json`.
     - Transfer necessary files (application data, local data, AI models) to the target directories on the device.
     - Run the installation script remotely on the device to finalize setup.
4. **Script Completion**: After completion, your device should be fully configured and ready for IoTConnect. If any issues arise, the script provides feedback to help with troubleshooting.

---

## 7. Viewing the Demo Through IoTConnect

1. **Import Dashboard Template**: Download the dashboard JSON template and import it into IoTConnect.
2. **Assign Device to Dashboard**: Select your device to display live telemetry and AI demo outputs.

