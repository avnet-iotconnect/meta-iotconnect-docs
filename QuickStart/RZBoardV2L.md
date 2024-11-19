# RZ Board V2L IoTC Quick Start Guide

# 1. Introduction
This guide is designed to walk through the steps to connect the RZ Board V2L to the Avnet IoTConnect platform and demonstrate the on-board AI functionality as demonstrated in the webinar hosted by Tria and Avnet December, 2024. For greatest reach, this guide is written to be following on a Windows 10/11 host machine.

# 2. Hardware Requirements
* [RZBoard V2L](https://www.avnet.com/wps/portal/us/products/avnet-boards/avnet-board-families/rzboard-v2l)
* MicroSD Card (minimum 16GB)
* MicroSD Card Slot on PC or adapter
* USB Type-C Cable
* Ethernet Cable
* [USB to TTL Serial Cable](https://www.amazon.com/s?k=usb+to+ttl+serial+cable)
* Jumper wire

# 3. Hardware Setup
Set up the device by connecting the following items:
* Connect the USB to Serial port adapter from the PC to the board header
* Connect the Jumper Wire
* Connect the Ethernet cable from the board to you LAN switch/router
* Connect the USB-C cable to the board, but DON'T connect your PC yet
*

Configure the DIP switches:  
1 = ON  
2 = OFF  

Reference Image  
![RZBoardV2L Flashing wiring diagram](https://hackster.imgix.net/uploads/attachments/1634133/image_Epd2Fx4Hue.png?auto=compress%2Cformat&w=740&h=555&fit=max)


# 4. Install Software
* Download and Install [BalenaEtcher](https://www.balena.io/etcher)
* Download and Install [Git for Windows](https://gitforwindows.org/)
* Download and Install [Python for Windows](https://www.python.org/downloads/)
> [!IMPORTANT]
> Ensure to select the add "PYTHON" to the PATH variable option during setup.
 
 
# 5. Flash Image to the Board

1. Download the [RZBoard V2L QuickStart Package](./README.md) to a project directory such as `C:\Renesas\RZboardV2L\`
2. Unzip the package by Right-Clicking and select "Extract Here"
3. Flash the `.wic` file to an SD Card:
    * Insert the SD Card into your computer (or adapter)
    * Open **Balena Etcher**.
    * Select the `.wic` extracted from the .zip file as the source
    * Choose the SD Card as the target
    * Click **Flash** to start the process
> [!NOTE]
> Depending on PC permission, the flash process might fail at the verification step.  You can safely ignore this message.
    

# 6. Download and Setup the Flash Utility
The Flash Utility will be used to setup the bootloader on the board

1. Navigate the project directory `C:\Renesas\RZboardV2L\`
2. Right-Click and select "Open Git Bash here"
3. Clone the latest flash utility from GitHub:  
```bash
git clone https://github.com/Avnet/rzboard_flash_util.git
```

4. Install the Python Requirements:
```bash
pip install -r rzboard_flash_util/requirements.txt
```

5. Flash the bootloader to the device:
>[!IMPORTANT]
>Replace `COM00` with the COM port assigned to your USB to Serial adapter.  This can be found in the Device Manager.
```bash
  python rzboard_flash_util/flash_rzboard.py --serial_port COM00 --bootloader --image_path .
```

6. When prompted, connect the USB cable to your PC.
7. Press and hold the power button for a couple seconds until the LED turns on. The script will begin flashing your bootloader.

> [!NOTE]
> This process will take a few minutes and may appear to be "stuck" at times, but be patient.

8. Once the bootloader is complete, remove power from the board
9. Set the DIP switches to boot from the SD Card:
1 = OFF  
2 = ON  

10. Remove the jumper wire, insert the SD Card, connect the USB power and power on the board by holding the power button for a couple seconds.

## Additional Documentation

For more advanced setup instructions, Yocto Project configurations, and other board features, refer to the following documents:

- **[RZ Board Linux Yocto User Manual v2.3](https://www.avnet.com/wps/wcm/connect/onesite/9fe02bc9-8335-4da2-924a-1bdde941e534/RzBoard-Linux-Yocto-UserManual-v2.3.pdf):** Direct PDF Link
- **[Avnet RZ Board V2L Product Page](https://www.avnet.com/wps/portal/us/products/avnet-boards/avnet-board-families/rzboard-v2l/):** Product Page (with access to additional guides and resources)
