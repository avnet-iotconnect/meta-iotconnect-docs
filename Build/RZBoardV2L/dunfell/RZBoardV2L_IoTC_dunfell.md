# RZ Board V2L IoTC Dunfell Base Image Build Guide
Tested on Ubuntu 22.04 (2024-04-19)

This will build a base Yocto image without IoTC for your board.

After you have built this you will need to add the [SDK](../../IoTC-SDK/README.md) and the [demos](../../Demos/README.md).

## Requirements
- Docker: 

    https://docs.docker.com/engine/install/ubuntu/
    
    https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user
- Git: `name` and `email` configured globally:

    `git config --global user.name "{YOUR_NAME_HERE}"`

    `git config --global user.email "{YOUR_EMAIL_HERE}"`

## Method
1. Create project directory and enter it:
```bash
mkdir RZBoardV2L_IoTC_dunfell && cd RZBoardV2L_IoTC_dunfell 
```

2. Download the following packages manually and place inside the `RZBoardV2L_IoTC_dunfell` directory

| Package Name                  | Version                   | Download File                                                                                                                                                             |
|-------------------------------|---------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| RZ/V Verified Linux Package   | V3.0.4                    | [RTK0EF0045Z0024AZJ-v3.0.4.zip](https://www.renesas.com/us/en/document/swo/rzv-verified-linux-package-v304rtk0ef0045z0024azj-v304zip?r=1628526)                           |
| RZ MPU Graphics Library       | Evaluation Version V1.1.0 | [RTK0EF0045Z13001ZJ-v1.1.0_EN.zip](https://www.renesas.com/us/en/document/sws/rz-mpu-graphics-library-evaluation-version-rzv2l-rtk0ef0045z13001zj-v110enzip?r=1843541)    |
| RZ MPU Codec Library          | Evaluation Version V1.1.0 | [RTK0EF0045Z15001ZJ-v1.1.0_EN.zip](https://www.renesas.com/us/en/document/sws/rz-mpu-video-codec-library-evaluation-version-rzv2l-rtk0ef0045z15001zj-v110enzip?r=1844066) |
| RZ/V2L DRP-AI Support Package | V7.40                     | [r11an0549ej0740-rzv2l-drpai-sp.zip](https://www.renesas.com/us/en/document/sws/rzv2l-drp-ai-support-package-version-740?r=1558356)                                       |
| RZ/V2L Multi-OS Package       | V1.11                     | [r01an6238ej0111-rzv2l-cm33-multi-os-pkg.zip](https://www.renesas.com/us/en/document/sws/rzv-multi-os-package-v111?r=1570181)                                             |


3. Download the provided `Makefile` and `Dockerfile`:
```bash
wget https://raw.githubusercontent.com/avnet-iotconnect/meta-iotconnect-docs/main/Build/RZBoardV2L/dunfell/Dockerfile && \
wget https://raw.githubusercontent.com/avnet-iotconnect/meta-iotconnect-docs/main/Build/RZBoardV2L/dunfell/Makefile
```

4. Download and execute the project setup script:
```bash
wget https://raw.githubusercontent.com/Avnet/meta-rzboard/rzboard_dunfell_5.10_v3/tools/create_yocto_rz_src.sh && \
chmod a+x create_yocto_rz_src.sh && \
./create_yocto_rz_src.sh
```

5. Clone meta-rzboard into our sources:
```bash
cd ./yocto_rzboard
git clone https://github.com/Avnet/meta-rzboard.git -b rzboard_dunfell_5.10_v3
```

6. Copy over build conf:
```bash
mkdir -p ./build/conf
cp meta-rzboard/conf/rzboard/* build/conf/
```

7. Increase the image size of `avnet-core-image.bb`:
```bash
echo -e "\nIMAGE_ROOTFS_SIZE = \"5120000\"" >> meta-rzboard/recipes-core/images/avnet-core-image.bb
```

8. Build the project:
```bash
cd ..
make build
```

### Flashing via eMMC

1. Setup the device by connecting the serial port, the jumper wire, and changing the dip switches. You can skip the ethernet port.
![RZBoardV2L Flashing wiring diagram](https://hackster.imgix.net/uploads/attachments/1634133/image_Epd2Fx4Hue.png?auto=compress%2Cformat&w=740&h=555&fit=max)

Dip switch configured as shown
| Switch | Position |
|--------|----------|
| 1      | ON       |
| 2      | OFF      |

Jumper wire connected across the board like in the diagram.
SD card removed.

2. Navigate to the images directory, this will contain the flash tool `flash_util.py`:
```bash
cd yocto_rzboard/build/tmp/deploy/images/rzboard/
```

3. Flash the bootloader to the device:
```bash
sudo ./flash_util.py --bootloader
```
4. When prompted to power on the board: connect the power cable and hold the power button for a few seconds until the LED turns on. The script will start flashing your bootloader. After it's done power off the device.

5. Unplug the Jumper wire going across the board.
   
6. Flash the image to the device:
```bash
sudo ./flash_util.py --rootfs
```
It is also possible to specify the path to an exisiting image using 
```bash
sudo ./flash_util.py --rootfs --image_rootfs <path-to>.rootfs.wic
```

7. When prompted to power on the board: connect the power cable and hold the power button for a few seconds until the LED turns on. After it's done power off the device.

8. Use the power switch again to power the device, as it's booting you should be able to read the serial output with `minicom` or a similar utility.

### Flashing SD Card

1. Using Balena Etcher or `dd` write `avnet-core-image-rzboard.wic` to an SD card. This file will be a symlink to another file named `avnet-core-image-rzboard-YYYYMMDDXXXXX.rootfs.wic`. While it's doing that you can continue on the rest of the guide.



2. Setup the device by connecting the serial port, the jumper wire, and changing the dip switches. You can skip the ethernet port.
![RZBoardV2L Flashing wiring diagram](https://hackster.imgix.net/uploads/attachments/1634133/image_Epd2Fx4Hue.png?auto=compress%2Cformat&w=740&h=555&fit=max)

3. Download the flash tool to the your images dir:
```bash
cd yocto_rzboard/build/tmp/deploy/images/rzboard/
git clone https://github.com/Avnet/rzboard_flash_util.git
cd rzboard_flash_util
```

4. Install python requirements as root:
```bash
sudo pip3 install -r requirements.txt
```

5. Flash the bootloader to the device:
```bash
sudo ./flash_rzboard.py --bootloader --image_path ../
```

6. When prompted to power on the board: connect the power cable and hold the power button for a few seconds until the LED turns on. The script will start flashing your bootloader. After it's done power off the device.


7. Flip the dip switches to the following position to boot from the SDCard:

| Switch | Position |
|--------|----------|
| 1      | OFF      |
| 2      | ON       |

8. Remove the jumper but leave the serial cable, plug the SD Card in and hold the power button to boot the device. As it's booting you should be able to read the serial output with `minicom` or a similar utility.

#### Notes:
- Based on the [meta-rzboard](https://github.com/Avnet/meta-rzboard/tree/rzboard_dunfell_5.10_v3) repository
- Flashing instructions based on [Build, Deploy, & Run a Qt Enabled Image on the RZBoard V2L](https://www.hackster.io/lucas-keller/build-deploy-run-a-qt-enabled-image-on-the-rzboard-v2l-de6c41#toc-hardware-configuration-11)
- You may have to remove systemd from the demo files in order for the Yocto image to build.
