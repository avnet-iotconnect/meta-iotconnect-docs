# {BOARD_NAME} IoTC {YOCTO_VERSION} Base Image Build Guide

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
- ...

## Method
1. Create project directory and enter it:
```bash
mkdir {BOARD_NAME}_IoTC_{YOCTO_VERSION} && cd {BOARD_NAME}_IoTC_{YOCTO_VERSION}
```

2. Use `repo` to get Yocto sources:
```bash
repo init -u {REPO_URL} && \
repo sync    
```

3. Download the provided `Makefile` and `Dockerfile`:
```bash
wget https://raw.githubusercontent.com/avnet-iotconnect/meta-iotconnect-docs/main/Build/{BOARD_NAME}/{YOCTO_VERSION}/Makefile && \
wget https://raw.githubusercontent.com/avnet-iotconnect/meta-iotconnect-docs/main/Build/{BOARD_NAME}/{YOCTO_VERSION}/Dockerfile
```

5. Setup the environment:
```bash
XXX
```

7. Return to the top level and build the image:
```bash
cd ..
make build
```
