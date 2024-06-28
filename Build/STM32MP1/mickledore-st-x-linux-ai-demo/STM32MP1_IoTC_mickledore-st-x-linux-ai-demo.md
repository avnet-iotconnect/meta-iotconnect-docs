# STM32MP1 IoTC Mickledore Base Image Build Guide
Tested on Ubuntu 22.04 (2024-04-19)

This will build a base Yocto image without IoTC for your board.

## Requirements
- Repo (from Google): https://android.googlesource.com/tools/repo
- Docker: 

    https://docs.docker.com/engine/install/ubuntu/
    
    https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user
- Git: `name` and `email` configured globally:

    `git config --global user.name "{YOUR_NAME_HERE}"`

    `git config --global user.email "{YOUR_EMAIL_HERE}"`
- STM32_Programmer_CLI: https://www.st.com/en/development-tools/stm32cubeprog.html

- USB Webcam

## Method
1. Create project directory and enter it:
```bash
mkdir STM32MP1_IoTC_mickledore && cd STM32MP1_IoTC_mickledore
```

2. Use `repo` to get Yocto sources:
```bash
repo init -u https://github.com/STMicroelectronics/oe-manifest.git -b refs/tags/openstlinux-6.1-yocto-mickledore-mp1-v24.03.13 && \
repo sync    
```

3. Download the provided `Makefile` and `Dockerfile`:
```bash
wget https://raw.githubusercontent.com/avnet-iotconnect/meta-iotconnect-docs/main/Build/STM32MP1/mickledore-st-x-linux-ai-demo/Makefile && \
wget https://raw.githubusercontent.com/avnet-iotconnect/meta-iotconnect-docs/main/Build/STM32MP1/mickledore-st-x-linux-ai-demo/Dockerfile
```

4. Enter the docker environment:
```bash
make docker
```

5. Setup the environment:
```bash
cd ..
DISTRO=openstlinux-weston
MACHINE=stm32mp1
EULA_stm32mp1=1
# Go through all of the EULA and accept everything
source layers/meta-st/scripts/envsetup.sh
```

6. Exit docker and return to the host:
```bash
exit
```

7. Clone the customized meta-st-x-linux-ai repo
```bash
cd layers
git clone git@github.com:akarnil/meta-st-x-linux-ai.git -b mickledore-iotc
cd -
```

8. Enter the docker environment:
```bash
make env
```

9. Add the layer using bitbake:
```bash
bitbake-layers add-layer ../layers/meta-st-x-linux-ai 
```

10. Exit docker and return to the host:
```bash
exit
```


11. Clone IOTC sources into your sources directory
```bash
cd layers
git clone git@github.com:avnet-iotconnect/meta-iotconnect.git -b mickledore
git clone git@github.com:avnet-iotconnect/meta-iotconnect-demos.git -b mickledore-st-x-linux-ai-demo
cd -
```

12. Enter the docker environment:
```bash
make env
```

13. Add the SDK layers using bitbake:
```bash
bitbake-layers add-layer ../layers/meta-iotconnect && \
bitbake-layers add-layer ../layers/meta-iotconnect-demos 
```

14. Exit docker and return to the host:
```bash
exit
```

15. Build the image on the host:
```bash
make build
```

### Flashing

1. Download and install [STM32_Programmer_CLI](https://www.st.com/en/development-tools/stm32cubeprog.html) if you haven't already 

2. Head to where you've installed programmer (f.e. `cd ~/STMicroelectronics/STM32Cube/STM32CubeProgrammer/`) and copy udev rules. You might need to restart `udev.service` after that. (`systemctl restart udev.service`)
```bash
cp Drivers/rules/* /etc/udev/rules.d/
```

3. Make sure boot DIP switches on the other side of the board are set correctly - both must be in OFF position.

4. Connect the USB-C cables ![picture](https://wiki.st.com/stm32mpu/nsfr_img_auth.php/5/53/STM32MP157x-DKx_flashing_configuration.png)

4. Flash the board, replace XXX with either 157 or 135 for your board
```bash
make flash target=XXX
```

5. After done flashing power off the board and flip both DIP switches to ON.