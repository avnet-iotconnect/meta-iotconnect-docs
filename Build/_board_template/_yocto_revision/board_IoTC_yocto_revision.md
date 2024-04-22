# BOARD IoTC YOCTO_REVISION Base Image Build Guide

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
mkdir XXX && cd $_
```

2. Use `repo` to get Yocto sources:
```bash
repo init -u XXX && \
repo sync    
```

3. Download the provided `Makefile` and `Dockerfile`:
```bash
wget https://raw.githubusercontent.com/avnet-iotconnect/meta-iotconnect-docs/main/Build/XXX/XXX/Makefile && \
wget https://raw.githubusercontent.com/avnet-iotconnect/meta-iotconnect-docs/main/Build/XXX/XXX/Dockerfile
```

4. Enter the docker environment:
```bash
make docker
```

5. Setup the environment:
```bash
XXX
```

6. Exit docker and return to the host:
```bash
exit
```

7. Build the image on the host:
```bash
make build
```
