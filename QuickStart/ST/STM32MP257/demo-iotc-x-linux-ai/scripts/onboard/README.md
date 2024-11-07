Provided are two folders and the installer script `install.sh`
contents inside folder `application` are used to replace contents inside `/usr/iotc/app`
contents inside folder `local_data`  are used to replace contents inside `/usr/iotc/local`

The folder structure is as follows
```bash
ota-payload-template/
├── install.sh
│
├── application
│   ├── model
│   └── scripts
│
├── local_data
│   └── certs
│
└── README
```

`install.sh` contains the logic for installing the OTA update, changing it may break the OTA procedure, excluding it will definitely not execute OTA

Placing files in specific directories correspond to where they will be installed in the application
For example putting an new `.sh` command script inside `application/scripts` would install a new command to the command

Content inside `application` and `local_data` will get appended to the installed application, to update a file inside the application, include the updated version using the same filename and path as the original that was installed to the device.

If the OTA does not have any content ending in `.py` or `.json` then the update would be reboot-less, for example an OTA that just adds new scripts or updates them would not cause an application restart.

Here is an example payload, below will be explanations of what the payload would do
```bash
ota-payload-template/
├── application
│   ├── model
│   ├── scripts
│   │   └── get_mem_usage.sh
│   └── telemetry_demo.py
├── install.sh
├── local_data
│   ├── certs
│   │   └── device.key
│   └── config.json
└── README
```

`application/telemetry_demo.py` would update the main application
`application/model/` is empty and would not introduce any changes
`application/scripts/get_mem_usage.sh` would add a new script to be used on the device
`local_data/config.json` would update the device config.
`local_data/certs/device.key` would update the X509 self signed certificate's device key.

To construct an OTA update, make a copy of `ota-payload-template` and add the payload contents
once complete, compress the folder you have copied and made changes to

Enter the folder and execute
`./construct_payload.sh`

When creating an OTA update upload `ota-payload.tar.gz` as the only file.