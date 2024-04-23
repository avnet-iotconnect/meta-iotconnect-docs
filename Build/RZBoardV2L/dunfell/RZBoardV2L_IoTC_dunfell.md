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

### Flashing
Flashing instructions based on [Build, Deploy, & Run a Qt Enabled Image on the RZBoard V2L](https://www.hackster.io/lucas-keller/build-deploy-run-a-qt-enabled-image-on-the-rzboard-v2l-de6c41#toc-hardware-configuration-11) but there are some small changes to the instructions, read the instructions to set the jumpers, set dip switches etc and follow the procedure below to download and setup the flashing tool.
```bash
cd yocto_rzboard/build/tmp/deploy/images/rzboard/
git clone https://github.com/Avnet/rzboard_flash_util.git
cd rzboard_flash_util
sudo pip3 install -r requirements.txt

# finally to flash
sudo ./flash_rzboard.py --full --image_path ../	
```

#### Notes:
- Based on the [meta-rzboard](https://github.com/Avnet/meta-rzboard/tree/rzboard_dunfell_5.10_v3) repository
- Flashing instructions based on [Build, Deploy, & Run a Qt Enabled Image on the RZBoard V2L](https://www.hackster.io/lucas-keller/build-deploy-run-a-qt-enabled-image-on-the-rzboard-v2l-de6c41#toc-hardware-configuration-11)
