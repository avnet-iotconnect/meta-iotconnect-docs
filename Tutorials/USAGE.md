# Usage instructions

These instructions guide you through using the demos provided by IoTConnect.

You will first need a board that has been flash with an [example image](../QuickStart/README.md) or a [compiled image](../Build/README.md). You will also need access to the board either via a serial interface or ssh.

The IoTConnect demos and all related data live in `/usr/iotc`, in that directory you will find `bin` and `local`.
Inside `bin` you will find two folders, each of these contain the executables for the C and Python Demos.
Inside `local` reside configuration jsons, certificates, and scripts that are executed as commands on the device from the IoTConnect portal.

```
/usr/iotc/
├── bin/
│   ├── iotc-c-sdk/
│   │   └── iotc-c-demo
│   └── iotc-python-sdk/
│       └── iotc-python-demo.py
└── local/
    ├── certs/
    │   └── YOUR_CERTS.pem
    ├── scripts/
    │   └── YOUR_SCRIPTS.sh
    └── config.json
```

You will need to fill out the `config.json` provided when provisioning the device on IoTConnect.
There is a further in-depth guide on filling out the `config.json` [here](SDK_JSON.md).

Any commands you would like your device to execute have to exist as bash scripts in `/usr/iotc/local/scripts/`.
There is a further in-depth guide on creating bash scripts [here](SCRIPTS.md).

Once everything is set up, you can execute either the Python or C SDK implementation of the demo to send telemetry configured from `config.json` and execute commands this is done below.

## C Demo
```bash
/usr/iotc/bin/iotc-c-sdk/iotc-c-demo /usr/iotc/local/config.json
```

## Python Demo
```bash
python3 /usr/iotc/bin/iotc-python-sdk/iotc-python-demo.py /usr/iotc/local/config.json
```
