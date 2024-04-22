# MaaXBoard IoTC Kirkstone Base Image Build Guide

This will build a base Yocto image without IoTC for your board.

After you have built this you will need to add the [SDK](../../IoTC-SDK/README.md) and the [demos](../../Demos/README.md).

## Requirements
- Repo (from Google): https://android.googlesource.com/tools/repo
- Docker: 

    https://docs.docker.com/engine/install/ubuntu/
    
    https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user
- Git: `name` and `email` configured globally:

    `git config --global user.name "{YOUR_NAME_HERE}"`

    `git config --global user.email "{YOUR_EMAIL_HERE}"`

-...

## Method
1. Create project directory and enter it:
```bash
mkdir imx-yocto-bsp  && cd $_
```

2. Use `repo` to get Yocto sources:
```bash
repo init -u https://github.com/nxp-imx/imx-manifest  -b imx-linux-kirkstone -m imx-5.15.71-2.2.2.xml && repo sync && \
git clone https://github.com/Avnet/meta-maaxboard.git -b kirkstone sources/meta-maaxboard  
```

3. Download the provided `Makefile` and `Dockerfile`:
```bash
wget https://raw.githubusercontent.com/avnet-iotconnect/meta-iotconnect-docs/main/Build/MaaXBoard/kirkstone/Makefile && \
wget https://raw.githubusercontent.com/avnet-iotconnect/meta-iotconnect-docs/main/Build/MaaXBoard/kirkstone/Dockerfile
```

4. Enter the docker environment:
```bash
make docker
```

5. Setup the environment:
```bash
MACHINE=maaxboard source sources/meta-maaxboard/tools/maaxboard-setup.sh -b maaxboard/build
```

6. Exit docker and return to the host:
```bash
exit
```

7. Build the image on the host:
```bash
make build
```
### Extras

Instructions for using a serial adapter and UART are found [here](https://www.hackster.io/monica/getting-started-with-maaxboard-headless-setup-24102b)  

If there are any problems during building then try:
```bash
rm -rf ./maaxboard/build/tmp
make build
```