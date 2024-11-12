# STM32MP257 AI Demo

This repository provides all the necessary documentation and scripts to set up and operate your STM32MP257 board with AI-based image classification and IoT capabilities using IoTConnect.

---

## Table of Contents

1. [Introduction to STM32MP257](readme.md#1-introduction-to-stm32mp257)
2. [Setting Up the STM32MP257 Board](readme.md#2-setting-up-the-stm32mp257-board)
3. [IoTConnect Configuration](readme.md#3-iotconnect-configuration)
4. [Running the Sample Dashboard](readme.md#4-running-the-sample-dashboard)
5. [Lambda Functions and S3 Image Server](readme.md#5-lambda-functions-and-s3-image-server)
6. [Over-the-Air (OTA) Updates and Commands](readme.md#6-over-the-air-ota-updates-and-commands)
7. [Resources and Further Exploration](readme.md#7-resources-and-further-exploration)

---

### 1. Introduction to STM32MP257 Discovery Kit

The **STM32MP257F-DK Discovery Kit** is a comprehensive development platform designed to showcase the advanced features of the STM32MP257 microprocessor, particularly its edge AI capabilities. This microprocessor integrates dual Arm® Cortex®-A35 cores operating at up to 1.5 GHz and a Cortex®-M33 core at 400 MHz, facilitating the development of applications that leverage both high-performance and real-time processing.

#### Key AI Features

- **Neural Processing Unit (NPU)**: The STM32MP257 includes an NPU capable of delivering up to 1.35 Tera Operations Per Second (TOPS), enabling efficient execution of complex neural network models directly on the device. [Read more on ST’s blog](https://blog.st.com/stm32mp25/).

- **Graphics Processing Unit (GPU)**: Equipped with a 3D GPU, the microprocessor supports advanced graphics rendering, facilitating the development of sophisticated user interfaces and graphics-intensive applications. [More details on ST](https://www.st.com/en/microcontrollers-microprocessors/stm32mp257.html).

- **AI Development Ecosystem**: The kit is compatible with the ST Edge AI Developer Cloud, allowing developers to test and deploy AI models using tools like TensorFlowLite and ONNX. This ecosystem streamlines the process of integrating AI functionalities into applications.

#### Additional Resources

- **Product Page**: Detailed information about the STM32MP257F-DK Discovery kit, including specifications and ordering options, is available on the [STMicroelectronics website](https://www.st.com/en/evaluation-tools/stm32mp257f-dk.html).

- **Software Support**: Comprehensive software support, including distributions and development tools for the STM32MP257F-DK, can be found on the [STMicroelectronics Wiki](https://wiki.st.com/stm32mpu/wiki/STM32MP257x-DKx_-_software_distributions).

---

### 2. Setting Up the STM32MP257 Board

This section provides the essential steps to set up and configure the STM32MP257 board, including flashing the device with a preconfigured image and setting up network connectivity.

- [STM32MP257 Overview and Setup Guide](board-setup.md)

---

### 3. IoTConnect Configuration

To connect the STM32MP257 to IoTConnect, follow this guide for creating an IoTConnect account, setting up device templates, registering your device, and configuring the `config.json` file with necessary certificates and credentials.

- [IoTConnect Setup Guide](IoTConnect-setup.md)

---

### 4. Running the Sample Dashboard

Follow this guide to configure the STM32MP257 Image Processing Dashboard, including widgets for classification results, confidence levels, and historical logs.

- [STM32MP257 Classification Dashboard](running-the-sample-dashboard.md)

---

### 5. Lambda Functions and S3 Image Server

This section details the AWS Lambda functions supporting automated image processing and storage in an S3 bucket, including retry logic and error handling.

- [AWS Lambda Image Server](demo-iotc-x-linux-ai/S3-image-server/README.md)

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
