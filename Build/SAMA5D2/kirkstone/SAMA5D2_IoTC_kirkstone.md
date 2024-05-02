# {BOARD_NAME} IoTC {YOCTO_VERSION} Base Image Build Guide

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
mkdir SAMA5D2_IoTC_kirkstone && cd SAMA5D2_IoTC_kirkstone
```

2. Clone layer sources:
```bash
# Poky
git clone https://git.yoctoproject.org/poky && cd poky && \
git checkout -b kirkstone yocto-4.0.13 && cd - && \
# meta-openembedded
git clone git://git.openembedded.org/meta-openembedded && cd meta-openembedded && \
git checkout -b kirkstone 79a6f6 && cd - && \
# meta-atmel
git clone https://github.com/linux4sam/meta-atmel.git && cd meta-atmel && \
git checkout linux4microchip-2023.10-rc4 && cd - && \
# meta-arm
git clone https://git.yoctoproject.org/meta-arm && cd meta-arm && \
git checkout -b kirkstone yocto-4.0.1 && cd -
```

3. Download the provided `Makefile` and `Dockerfile`:
```bash
wget https://raw.githubusercontent.com/avnet-iotconnect/meta-iotconnect-docs/main/Build/SAMA5D2/kirkstone/Makefile && \
wget https://raw.githubusercontent.com/avnet-iotconnect/meta-iotconnect-docs/main/Build/SAMA5D2/kirkstone/Dockerfile
```

4. Setup the template conf:
```bash
echo "export TEMPLATECONF=\${TEMPLATECONF:-../meta-atmel/conf}" > poky/.templateconf
```

5. Build the image:
```bash
make build
```

#### Notes:
- These docs are based on: https://github.com/linux4sam/meta-atmel