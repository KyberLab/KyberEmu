# KyberEmu

KyberEmu 是一个基于 QEMU 的虚拟化仿真平台， 需配合KyberLab的其他项目一起使用。

## 功能特性

- **虚拟化支持**：支持基于 QEMU 的虚拟开发板
- **虚拟网络**：支持 NAT 网络配置和虚拟网桥
- **终端管理**：支持 tmux 和独立终端模式
- **图形界面**：可选的图形显示支持

## 环境要求

- Linux 操作系统（推荐 Ubuntu 20.04+）
- QEMU 6.0 或更高版本
- Make 工具
- tmux（可选，用于终端管理）

## 项目结构

```
KyberEmu/
├── Makefile              # 主 Makefile
├── LICENSE               # Apache 2.0 许可证
├── README.md             # 英文文档
├── README_CN.md          # 中文文档
├── qemu/                 # QEMU 相关配置
│   ├── Graphic.mk        # 图形配置
│   ├── Develop.mk        # 开发配置
│   ├── Terminal.mk       # 终端配置
│   ├── Network.mk        # 网络配置
│   └── Storage.mk        # 存储配置
├── virt/                 # 虚拟化配置
│   ├── Network.mk        # 虚拟网络配置
│   └── Image.mk          # 镜像管理
└── scripts/              # 辅助脚本
    ├── emu-ifup.sh       # 网卡启动脚本
    ├── emu-ifdown.sh     # 网卡关闭脚本
    ├── virt-net.sh       # 虚拟网络脚本
    └── emu-term.py       # 终端管理脚本
```

## 许可证

本项目采用 Apache License 2.0 许可证，详见 [LICENSE](LICENSE) 文件。

## 贡献指南

欢迎提交 Issue 和 Pull Request。在提交代码前，请确保：

1. 代码符合项目编码规范
2. 所有测试通过
3. 提交信息清晰明确

## 联系方式

- 项目主页：<repository-url>
- 问题反馈：[Issues](<repository-url>/issues)

## 版权信息

Copyright (c) 2025-2026, Kyber Development Team, all right reserved.
