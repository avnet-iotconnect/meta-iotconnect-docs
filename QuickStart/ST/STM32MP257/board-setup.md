# STM32MP257 Quick Start: Board Setup

This guide provides the essential steps to set up your STM32MP257 evaluation kit using the preconfigured image. For more detailed hardware specifications, please refer to the official [UM3359 Evaluation Board Manual](um3359-evaluation-board-with-stm32mp257f-mpu-stmicroelectronics.pdf). This guide is intended to get your board operational with the AI demo and IoTConnect integration.

---

## Table of Contents

1. [Overview](#overview)
2. [Requirements](#requirements)
3. [Hardware Setup](#hardware-setup)
4. [Flashing the Device](#flashing-the-device)
5. [Basic Network Configuration](#basic-network-configuration)
6. [Next Steps](#next-steps)

---

### 1. Overview

The STM32MP257 board supports AI and IoT applications, enabling image classification, object detection, and telemetry. This guide outlines the steps to set up your board using a specific image for quick deployment.

---

### 2. Requirements

- **Preconfigured Image**: Download the preconfigured image from [IoTConnect SDK Images](https://iotconnect-sdk-images.s3.amazonaws.com/MPU/mickledore/st/stm32mp257x-ev1/stm32mp25-eval-image.tar.gz).
- **STM32CubeProgrammer**: Required for flashing the image to your STM32MP257 board. [Download STM32CubeProgrammer](https://www.st.com/en/development-tools/stm32cubeprog.html).
- **Hardware**:
  - STM32MP257 evaluation board
  - Power supply and cables (USB, Ethernet)
  - MicroSD card (minimum 4GB) or eMMC storage

---

### 3. Hardware Setup

1. **Prepare the Board**:
   - Connect the STM32MP257 to your development PC via USB or Ethernet.
   - Power on the board and connect any necessary peripherals as outlined in Section 2 of the [UM3359 Manual](um3359-evaluation-board-with-stm32mp257f-mpu-stmicroelectronics.pdf).

2. **Connect Storage**:
   - Insert a MicroSD card if flashing to SD memory.
   - Ensure all connections are secure before proceeding.

---

### 4. Flashing the Device

1. **Download and Prepare Image**:
   - Download the image from [stm32mp25-eval-image.tar.gz](https://iotconnect-sdk-images.s3.amazonaws.com/MPU/mickledore/st/stm32mp257x-ev1/stm32mp25-eval-image.tar.gz).
   - Extract the image file locally on your development machine.

2. **Use STM32CubeProgrammer**:
   - Install and open STM32CubeProgrammer, selecting the STM32MP257 as the target device.
   - Connect via USB or UART as specified in the UM3359 manual.
   - Load the extracted image and flash it to either eMMC or the SD card.

---

### 5. Basic Network Configuration

After flashing, proceed with network setup for IoTConnect integration and OTA updates.

- **Ethernet/WiFi Setup**:
  - Connect the STM32MP257 to your network. Use Ethernet for a reliable connection, or WiFi if supported.
  - Verify the network connection for stable communication.

- **IoTConnect Initial Setup**:
  - To enable IoTConnect functionality, configure the connection as described in the [AI Demo Setup Guide](stm32mp-ai-demo.md).

---

### 6. Next Steps

With your STM32MP257 evaluation board set up, explore the following resources for advanced configurations:

- **OTA Updates**:
  - Set up and manage OTA firmware and script updates as described in [STM32MP-X-Linux-AI-OTA.md](STM32MP-X-Linux-AI-OTA.md).

- **Image Processing and AI Dashboard**:
  - Follow the steps in [Dashboard Export Guide](STM - MP2 Image Classification_dashboard_export(2).json) to configure and monitor AI tasks.

- **AWS Lambda Integration**:
  - Automate image processing through AWS Lambda as detailed in [lambda-func-randompics.json](lambda-func-randompics.json).

For detailed hardware specs, peripheral support, and troubleshooting, refer to the [UM3359 Evaluation Board Manual](um3359-evaluation-board-with-stm32mp257f-mpu-stmicroelectronics.pdf).

---

This quick start guide should help you get your STM32MP257 board up and running. For additional setup help, please consult the main [README.md](README.md).
