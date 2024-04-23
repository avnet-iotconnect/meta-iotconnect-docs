# Usage instructions

These instructions guide you through using the demos provided by IoTConnect.

After a board is flashed with the example image or compiled from source, and you have successfully booted the board and accessed the command line through a serial interface or ssh you can use the next steps to get you familiarized with the demo applications. 

The IoTConnect demos and all related data live in `/usr/iotc`, in that directory you will find `bin` and `local`.
Inside `bin` you will find two folders, each of these contain the executables for the C and Python Demos.
Inside `local` reside configuration jsons, certificates and scripts that are executed as commands on the device from the IoTConnect portal.

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