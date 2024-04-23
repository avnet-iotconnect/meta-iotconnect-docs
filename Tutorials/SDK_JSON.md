
# JSON Configs
Also in the `eg-private-repo-data` are sample JSON files, these are cross compatible with AWS and Azure. This aims to be the main configuration file for IoTC. This can be edited live on the device and the changes immediately reflected after restarting of the service.

The config json provides a quick and easy way to provide a user's executable with the requisite device credentials for any connection and a convenient method of mapping sensors to iotc device attributes. The demo source provided will match an `attribute.name` to a path on the user's host where the relevant sensor data resides. It also indicates to the demo what format to expect the data at the path to be in.

```json
{
    "sdk_ver": "2.1",
    
    // Unique ID of the device as used in the web console. This MUST match otherwise the handshake will fail.
    "duid": "",

    // Your unique CPID exactly as it shows in the Key Vault, this will authorize your devices to connect.
    "cpid": "",

    // Your environment exactly as it shows in the Key Vault.
    "env": "",

    // This is the root CA cert used for connecting your device, it is likely to be AWS Root CA 1 or a custom CA you have registered on the web console.
    "iotc_server_cert": "/etc/ssl/certs/...",

    // SDK Identities -> Language: Python **, Version: 1.0' from portal's Key Vault, needed for Python SDK
    "sdk_id": "",

    // The discovery URL for starting the IoTC login process. It WILL be different depending on if you are using AWS or Azure.
    "discovery_url": "",

    // Use IOTC_CT_AZURE or IOTC_CT_AWS to select connection type
    "connection_type": "IOTC_CT_AZURE",
    
    // This is the auth method used to connect the device.
    "auth": {
        "auth_type": "IOTC_AT_X509",
            "params": {
                // This is the path on the device AFTER it's built and running on the device. Ensure that these files exist after building and are valid certs.
                // If you are using generated keys goto: https://awspoc.iotconnect.io/device/1/{THING_NAME_HERE} > Connection Info > Click on the icon with a certificate and download arrow.
                // Check the types of the certs you have just download and ensure they are in the correct format, as well as if their locations are as specified below.
                "client_key": "/usr/iotc-c/local/certs/device.key",
                "client_cert": "/usr/iotc-c/local/certs/DeviceCertificate.pem"
        }
    },
    // This contains specific command and telemetry to be send to IoTC.
    "device": {
        "commands_list_path": "/usr/iotc-c/app/scripts",
        "attributes": [
            {
                "name": "example",
                "private_data": "/tmp/example",
                "private_data_type": "ascii"
            }
        ]
    }
}
```

The sample JSON contains key value pairs where the value contains directions to what your individual value will be. E.g:
```json
{
    "sdk_ver": "2.1",
    "duid": "Your Device's name in https://avnet.iotconnect.io/device/1",
...
}
```
Would become: 
```json
{
    "sdk_ver": "2.1",
    "duid": "myDemoDevice",
...
}
```
