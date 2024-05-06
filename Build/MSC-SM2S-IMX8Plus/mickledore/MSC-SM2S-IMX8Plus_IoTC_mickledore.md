# MSC SM2S-IMX8Plus IoTC mickledore Base Image Build Guide

This will build a base Yocto image without IoTC for your board.

After you have built this you will need to add the [SDK](../../IoTC-SDK/README.md) and the [demos](../../Demos/README.md).

## Method

You will have to download and follow guides hosted on [Avnet Embedded](https://embedded.avnet.com/product/msc-sm2s-imx8plus/#mechanical_data).

1. Start off getting access to the MSC git server (Chapter 3.1 to 3.2) of:  [App_Note_030_Building_from_MSC_Git_V1_9](https://embedded.avnet.com/?__wpdmlo=8955#)

2. Get the url for the git server (Chapter 3.2) from: [App_Note_030_Addendum_Building_from_MSC_Git_2024-04-25](https://embedded.avnet.com/?__wpdmlo=9219#)

3. Clone the private repo, you will need to replace the XXXXXXX with the url from the pdf:
```bash
git clone ssh://gitolite@XXXXXXX:9418/msc_ol99/msc-ldk --branch master && cd msc-ldk
git checkout 96b9a738fc532547ab05d502769cec4fdffafdfb
./setup.py --bsp=01047 --checkout-layers --re-create-conf
```

4. Build the base image:
```bash
make  
```

5. Since this board is built in a different way to the others, the steps for adding the SDK and Demos will be given below:
```bash
cd sources && \
git clone git@github.com:avnet-iotconnect/meta-iotconnect.git -b mickledore && \
git clone git@github.com:avnet-iotconnect/meta-iotconnect-demos.git -b mickledore && \
cd .. && \
cd build/01047 && \
./bitbake-layers add-layer ../../sources/meta-iotconnect && \
./bitbake-layers add-layer ../../sources/meta-iotconnect-demos && \
cd ../../ && \
make
```

## Flashing

1. Follow the `uuu` tool to flash the board's eMMC, instructions are at [App_Note_035_Using_NXP_Mfgtool+uuu](https://embedded.avnet.com/?__wpdmlo=8965#).

2. Set the dip switches as below for eMMC flash and boot:

Note: Towards the `ON` text is on, and away from the `ON` text is off.

| Dip |     |
|-----|-----|
| 1   | ON  |
| 2   | OFF |
| 3   | OFF |
| 4   | OFF |

3. If your board already has a bootloader installed on it then you can flash `msc-image-base-sm2s-imx8mp.wic` to an SD card with Balena Etcher or `dd`:
```bash
sudo dd if=msc-image-base-sm2s-imx8mp.wic of=/dev/mmcblk0 bs=8M conv=fdatasync status=progress
```

4. Set the dip switches as below for SD card boot:

Note: Towards the `ON` text is on, and away from the `ON` text is off.

| Dip |     |
|-----|-----|
| 1   | OFF |
| 2   | ON  |
| 3   | ON  |
| 4   | ON  |

5. Insert the SD card and power on the device.
