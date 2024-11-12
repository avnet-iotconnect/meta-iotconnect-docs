# STM32MP257 Classification Dashboard - README

![STM32MP257 Classification Dashboard](https://github.com/avnet-iotconnect/meta-iotconnect-docs/blob/main/QuickStart/ST/STM32MP257/media/dashboard_stm32mp2_classification_v2.png)

## Overview
This dashboard provides users with access to the STM32MP257’s AI image classification capabilities, displaying real-time and historical classification data. With a unique Device ID (UID) and Company ID (CPID) from the IoTConnect account, users can securely access their specific device data within a shared test environment, avoiding cross-device data viewing.

## Purpose of UID and CPID
- **UID (Device ID)**: Identifies each device on IoTConnect, isolating data per device.
- **CPID (Company ID)**: Ensures secure access to each user's IoTConnect account data in shared setups.

By using your UID and CPID, you can ensure only your device’s classification data is displayed.

## How to Use the Dashboard

1. **Start IoTConnect on Your Device** (if not already running):
   - If IoTConnect is not running, SSH into the device or open the debug terminal, then execute:
     ```bash
     ~/iotc-application.sh
     ```
   - Ensure the IoTConnect platform is active before proceeding to the dashboard.

2. **Locate and Copy Your Device ID**:
   - Your UID (Device ID), concatenated with the CPID, is shown in the **Device ID** widget on the dashboard.
   - This combined ID provides a unique identifier for accessing your specific logs in the **STM32MP257 Classification** widget, isolating your device data from others.

3. **Enable the AI Image Classification Model**:
   - On the dashboard, locate the **AI Model on/off** section.
   - Click the command widget button beneath the **AI Model on/off** label to start the AI image classification model on your board.
   
4. **Access Classification Results**:
   - Go to the **STM32MP257 Classification** widget on the dashboard.
   - Paste your unique identifier (from the Device ID widget) into this widget to view both real-time and historical classification data for your device.
   - Once entered, the widget displays your device’s classifications, confidence levels, and timestamps.

5. **Understanding Displayed Information**:
   - **Classification Results**: Shows the latest classification result from the STM32MP257.
   - **Confidence Gauge**: Displays confidence levels for the classification result.
   - **Historical Logs**: View previous classifications by time for device performance tracking.

6. **Additional Dashboard Widgets**:
   - The **STM32MP257 Confidence** gauge visualizes confidence levels for the latest classification.
   - **Historical Results** provides logs of past classifications for further analysis.

7. **Embedded Image Source from S3**:
   - The **Image Source** widget links to the image in the AWS S3 bucket currently under classification, allowing you to visually verify data accuracy.

## Example Workflow
1. **Start IoTConnect** if needed, by executing `~/iotc-application.sh`.
2. **Copy UID from Device ID Widget**: This is your unique device identifier.
3. **Enable AI Classification Model**: Click the button in **AI Model on/off** to start classification.
4. **Enter UID in Classification Widget**: Paste it into **STM32MP257 Classification** to view your device’s data.
5. **Analyze Results**: Explore classification, confidence metrics, and historical logs specific to your device.
