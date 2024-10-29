# STM32MP257 AI and IoT Demo Repository

Welcome to the STM32MP257 AI and IoT Demo repository. This repository is designed to guide you through setting up and running the STM32MP257 with AI-based image classification and IoT capabilities. Follow the instructions below to get started and explore the advanced functionalities available.

---

## Table of Contents

1. [Introduction to STM32MP257](#introduction-to-stm32mp257)
2. [Setting Up the STM32MP257 AI Demo](#setting-up-the-stm32mp257-ai-demo)
3. [Image Processing Dashboard Setup](#image-processing-dashboard-setup)
4. [Lambda Functions and S3 Image Processing](#lambda-functions-and-s3-image-processing)
5. [Over-the-Air (OTA) Updates and Commands](#over-the-air-ota-updates-and-commands)
6. [Resources and Further Exploration](#resources-and-further-exploration)

---

### 1. Introduction to STM32MP257

Learn more about the STM32MP257’s capabilities, including AI processing and IoT readiness. Get started with the evaluation kit and essential configuration tools for STM32MP257 development.

- [STM32MP257 Overview and Setup Guide](../../STM32MP257.md)

### 2. Setting Up the STM32MP257 AI Demo

This section provides a walkthrough of setting up the STM32MP257 AI demo. It includes firmware installation steps and guides for executing demo scripts. Requirements for the demo include connectivity to the IoTConnect platform and OTA update configurations.

- [AI Demo Installation and Configuration](stm32mp-ai-demo.md)
- [X-Linux-AI OTA Setup Guide](STM32MP-X-Linux-AI-OTA.md)

### 3. Image Processing Dashboard Setup

Set up and navigate the Image Processing Dashboard to monitor classification confidence, view processed images, and check application versioning. This dashboard offers real-time insights and configuration options for image transformations and telemetry.

- [Dashboard Export and Configuration](STM - MP2 Image Classification_dashboard_export(2).json)

### 4. Lambda Functions and S3 Image Processing

This section details the AWS Lambda functions that support automated image processing in S3, including:
- Image selection, confidence check, archival, and metadata management.
- Retry logic and error handling for robust image processing.

- [Lambda Function for Image Processing](lambda-func-randompics.json)

### 5. Over-the-Air (OTA) Updates and Commands

Manage OTA updates and device commands for continuous deployment and control of STM32MP257 operations. This includes pushing AI model updates, setting thresholds, and adjusting device configurations remotely.

- [Template for Commands and Attributes](stm32mp2ai_template.JSON)

### 6. Resources and Further Exploration

Explore more with direct links to additional resources, tools, and examples for the STM32MP257 and IoTConnect platform.

- [STM32MP257 Evaluation Kit](https://wiki.st.com/stm32mpu/wiki/STM32MP25_Evaluation_boards_-_Starter_Package)
- [X-Linux-AI Expansion Package](https://wiki.stmicroelectronics.cn/stm32mpu/wiki/Category:X-LINUX-AI_expansion_package)
- [IoTConnect SDK and Examples](https://github.com/avnet-iotconnect/meta-iotconnect-docs/tree/main)
- [IoTConnect Platform & Services](https://www.iotconnect.io/)

---

### Contributing

We welcome contributions! Please read our [Contributing Guidelines](CONTRIBUTING.md) for more information.

### License

This repository is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

---

Happy exploring! If you have questions, open an issue or reach out through our community support channels.
