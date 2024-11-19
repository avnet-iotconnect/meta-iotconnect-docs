# RZ Board V2L IoTC Quick Start Guide

# 1. Introduction
This guide is designed to walk through the steps to connect the RZ Board V2L to the Avnet IoTConnect platform and demonstrate the on-board AI functionality as demonstrated in the webinar hosted by Tria and Avnet December, 2024. For greatest reach, this guide is written to be following on a Windows 10/11 host machine.

# 2. Hardware Requirements
* RZ Board V2L
* MicroSD Card (minimum 16GB)
* USB Type-C Cable
* Ethernet Cable
* USB to TTL Serial Cable
* Jumper wire

# 3. Hardware Setup

Set up the device by connecting the following items:
* USB to Serial port adapter
* Jumper wire
* Ethernet Cable
* USB-C
*

Configure the DIP switches 1 = ON, 2 = OFF

Reference Image
![RZBoardV2L Flashing wiring diagram](https://hackster.imgix.net/uploads/attachments/1634133/image_Epd2Fx4Hue.png?auto=compress%2Cformat&w=740&h=555&fit=max)


# 4. Install Software
* Download and Install [BalenaEtcher](https://www.balena.io/etcher)
* Download and Install [Git for Windows](https://gitforwindows.org/)
* Download and Install [Python for Windows](https://www.python.org/downloads/)
  * Ensure to select the add "PYTHON" to the PATH variable option during setup
 
 
# 5. Flash Image

1. Download the RZ Board V2L QuickStart package: [FILENAME](./README.md)
2. Unzip the package by Right-Click, "Extract Here"
3. Flash the `.wic` file to an SD Card

 Insert your SD Card into your computer and choose one of the following methods to flash the `.wic` file:
     1. Open **Balena Etcher**.
     2. Select the `.wic` file as the source.
     3. Choose the SD Card as the target.
     4. Click **Flash** to start the process.

5. Download the flash utility tool to your project directory:
     ```bash
     git clone https://github.com/Avnet/rzboard_flash_util.git
     ```
     ```bash
     cd rzboard_flash_util
     ```
6. Install Python requirements:

     ```cmd
     pip install -r requirements.txt
     ```

7. Flash the bootloader to the device:

   Run `flash_rzboard.py` from a Python-enabled shell as Administrator, specifying the correct path to the images.
    ```bash
      python rzboard_flash_util/flash_rzboard.py --serial_port COM00 --bootloader --image_path .
    ```

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
