# STM32MP257x-EV1 Evaluation Kit QuickStart for Webinar

# 1. Introduction

# 2. Requirements

## Environment
* Windows 10/11

## Hardware
* STM32MP257F-EV1 Evaluation Board
* MicroSD Card (minimum 16GB)
* 2x USB Type-C Cables
* (Optional) 7” LVDS WSVGA Display with Touch Panel (B-LVDS7-WSVGA)
* (Optional) Camera Module Bundle (B-CAMS-IMX)
* (Optional) 5V, 3A Power Supply with barrel jack (Or USB port that can provide equivalent power)

# 3. Hardware Setup
See the reference image below for cable connections.
<details>
<summary>Reference Image</summary>
<img src="https://wiki.stmicroelectronics.cn/stm32mpu/nsfr_img_auth.php/thumb/d/d7/STM32MP257x-EV1_connections.jpg/800px-STM32MP257x-EV1_connections.jpg" alt="STM32MP257x-EV1 Connections">
</details>

1. Connect an Ethernet cable from your LAN (router/switch) to the port labeled **#2** in the reference image.
2. Connect a USB-C cable from your PC to the port labeled **#1** in the reference image.
> [!NOTE]
> If using the optional display and camera, your host machine must be able to supply 3A on the USB port.  If it cannot, use a wall adapter (e.g. phone charger) that meets the power requirements or adjust the header above the power receptacle labeled **#6** in the reference image and use an external 5V/3A barrel style connector and power supply.
3. Connect a USB-C cable from your host machine to the port labeled **#4** in the reference image.

---

# 4. Installing Required Tools
1. Create a [MyST Account](https://my.st.com/cas/login) if you don't have one.
2. Download and Install [STM32CubeProgrammer](https://www.st.com/en/development-tools/stm32cubeprog.html) (Tested with v2.17)
3. Ensure the USB Serial Link and DFU drivers are installed.

---

# 5. Flashing the Custom Image

1. Download the custom image: [stm32mp25-eval-image.tar.gz](https://iotconnect-sdk-images.s3.us-east-1.amazonaws.com/MPU/mickledore/st/stm32mp257x-ev1/stm32mp25-eval-image.tar.gz).
2. Set Boot Switches to boot from UART/USB using the reference image below

<details>
<summary>Boot Switchs for UART/USB boot</summary>
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

