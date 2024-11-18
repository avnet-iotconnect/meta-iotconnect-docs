# RZ Board V2L IoTC Quick Start Guide

# 1. Introduction

# 2. Hardware Requirements

# 3. Download / Install Software

1. Download the RZ Board V2L QuickStart package: [FILENAME](./README.md)
2. Unzip the package by Right-Click, "Extract Here"
3. Flash the `.wic` file to an SD Card

5. 
# 4. Hardware Setup

3. **Flash the `.wic` File to an SD Card**

   Insert your SD Card into your computer and choose one of the following methods to flash the `.wic` file:

   - **Linux (using dd)**:
     ```bash
     sudo dd if=avnet-core-image-rzboard-YYYYMMDDXXXXX.rootfs.wic of=/dev/sdX bs=4M status=progress
     ```
     Replace `/dev/sdX` with the appropriate path to your SD Card. Be careful to avoid overwriting other drives.

   - **Windows (using Win32 Disk Imager)**:
     1. Open **Win32 Disk Imager**.
     2. In the "Image File" field, select the `.wic` file. If it doesn’t appear, rename it to `.img`.
     3. Choose the SD Card as the destination drive.
     4. Click **Write** to begin the flashing process.

   - **Windows or Linux (using Balena Etcher)**:
     1. Open **Balena Etcher**.
     2. Select the `.wic` file as the source.
     3. Choose the SD Card as the target.
     4. Click **Flash** to start the process.

4. Set up the device by connecting the serial port, attaching the jumper wire, and configuring the DIP switches. You can skip the Ethernet port for this setup.
   
   ![RZBoardV2L Flashing wiring diagram](https://hackster.imgix.net/uploads/attachments/1634133/image_Epd2Fx4Hue.png?auto=compress%2Cformat&w=740&h=555&fit=max)

5. Download the flash utility tool to your project directory:
   - **Linux** / **Windows (Git Bash)**:
     ```bash
     git clone https://github.com/Avnet/rzboard_flash_util.git
     ```
     ```bash
     cd rzboard_flash_util
     ```
6. Install Python requirements:
   - **Linux**:
     ```bash
     sudo pip3 install -r requirements.txt
     ```
   - **Windows**: Open Command Prompt as Administrator and run:
     ```cmd
     pip install -r requirements.txt
     ```

7. Flash the bootloader to the device:
   - **Linux**:
     ```bash
     sudo ./flash_rzboard.py --bootloader --image_path ./path/to/unzipped/dir
     ```
   - **Windows**: Run `flash_rzboard.py` from a Python-enabled shell as Administrator, specifying the correct path to the images.

8. When prompted to power on the board: connect the power cable and hold the power button for a few seconds until the LED turns on. The script will begin flashing your bootloader.

9. Set the DIP switches to boot from the SD Card as shown below:

   | Switch | Position |
   |--------|----------|
   | 1      | OFF      |
   | 2      | ON       |

10. Remove the jumper wire, leave the serial cable connected, insert the SD Card, and power on the board by holding the power button. You can monitor the boot process:
   - **Linux**: Use `minicom` or `screen` to read the serial output:
     ```bash
     minicom -D /dev/ttyUSB0 -b 115200
     ```
   - **Windows**: Use a serial terminal like PuTTY, selecting the appropriate COM port and baud rate (115200).

## Additional Documentation

For more advanced setup instructions, Yocto Project configurations, and other board features, refer to the following documents:

- **[RZ Board Linux Yocto User Manual v2.3](https://www.avnet.com/wps/wcm/connect/onesite/9fe02bc9-8335-4da2-924a-1bdde941e534/RzBoard-Linux-Yocto-UserManual-v2.3.pdf):** Direct PDF Link
- **[Avnet RZ Board V2L Product Page](https://www.avnet.com/wps/portal/us/products/avnet-boards/avnet-board-families/rzboard-v2l/):** Product Page (with access to additional guides and resources)
