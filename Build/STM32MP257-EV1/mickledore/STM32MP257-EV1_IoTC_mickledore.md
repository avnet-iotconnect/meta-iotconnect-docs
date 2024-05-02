# STM32MP257 IoTC Mickledore Base Image Build Guide
Tested on Ubuntu 22.04 (2024-04-19)

The STM32MP2 is currently in BETA, we have tested IoTConnect support and the IoTC integration does not have any issues.
However things may change with the build instructions for building the Yocto distribution for the board so they may be unexpected issues.

You will need to follow the guide on the [ST Wiki](https://wiki.st.com/stm32mp25-beta-v5/wiki/STM32MPU_Distribution_Package)

The repository you will need to clone requires access and authentication for when pulling with the repo tool.

- A recommendation is to create a [Personal Access Token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-personal-access-token-classic)
and then using [Credential Store](https://www.shellhacks.com/git-config-username-password-store-credentials/) with git.
Otherwise cloning may fail silently.

Follow from Step 5 of the guide, after Step 6 you can add the [SDK](../../IoTC-SDK/GENERIC-README.md) and the [demos](../../Demos/GENERIC-README.md).

And then re-run the build process from Step 6.

For flashing the board, the SD card process is recommended, confirm the [boot switches](https://wiki.st.com/stm32mp25-beta-v5/wiki/STM32MP257x-EV1_-_hardware_description#Boot_related_switches)

and execute the below to construct an SD card image.
```bash
### assuming you are in the build directory named /build-openstlinuxweston-stm32mp25/
cd tmp-glibc/deploy/images/stm32mp25/scripts && \
./create_sdcard_from_flashlayout.sh ../flashlayout_st-ima
ge-weston/optee/FlashLayout_sdcard_stm32mp257f-ev1-ca35tdcid-ostl-m33-examples-optee.tsv
```

To flash you will to insert the SD card and call
```bash
sudo dd if=../flashlayout_st-image-weston/optee/../../FlashLayout_sdcard_stm32mp257f-ev1-ca35tdcid-ostl-m33-examples-optee.raw of=/dev/mmcblk0 bs=8M conv=fdatasync status=progress
```