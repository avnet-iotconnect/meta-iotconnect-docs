# RZ Board V2L IoTC Quick Start Guide

1. Download the RZ Board V2L quick start package [here](./README.md)
or
```
wget {URL_HERE} -o RZBoardV2L_IoTC.zip
```

2. Unzip the package which contains a `.wic` file for the rootfs, and bootloader files such as `bl2_bp-rzboard.srec`, `fip-rzboard.srec`, and `Flash_Writer_SCIF_rzboard.mot`.
```bash
unzip RZBoardV2L_IoTC.zip
```

3. Flash the wic image named `avnet-core-image-rzboard-YYYYMMDDXXXXX.rootfs.wic` to the SDCard with Balena Etcher or `dd`. While it's doing that you can continue on the rest of the guide.

4. Setup the device by connecting the serial port, the jumper wire, and changing the dip switches. You can skip the ethernet port.
![RZBoardV2L Flashing wiring diagram](https://hackster.imgix.net/uploads/attachments/1634133/image_Epd2Fx4Hue.png?auto=compress%2Cformat&w=740&h=555&fit=max)

5. Download the flash tool to your project directory.
```bash
git clone https://github.com/Avnet/rzboard_flash_util.git
cd rzboard_flash_util
```

6. Install python requirements as root:
```bash
sudo pip3 install -r requirements.txt
```

7. Flash the bootloader to the device:
```bash
sudo ./flash_rzboard.py --bootloader --image_path ./path/to/unzipped/dir
```

8. When prompted to power on the board: connect the power cable and hold the power button for a few seconds until the LED turns on. The script will start flashing your bootloader.

9. Flip the dip switches to the following position to boot from the SDCard:

| Switch | Position |
|--------|----------|
| 1      | OFF      |
| 2      | ON       |

10. Remove the jumper but leave the serial cable, plug the SD Card in and hold the power button to boot the device. As it's booting you should be able to read the serial output with `minicom` or a similar utility.
