## Build Instructions
Tested on Ubuntu 22.04 (2024-04-19)

This will build a base Yocto image for your board.

# Requirements
- Repo (from Google): https://android.googlesource.com/tools/repo
- Docker: https://docs.docker.com/engine/install/ubuntu/ + https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user
- Git: `name` and `email` configured globally:
`git config --global user.name "{YOUR_NAME_HERE}"`
`git config --global user.email "{YOUR_EMAIL_HERE}"`
- STM32_Programmer_CLI: https://www.st.com/en/development-tools/stm32cubeprog.html

# Method
1. Create project directory and enter it
```bash
mkdir STM32MP157_IoTC_kirkstone && cd STM32MP157_IoTC_kirkstone
```

2. Use repo tool to get the yocto sources
```bash
repo init -u https://github.com/STMicroelectronics/oe-manifest.git -b refs/tags/openstlinux-5.15-yocto-kirkstone-mp1-v23.07.26 && \
repo sync    
```

3. Download provided Makefile and Dockerfile to project directory:
```bash
wget https://raw.githubusercontent.com/ylin-witekio/meta-iotconnect-docs/STM32MP157/kirkstone/Makefile && \
wget https://raw.githubusercontent.com/ylin-witekio/meta-iotconnect-docs/STM32MP157/kirkstone/Dockerfile
```

4. Enter the docker environment:
```bash
make docker
```

5. Setup the environment:
```bash
DISTRO=openstlinux-weston
MACHINE=stm32mp1
# go through all of the EULA and accept everything
source layers/meta-st/scripts/envsetup.sh
```

6. Exit the docker image and return to the host:
```bash
exit
```

7. Build the image on the host
```bash
make build
```

### Extras

1. To flash
```bash
make flash
```
