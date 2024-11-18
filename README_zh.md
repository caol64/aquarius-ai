<div align="center">
    <img alt = "logo" src="Data/256-mac.png" />
</div>

# AquariusAI

[English](README.md) | 中文

`AquariusAI`致力于研究在苹果设备（包括 Mac、iPhone 和 iPad）上独立运行本地大型模型的能力。目标是可以将`hugging face`上下载的模型直接（或通过转换后）运行在设备上，并且充分利用设备固有算力（CPU、GPU 和 NPU）。

## 概念

- CoreML

> Core ML 是苹果公司的原生机器学习框架，也是它使用的文件格式的名称。在您将模型从（例如）PyTorch 转换为 Core ML 之后，您可以在 Swift 应用中使用它。Core ML 框架会自动选择最佳的硬件来运行您的模型：CPU、GPU 或一个称为神经引擎的专用张量单元。根据您的系统特性和模型细节，也可以组合使用这些计算单元中的多个。

- Exporting a model to Core ML

## 特性

### 文本生成

使用[swift-transformers](https://github.com/huggingface/swift-transformers)加载和运行`CoreML`模型。

### 图像生成
使用[Core ML Stable Diffusion](https://github.com/apple/ml-stable-diffusion)加载和运行`CoreML`模型。

### 不断增加中...

## 最低系统要求

- macOS 14.0 Sonoma

## APP截屏

![screenshot](Data/1.webp)
![screenshot](Data/2.webp)
