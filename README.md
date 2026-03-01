# KyberEmu

KyberEmu is a QEMU-based virtualization emulation platform, which needs to be used with other projects in KyberLab.

[中文文档](README_CN.md)

## Features

- **Virtualization Support**: Supports QEMU-based virtual development boards
- **Virtual Networking**: Support for NAT network configuration and virtual bridges
- **Terminal Management**: Support for tmux and standalone terminal modes
- **Graphics Interface**: Optional graphical display support

## Requirements

- Linux operating system (Ubuntu 20.04+ recommended)
- QEMU 6.0 or higher
- Make tool
- tmux (optional, for terminal management)

## Project Structure

```
KyberEmu/
├── Makefile              # Main Makefile
├── LICENSE               # Apache 2.0 License
├── README.md             # English documentation
├── README_CN.md          # Chinese documentation
├── qemu/                 # QEMU related configurations
│   ├── Graphic.mk        # Graphics configuration
│   ├── Develop.mk        # Development configuration
│   ├── Terminal.mk       # Terminal configuration
│   ├── Network.mk        # Network configuration
│   └── Storage.mk        # Storage configuration
├── virt/                 # Virtualization configurations
│   ├── Network.mk        # Virtual network configuration
│   └── Image.mk          # Image management
└── scripts/              # Helper scripts
    ├── emu-ifup.sh       # NIC up script
    ├── emu-ifdown.sh     # NIC down script
    ├── virt-net.sh       # Virtual network script
    └── emu-term.py       # Terminal management script
```

## License

This project is licensed under the Apache License 2.0. See the [LICENSE](LICENSE) file for details.

## Contributing

Issues and Pull Requests are welcome. Before submitting code, please ensure:

1. Code follows the project's coding standards
2. All tests pass
3. Commit messages are clear and descriptive

## Contact

- Project Homepage: <repository-url>
- Issue Feedback: [Issues](<repository-url>/issues)

## Copyright

Copyright (c) 2025-2026, Kyber Development Team, all right reserved.
