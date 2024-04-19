# IoT Connect Demo Build Guide

Ensure you first have built the [base image](./README.md) for your board.

You will also need the [SDK](../IoTC-SDK/README.md) installed.

1. Find the directory with all your Yocto layer source files, this may be named `layers`, `sources` or otherwise. This will depend on how your Yocto project is configured.

2. `cd` into your Yocto layers directory.

3. Clone the SDK into your sources directory. Make sure you checkout the right version of the SDK for your Yocto version. This may be `kirkstone`, `dunfell`, or otherwise.
```bash
git clone git@github.com:avnet-iotconnect/meta-iotconnect-demos.git -b {YOCTO_VERSION_HERE}
```

4. Go back to the top level of your project where the `Makefile` exists, in most cases it should be just:
```bash
cd ..
```

5. Enter the docker environment:
```bash
make env
```

6. Add the SDK to bitbake:
```bash
bitbake-layers add-layer ../path/to/meta-iotconnect-demos
```

7. Exit docker to the host:
```bash
exit
```

8. You should now be back in the root project directory with the `Makefile` on the host where you can build the project:
```bash
make build
```
