# IoT Connect Demo Build Guide

Ensure you first have built the [base image](../README.md) for your board.

You will also need the [SDK](../IoTC-SDK/README.md) installed.

1. Find the directory with all your Yocto layer source files, this may be named `layers`, `sources` or otherwise. This will depend on how your Yocto project is configured.

2. `cd` into your Yocto layers directory.

3. Clone the SDK into your sources directory. Make sure you checkout the right version of the SDK for your Yocto version. This may be `kirkstone`, `dunfell`, or otherwise.
```bash
git clone git@github.com:avnet-iotconnect/meta-iotconnect-demos.git -b {YOCTO_VERSION}
```

4. Return to the top level with the `Makefile` and enter the docker environment:
```bash
cd ..
make env
```

5. Add the SDK to bitbake:
```bash
bitbake-layers add-layer ../path/to/meta-iotconnect-demos
```

6. Exit docker to the host:
```bash
exit
```

7. You should now be back in the root project directory with the `Makefile` on the host where you can build the project:
```bash
make build
```


## Troubleshooting:

1. If you are having issues with the demos not appearing, it may be worth a try replacing `IMAGE_INSTALL` with `CORE_IMAGE_EXTRA_INSTALL` in `meta-iotconnect-demos/conf/layer.conf`.
2. If you are having connection issues try `ping 1.1.1.1` to test your network connection. Then try `ping google.com` to see if your DNS works. If you are able to get network but no DNS you may need to install a DNS resolver such as systemd-resolved.
3. If your Yocto image fails to build you can modify the `Makefile` to change `bitbake` to `bitbake -k`, by adding `-k` bitbake will continue even on failure. This sometimes is able to resolve a failing build. Another thing you can try is removing systemd from your builds. This has been observed to fail on some platforms such as the RZ.
