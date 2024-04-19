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

2. Download the following packages manually and place inside `RZBoardV2L_IoTC_dunfell` directory

| Package Name                  | Version                   | File                                                                                                                                                                      |
|-------------------------------|---------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| RZ/V Verified Linux Package   | V3.0.2                    | [RTK0EF0045Z0024AZJ-v3.0.2.zip](https://www.renesas.com/us/en/document/swo/rzv-verified-linux-package-v302rtk0ef0045z0024azj-v302zip?r=1628526)                           |
| RZ MPU Graphics Library       | Evaluation Version V1.4   | [RTK0EF0045Z13001ZJ-v1.4_EN.zip](https://www.renesas.com/us/en/document/swo/rz-mpu-graphics-library-evaluation-version-rzv2l-rtk0ef0045z13001zj-v14enzip?r=1843541)       |
| RZ MPU Codec Library          | Evaluation Version V1.0.1 | [RTK0EF0045Z15001ZJ-v1.0.1_EN.zip](https://www.renesas.com/us/en/document/swo/rz-mpu-video-codec-library-evaluation-version-rzv2l-rtk0ef0045z15001zj-v101enzip?r=1844066) |
| RZ/V2L DRP-AI Support Package | V7.30                     | [r11an0549ej0730-rzv2l-drpai-sp.zip](https://www.renesas.com/us/en/document/sws/rzv2l-drp-ai-support-package-version-730?r=1558356)                                       |
| RZ/V2L Multi-OS Package       | V1.10                     | [r01an6238ej0110-rzv2l-cm33-multi-os-pkg.zip](https://www.renesas.com/us/en/document/sws/rzv-multi-os-package-v110)                                                       |


3. Download the provided `Makefile` and `Dockerfile`:
```bash
wget https://raw.githubusercontent.com/avnet-iotconnect/meta-iotconnect-docs/main/Build/RZBoardV2L/Dockerfile && \
wget https://raw.githubusercontent.com/avnet-iotconnect/meta-iotconnect-docs/main/Build/RZBoardV2L/Makefile
```

4. Enter the docker environment:
```bash
make docker
```

5. Download and execute the project setup script:
```bash
wget https://raw.githubusercontent.com/Avnet/meta-rzboard/rzboard_dunfell_5.10_v2/tools/create_yocto_rz_src.sh && \
chmod a+x create_yocto_rz_src.sh && \
./create_yocto_rz_src.sh
```

6. Clone meta-rzboard
```bash
cd ./yocto_rzboard
git clone https://github.com/Avnet/meta-rzboard.git -b rzboard_dunfell_5.10_v2
```

7. Copy over build conf:
```bash
mkdir -p ./build/conf
cp meta-rzboard/conf/rzboard/* build/conf/
exit
```

8. Increase the image size of `avnet-core-image.bb`, you will need to add the line below to `meta-rzboard/recipes-core/images/avnet-core-image.bb`:
```bash
IMAGE_ROOTFS_SIZE = "5120000"
```

9. Build the project:
```bash
make build
```

### Flashing
Flashing instructions based on [Build, Deploy, & Run a Qt Enabled Image on the RZBoard V2L](https://www.hackster.io/lucas-keller/build-deploy-run-a-qt-enabled-image-on-the-rzboard-v2l-de6c41#toc-hardware-configuration-11) but there are some small changes to the instructions, read the instructions to set the jumpers, set dip switches etc and follow the procedure below to download and setup the flashing tool.
```bash
cd yocto_rzboard/build/tmp/deploy/images/rzboard/
git clone https://github.com/Avnet/rzboard_flash_util.git
cd rzboard_flash_util
python3 -m venv venv
source venv/bin/activate
pip3 install -r requirements.txt

# finally to flash
sudo ./flash_rzboard.py --full --image_path ../	
```

#### Notes:
- Based on the [meta-rzboard](https://github.com/Avnet/meta-rzboard/tree/rzboard_dunfell_5.10_v2) repository
- Flashing instructions based on [Build, Deploy, & Run a Qt Enabled Image on the RZBoard V2L](https://www.hackster.io/lucas-keller/build-deploy-run-a-qt-enabled-image-on-the-rzboard-v2l-de6c41#toc-hardware-configuration-11)
