# STM32MP257x-EV1 Evaluation Kit QuickStart for Webinar

1. [Introduction](#1-introduction)
2. [Hardware Requirements](#2-hardware-requirements)
3. [Hardware Setup](#3-hardware-setup)
4. [Installing Required Tools](#4-installing-required-tools)
5. [Obtain the Custom Image and Configuration Script](#5-obtain-the-custom-image-and-configuration-script)
6. [Flash the Custom Image](#6-flash-the-custom-image)
7. [Cloud Account Setup](#7-cloud-account-setup)
8. [/IOTCONNECT Device Template Setup](#8-iotconnect-device-template-setup)
9. [Create a Device in /IOTCONNECT](#9-create-a-device-in-iotconnect)
10. [Obtain Board IP address](#10-obtain-board-ip-address)
11. [Running the Device Setup Script](#11-running-the-device-setup-script)
12. [Import a Dashboard](#12-import-a-dashboard)
13. [Using the Demo](#13-using-the-demo)
14. [Further Learning](#14-further-learning)
15. [Resources](#15-resources)
- [Revision Info](#revision-info)

# 1. Introduction
This guide is designed to walk through the steps to connect the STM32MP257-EV1 to the Avnet /IOTCONNECT platform and demonstrate the on-board Image Classification functionality as shown in the [webinar hosted by ST and Avnet](https://players.brightcove.net/4598493563001/BkZJhSKu_default/index.html?videoId=6364751976112) November, 2024. For greatest reach, this guide is written to be following on a Windows 10/11 host machine.

<table>
  <tr>
    <td><img src="../media/STM32MP257F-EV1.jpg" width="6000"></td>
    <td>The STM32MP257 is a powerful microprocessor board based on the ARM Cortex-A7 and Cortex-M4 cores, offering a blend of high-performance computing and low-power operation. It features extensive connectivity options, including Ethernet, USB, and UART interfaces, making it ideal for industrial, IoT, and embedded applications.</td>
  </tr>
</table>

# 2. Hardware Requirements
* STM32MP257F-EV1 Evaluation Board [Purchase](https://www.avnet.com/shop/us/products/stmicroelectronics/stm32mp257f-ev1-3074457345659668899) | [Specifications](https://www.st.com/resource/en/data_brief/stm32mp257f-ev1.pdf) | [User Manual & Kit Contents](https://www.st.com/resource/en/user_manual/um3359-evaluation-board-with-stm32mp257f-mpu-stmicroelectronics.pdf) | [All Resources](https://www.st.com/en/evaluation-tools/stm32mp257f-ev1.html#documentation)
* MicroSD Card (minimum 16GB)
* 2x USB Type-C Cables
* (Optional) 7” LVDS WSVGA Display with Touch Panel (B-LVDS7-WSVGA)
* (Optional) Camera Module Bundle (B-CAMS-IMX)
* (Optional) 5V, 3A Power Supply with barrel jack (Or USB port that can provide equivalent power)

# 3. Hardware Setup
See the reference image below for cable connections.
<details>
<summary>Reference Image with Connections</summary>
<img src="https://github.com/avnet-iotconnect/meta-iotconnect-docs/blob/main/QuickStart/ST/STM32MP257/media/STM32MP257x-EV1_connections.jpg" alt="STM32MP257x-EV1 Connections">
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
   * Ensure the USB Serial Link and DFU drivers are installed.
3. Download and Install [Git for Windows](https://gitforwindows.org/) (or similar application for bash)

---

# 5. Obtain the Custom Image and Configuration Script

### Custom Image
1. Download the custom image: [stm32mp25-eval-image.tar.gz](https://iotconnect-sdk-images.s3.us-east-1.amazonaws.com/MPU/mickledore/st/stm32mp257x-ev1/stm32mp25-eval-image.tar.gz).
2. Extract the contents of the **.gz**
3. Extract the contents of the **.tar**

### Configuration Script
1. Download the device configuration script [onboard.zip](scripts/onboard.zip?raw=1)
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

> [!NOTE]
> It may take up to 5 minutes for the board to fully boot

---

# 7. Cloud Account Setup
An /IOTCONNECT account with AWS backend is required.  If you need to create an account, a free trial subscription is available.

[/IOTCONNECT Free Trial (AWS Version)](https://subscription.iotconnect.io/subscribe?cloud=aws)

> [!NOTE]
> Be sure to check any SPAM folder for the temporary password after registering.

See the /IOTCONNECT [Subscription Information](https://github.com/avnet-iotconnect/avnet-iotconnect.github.io/blob/main/documentation/iotconnect/subscription/subscription.md) for more details on the trial.

# 8. /IOTCONNECT Device Template Setup
A Device Template define the type of telemetery the platform should expect to recieve.
* Download the premade device template [device_template_stm32mp2ai.JSON](https://github.com/avnet-iotconnect/meta-iotconnect-docs/blob/main/QuickStart/ST/STM32MP257/demo-iotc-x-linux-ai/templates/device_template_stm32mp2ai.JSON?raw=1) (**MUST** Right-Click and "Save-As" to get the raw json file)
* Import the template into your /IOTCONNECT instance. (A guide on [Importing a Device Template](https://github.com/avnet-iotconnect/avnet-iotconnect.github.io/blob/main/documentation/iotconnect/import_device_template.md) is available or for more information, please see the [/IOTCONNECT Documentation](https://docs.iotconnect.io/iotconnect/) website.)

# 9. Create a Device in /IOTCONNECT

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
The script in the next section will need to connect to the board update files and configure connection settings.
To accomplish this task, the IP Address of the board is required.  This can be obtained in a couple of ways:
1. Login to your router and find the DHCP lease associated with hostname `stm32mp25-eval`
2. Connect to the board via a serial terminal such as https://googlechromelabs.github.io/serial-terminal/
   * Look for a Device called `ST-LINK VCP Ctrl(COM##)`
   * Type `ifconfig` and look for the IP address under **end0**

* Take note of the IP Address

# 11. Running the Device Setup Script

1. Navigate to your working directory that contains the "onboard" folder in windows explorer
2. Right-click on the onboard folder and select "Open Git Bash here"
3. Enter
```
./initial-device-config-and-update.sh
```
5. Enter the IP address of the board
6. Assuming you placed the `iotcDeviceConfig.json` in the onboarding folder, just hit Enter
7. Assuming you placed the `STM32MP257-certificates.zip` in the onboarding folder, just hit Enter
8. When prompted to replace the .crt file type `A`
9. When prompted again, type `yes`

**Script Completion**: After completion, your device should be fully configured and ready for /IOTCONNECT. If any issues arise, the script provides feedback to help with troubleshooting.

---
# 12. Import a Dashboard
The interactive demo can be loaded by using the Dynamic Dashboard feature of /IOTCONNECT.  
The pre-configured demo dashboard is available here: [dashboard_template_stm32mp2_classification.json](templates/dashboard_template_stm32mp2_classification.json?raw=1) (**must** Right-Click the link, Save As)

* **Download** the template then select "Create Dashboard" from the top of the /IOTCONNECT portal
* **Select** the "Import Dashboard" option and **Select** the *Template* and *Device Name* used previously 
* **Input** a name and complete the import

You will now be in the dashboard edit mode. You can add/remove widgets or just click **Save** in the upper-right to exit the edit mode.

# 13. Using the Demo

The "Target Image" box will randomly display an image from an AWS S3 bucket every 60 seconds.  
* Enter the Device ID (Unique ID) displayed on the dashboard into the field "Enter device ID" then press "View Logs"
* Click the "Model ON / OFF" toggle button to turn on the AI Image Classification model on the device.
* The Dashboard widgets to the right, will being to update with the results momentarily.

> [!NOTE]
> For more information on configuring and using the dashboard see [this guide](https://github.com/avnet-iotconnect/meta-iotconnect-docs/blob/main/QuickStart/ST/STM32MP257/running-the-sample-dashboard.md).

# 14. Further Learning

Other QuickStart guides are available that demonstrate the Object Detection and Pose Estimation models as well as the ability to deploy new models via the /IOTCONNECT OTA service.
To learn more, [view the unabridged QuickStart](https://github.com/avnet-iotconnect/meta-iotconnect-docs/blob/main/QuickStart/STM32MP257.md).

# 15. Resources
* [Webinar Slides](Rapidly_Create_Vision-based_EdgeAI_Solutions_STM32MP257.pdf)
* [Purchase the STM32MP257-EV1 Board](https://www.avnet.com/shop/us/products/stmicroelectronics/stm32mp257f-ev1-3074457345659668899)
* [Additional ST QuickStart Guides](https://www.avnet.com/iotconnect/st)
* [/IOTCONNECT Overview](https://www.iotconnect.io/)
* [/IOTCONNECT Knowledgebase](https://help.iotconnect.io/)

# Revision Info
![GitHub last commit](https://img.shields.io/github/last-commit/avnet-iotconnect/meta-iotconnect-docs?label=Last%20Commit)
- View change to this repository: [Commit History](https://github.com/avnet-iotconnect/meta-iotconnect-docs/commits/main)
- View changes to this document: [QUICKSTART.md](https://github.com/avnet-iotconnect/meta-iotconnect-docs/commits/main/QuickStart/ST/STM32MP257/demo-iotc-x-linux-ai/QuickStart_Webinar.md)
