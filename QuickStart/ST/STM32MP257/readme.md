# STM32MP257 AI Demo

This repository provides all the necessary documentation and scripts to set up and operate your STM32MP257 board with AI-based image classification and IoT capabilities using IoTConnect.

---

## Table of Contents

1. [Introduction to STM32MP257](readme.md#1-introduction-to-stm32mp257)
2. [Setting Up the STM32MP257 Board](readme.md#2-setting-up-the-stm32mp257-board)
3. [IoTConnect Configuration](readme.md#3-iotconnect-configuration)
4. [Image Processing Dashboard Setup](readme.md#4-image-processing-dashboard-setup)
5. [Lambda Functions and S3 Image Processing](#5-lambda-functions-and-s3-image-processing)
6. [Over-the-Air (OTA) Updates and Commands](#6-over-the-air-ota-updates-and-commands)
7. [Resources and Further Exploration](#7-resources-and-further-exploration)

---

### 1. Introduction to STM32MP257

The STM32MP257 board integrates advanced AI processing and IoT functionality, enabling image classification, object detection, and telemetry through IoTConnect. For an overview of the board’s capabilities and essential setup steps, see the [STM32MP257 Overview and Setup Guide](board-setup.md).

---

### 2. Setting Up the STM32MP257 Board

This section provides the essential steps to set up and configure the STM32MP257 board, including flashing the device with a preconfigured image and setting up network connectivity.

- [STM32MP257 Overview and Setup Guide](board-setup.md)

---

### 3. IoTConnect Configuration

To connect the STM32MP257 to IoTConnect, follow this guide for creating an IoTConnect account, setting up device templates, registering your device, and configuring the `config.json` file with necessary certificates and credentials.

- [IoTConnect Setup Guide](IoTConnect-setup.md)

---

### 4. Image Processing Dashboard Setup

Set up the Image Processing Dashboard to monitor and visualize AI classification results. The dashboard includes various widgets to display classification confidence, live data, and device status.

- [Dashboard Configuration Guide](STM - MP2 Image Classification_dashboard_export(2).json)

---

### 5. Lambda Functions and S3 Image Processing

This section details the AWS Lambda functions supporting automated image processing and storage in an S3 bucket, including retry logic and error handling.

- [AWS Lambda Image Processing Function](lambda-func-randompics.json)

---

### 6. Over-the-Air (OTA) Updates and Commands

Manage OTA updates for firmware and scripts, as well as device commands, enabling continuous deployment and control of STM32MP257 operations.

- [OTA Setup Guide](STM32MP-X-Linux-AI-OTA.md)
- [Command Template and Configuration](stm32mp2ai_template.JSON)

---

### 7. Resources and Further Exploration

Explore additional resources and examples to expand your STM32MP257 project.

- [STM32MP257 Evaluation Kit Documentation](https://wiki.st.com/stm32mpu/wiki/STM32MP25_Evaluation_boards_-_Starter_Package)
- [X-Linux-AI Expansion Package](https://wiki.stmicroelectronics.cn/stm32mpu/wiki/Category:X-LINUX-AI_expansion_package)
- [IoTConnect SDK and Examples](https://github.com/avnet-iotconnect/meta-iotconnect-docs/tree/main)
- [IoTConnect Platform & Services](https://www.iotconnect.io/)

---

### License

This repository is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.
