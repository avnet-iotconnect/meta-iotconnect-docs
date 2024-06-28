# AI DEMO Guide 

1. [Build and flash the board](./STM32MP1_IoTC_mickledore-st-x-linux-ai-demo.md)

2. Create a template on IOTConnect.

```
Authentication type: `x509`

It will need a `Data Frequency` of `0` To showcase the reactivity of the demo (this will require a support ticket to change it.)
```

Two attributes also will need to be added to the template

```
`Local Name:` `object_detected`

`Data Type`: `STRING`

`Local Name:` `confidence`

`Data Type`: `INTEGER`

`Unit:` :`%`
```

3. Connect a USB webcam, Ethernet to the Board, and micro USB to the ST-Link port.

4. Power up the board and connect to the board using a serial terminal.

5. Once the board is booted, you will need to make some changes:

`/usr/iotc/local/config.json` will need to be filled out.
with the x509 certificates saved in the `/usr/iotc/local/certs` folder ( you can transfer them with `scp` if needed)

The device attributes in the JSON are not required to be filled out.

5. Launch the IOTC application using
```bash
    ~/iot-application.sh
```

6. Use the touchscreen to navigate to the `TensorFlowLite Object Detection COCO SSD v1` icon and execute the program (you may need to tap on next to flick to the next page to find it.)

7. On the terminal screen you will see IOTC connecting, when an object gets detected by the camera that will also print messages on the terminal of data being uploaded.