# Raspberry Pi IoTC Nanbield Base Image Build Guide

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
mkdir RaspberryPi_IoTC_nanbield && cd RaspberryPi_IoTC_nanbield
```

2. Clone the layer sources:
```bash
mkdir layers && \
cd layers && \
git clone -b nanbield git://git.yoctoproject.org/poky.git && \
git clone -b nanbield git://git.yoctoproject.org/meta-raspberrypi.git && \
git clone -b nanbield git://git.openembedded.org/meta-openembedded && \
cd ..
```

3. Download the provided `Makefile` and `Dockerfile`:
```bash
wget https://raw.githubusercontent.com/avnet-iotconnect/meta-iotconnect-docs/main/Build/RaspberryPi/nanbield/Makefile && \
wget https://raw.githubusercontent.com/avnet-iotconnect/meta-iotconnect-docs/main/Build/RaspberryPi/nanbield/Dockerfile
```

4. Enter the docker environment:
```bash
make env
```

5. Add the bitbake layers:
```bash
bitbake-layers add-layer ../meta-openembedded/meta-oe && \
bitbake-layers add-layer ../meta-openembedded/meta-python && \
bitbake-layers add-layer ../meta-openembedded/meta-multimedia && \
bitbake-layers add-layer ../meta-openembedded/meta-networking && \
bitbake-layers add-layer ../meta-raspberrypi
```

6. Return to the host from docker:
```bash
exit
```

7. List the supported target Raspberry Pis machines:
```bash
ls layers/meta-raspberrypi/conf/machine/*.conf
```
example output:
```
layers/meta-raspberrypi/conf/machine/raspberrypi-armv8.conf
layers/meta-raspberrypi/conf/machine/raspberrypi-cm.conf
layers/meta-raspberrypi/conf/machine/raspberrypi-cm3.conf
layers/meta-raspberrypi/conf/machine/raspberrypi.conf
layers/meta-raspberrypi/conf/machine/raspberrypi0-2w-64.conf
layers/meta-raspberrypi/conf/machine/raspberrypi0-2w.conf
layers/meta-raspberrypi/conf/machine/raspberrypi0-wifi.conf
layers/meta-raspberrypi/conf/machine/raspberrypi0.conf
layers/meta-raspberrypi/conf/machine/raspberrypi2.conf
layers/meta-raspberrypi/conf/machine/raspberrypi3-64.conf
layers/meta-raspberrypi/conf/machine/raspberrypi3.conf
layers/meta-raspberrypi/conf/machine/raspberrypi4-64.conf
layers/meta-raspberrypi/conf/machine/raspberrypi4.conf
layers/meta-raspberrypi/conf/machine/raspberrypi5.conf
```

8. Edit the target `MACHINE` configuration in `layers/build/conf/local.conf`. **ENSURE** the string matches the file names that has been previously listed. For example if you were targeting the Raspberry Pi 4 you can use `raspberrypi4` or `raspberrypi4-64`.
```
MACHINE ??= "raspberrypi4"
```

9. Accept the license agreement for synaptic:
```bash
echo "LICENSE_FLAGS_ACCEPTED = \"synaptics-killswitch\"" >> layers/build/conf/local.conf
```

10. Build the image:
```bash
make build
```

#### Note:
While not officially supported, it is likely that other Yocto versions are also supported as `poky` and `meta-raspberrypi` are well maintained. It is worth trying for other versions if your project requires it.
