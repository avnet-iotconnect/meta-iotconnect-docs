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
2. Connect a USB-C cable from your host machine to the port labeled **#4** in the reference image.
3. Insert the MicroSD card into the slot.
4. Set all the Boot Switches to "open" to allow booting from UART/USB (see reference image below).
5. Connect a USB-C cable from your PC to the port labeled **#1** in the reference image.
<details>
<summary>Boot Switches for UART/USB boot</summary>
<img src="https://wiki.stmicroelectronics.cn/stm32mpu/nsfr_img_auth.php/thumb/d/d8/STM32MP257x-EV1_boot_switches_UART_USB_mode.jpg/450px-STM32MP257x-EV1_boot_switches_UART_USB_mode.jpg" alt="UART USB Mode Boot Switches">
</details>

---

# 4. Installing Required Tools
1. Create a [MyST Account](https://my.st.com/cas/login) if you don't have one.
2. Download and Install [STM32CubeProgrammer](https://www.st.com/en/development-tools/stm32cubeprog.html) (Tested with v2.17)
3. Ensure the USB Serial Link and DFU drivers are installed.

---

# 5. Obtain the Custom Image and Configuration Script

### Custom Image
1. Download the custom image: [stm32mp25-eval-image.tar.gz](https://iotconnect-sdk-images.s3.us-east-1.amazonaws.com/MPU/mickledore/st/stm32mp257x-ev1/stm32mp25-eval-image.tar.gz).
2. Extract the contents of the **.gz**
3. Extract the contents of the **.tar**

### Configuration Script
1. Download the device configuration script [onboard.zip](scripts/onboard.zip)
2. Extract the contents to the same location as the `stm32mp25-eval-image` folder

---

# 6. Flash the Custom Image
1. Launch the STM32CubeProgrammer
2. Click "Open File" and navigate to the following file:
   - File: `..\stm32mp25-eval-image\flashlayout_st-image-ai\optee\FlashLayout_sdcard_stm32mp257f-ev1-optee.tsv`
3. Click "Browse" to the right of the "Binaries Path" field and navigate to the following directory:
   - Browse: `..\stm32mp25-eval-image\`
4. In the upper-right corner, click the connection drop-down and select "USB"
5. Click "Connect"
6. Click "Download" and wait as this will take 5-10 minutes.
7. Once the download is complete, close the programmer.
8. Configure the board to boot from the SD card by changing boot switch 1 to closed (see reference image below)

<details>
<summary>Boot Switches for SD card boot</summary>
<img src="https://wiki.stmicroelectronics.cn/stm32mpu/nsfr_img_auth.php/thumb/1/11/STM32MP257x-EV1_boot_switches_microSD_card.jpg/450px-STM32MP257x-EV1_boot_switches_microSD_card.jpg" alt="SD Card Boot Switches">
</details>

9. Press the RESET button to boot the system with the new image.

---

# 7. Cloud Account Setup
An IoTConnect account with AWS backend is required.  If you need to create an account, a free trial subscription is available.

[IoTConnect Free Trial (AWS Version)](https://subscription.iotconnect.io/subscribe?cloud=aws)

> [!NOTE]
> Be sure to check any SPAM folder for the temporary password after registering.

See the IoTConnect [Subscription Information](https://github.com/avnet-iotconnect/avnet-iotconnect.github.io/blob/main/documentation/iotconnect/subscription/subscription.md) for more details on the trial.

# 8. IoTConnect Device Template Setup
A Device Template define the type of telemetery the platform should expect to recieve.
* Download the premade device template [device_template_stm32mp2ai.JSON](https://github.com/avnet-iotconnect/meta-iotconnect-docs/blob/main/QuickStart/ST/STM32MP257/demo-iotc-x-linux-ai/templates/device_template_stm32mp2ai.JSON?raw=1) (**MUST** Right-Click and "Save-As" to get the raw json file)
* Import the template into your IoTConnect instance. (A guide on [Importing a Device Template](https://github.com/avnet-iotconnect/avnet-iotconnect.github.io/blob/main/documentation/iotconnect/import_device_template.md) is available or for more information, please see the [IoTConnect Documentation](https://docs.iotconnect.io/iotconnect/) website.)

# 9. Create a Device in IoTConnect

1. **Click** the Device icon and the "Device" sub-menu
2. At the top-right, click on the "Create Device" button
3. Enter "STM32MP257" for both **Unique ID** and **Device Name**
4. Select the entity in the drop-down (if this is a new/trial account, there is only one option)
5. Select the template ("stm32mp257 AI Demo") from the template dropdown box
6. Leave the Device Certificate as "Auto-generated"
7. Click Save & View
8. Click the "Download device configuration" icon at the top-right and save the file "iotcDeviceConfig.json" into the `..\onboard\` folder
9. Click the link for "Connection Info" and then the icon in the top-right and save the file "STM32MP257-certificates.zip" into the `..\onboard\` folder

---

# 10. Obtain Board IP address
The script in the next sction will need to connect to the board update files and configure connection settings.
To accomplish this task, the IP Address of the board is required.  This can be obtained in a couple of ways:
1. Login to your router and find the DHCP lease
2. Connect to the board via a serial terminal such as https://www.serialterminal.com/

# 11. Running the Device Setup Script

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

