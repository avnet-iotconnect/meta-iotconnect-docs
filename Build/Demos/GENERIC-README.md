# Generic IoT Connect Yocto Demo Build Guide

This is a generic guide on how to add the IoTConnect C and Python [Demos](https://github.com/avnet-iotconnect/meta-iotconnect-demos) to your existing Yocto build environment.
First you will need to add the [SDK meta-layer](../IoTC-SDK/GENERIC-README.md)

1. Find the directory with all your Yocto layer source files, this may be named `layers`, `sources` or otherwise. This will depend on how your Yocto project is configured.

2. `cd` into your Yocto layers directory.

3. Clone the SDK into your sources directory. Make sure you checkout the right version of the SDK for your Yocto version. This may be `kirkstone`, `dunfell`, or otherwise.
```bash
git clone git@github.com:avnet-iotconnect/meta-iotconnect-demos.git -b <YOCTO_VERSION_HERE>
```
4. Enter the `bitbake` environment, usually by `source <path-to-poky>/oe-init-build-env`

5. Add the SDK to bitbake (relative to your `/build/` folder):
```bash
bitbake-layers add-layer <path-to>/meta-iotconnect-demos
```
By default the meta layer adds both the C and Python Demo, you can select what you need by modifying `./meta-iotconnect-demos/conf/layer.conf`
