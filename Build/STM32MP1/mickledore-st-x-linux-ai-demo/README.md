Usage

1. Build and flash the board.

2. Create a template on IOTConnect.

Authentication type: `x509`

It will need a `Data Frequency` of `0` To showcase the reactivity of the demo.

Two attributes also will need to be added to the template

`Local Name:` `object_detected`

`Data Type`: `STRING`

`Local Name:` `confidence`

`Data Type`: `INTEGER`

`Unit:` :`%`

2. Once the board is booted:

`/usr/iotc/local/config.json` will need to be filled out, with the x509 certificates saved in the `/usr/iotc/local/certs` folder.

The device attributes in the JSON are not required to be filled out.

3. Launch the IOTC application using
```bash
    ~/iot-application.sh
```

4. Launch the Python Tensor Flow Coco application via the GUI on the touchscreen.