# RZ Board V2L IoTC Quick Start Guide

1. Download the SDCard image [here](./README.md)
or
```
wget {URL_HERE} -o RZBoardV2L_IoTC.img
```

2. Flash the image to the SDCard with Balena Etcher.

3. Flash the boot loader. https://www.hackster.io/lucas-keller/build-deploy-run-a-qt-enabled-image-on-the-rzboard-v2l-de6c41#toc-hardware-configuration-11

4. Change the dip switches to boot from the SDCard by setting the dip switches to the following position:

| Switch | Position |
|--------|----------|
| 1      | OFF      |
| 2      | ON       |

5. Plug in the SDCard and the power cable. Press and hold the power button until it boots.
