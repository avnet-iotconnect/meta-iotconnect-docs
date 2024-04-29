# Generic IoT Connect Yocto SDK Build Guide

This is a generic guide on how to add the IoTConnect C and Python SDKs to your existing Yocto build environment.

1. Find the directory with all your Yocto layer source files, this may be named `layers`, `sources` or otherwise. This will depend on how your Yocto project is configured.

2. `cd` into your Yocto layers directory.

3. Clone the SDK into your sources directory. Make sure you checkout the right version of the SDK for your Yocto version. This may be `kirkstone`, `dunfell`, or otherwise.
```bash
git clone git@github.com:avnet-iotconnect/meta-iotconnect.git -b <YOCTO_VERSION_HERE>
```
4. Enter the `bitbake` environment, usually by `source <path-to-poky>/oe-init-build-env`

5. Add the SDK to bitbake (relative to your `/build/` folder):
```bash
bitbake-layers add-layer <path-to>/meta-iotconnect
```
This provides a recipe for the C SDK which you can add to your own recipes through `RDEPENDS_${PN} += " iotc-c-sdk"`
as well as the Python SDK through `RDEPENDS_${PN} += " python3-iotconnect-sdk"`
