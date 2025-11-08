# pengwin-setup

A comprehensive configuration and package installation utility for [Pengwin](https://www.pengwin.dev/), a Linux distribution optimized for Windows Subsystem for Linux (WSL).

## Overview

**pengwin-setup** is the central configuration tool for Pengwin, providing an intuitive menu-driven interface and command-line options to install and configure:

- 🤖 **AI Tools** - GitHub Copilot CLI and AI assistants
- ✏️ **Text Editors** - Visual Studio Code, Neovim, Emacs
- 🖥️ **GUI Applications** - X servers, desktop environments (XFCE), terminal emulators
- 💻 **Programming Languages** - Python, Node.js, Go, Rust, Ruby, Java, .NET, and more
- 🛠️ **Development Tools** - Docker, Ansible, Cloud CLIs (AWS, Azure, Terraform)
- ⚙️ **System Services** - SystemD, SSH, LAMP stack, rc.local
- 🎨 **Settings & Customization** - Shells (Zsh, Fish), language settings, Windows integration

## Quick Start

### Interactive Mode

Simply run:
```bash
pengwin-setup
```

Navigate using arrow keys, select options with Space, and confirm with Enter.

### Non-Interactive Mode

Install packages directly from the command line:
```bash
# Install Node.js
pengwin-setup install PROGRAMMING NODEJS

# Install Visual Studio Code
pengwin-setup install EDITORS CODE

# Install XFCE desktop environment
pengwin-setup install GUI DESKTOP XFCE

# Install Docker bridge to Docker Desktop
pengwin-setup install TOOLS DOCKER
```

### Automated Installation

Use flags for scripting and automation:
```bash
# Install without prompts
pengwin-setup --yes --noninteractive install PROGRAMMING PYTHONPI

# Update packages only
pengwin-setup update

# Verbose output for debugging
pengwin-setup --debug install TOOLS HOMEBREW
```

## Documentation

📖 **[Complete User Guide](USER_GUIDE.md)** - Comprehensive documentation including:
- Initial setup and installation
- Detailed guide to all features and options
- Configuration walkthroughs (GUI, SystemD, backups, etc.)
- Troubleshooting common issues
- Best practices and tips

### Quick Links

- **Installation Guide**: [USER_GUIDE.md#initial-setup](USER_GUIDE.md#initial-setup)
- **Quick Start**: [USER_GUIDE.md#quick-start-guide](USER_GUIDE.md#quick-start-guide)
- **All Options Reference**: [USER_GUIDE.md#detailed-options-reference](USER_GUIDE.md#detailed-options-reference)
- **Troubleshooting**: [USER_GUIDE.md#troubleshooting](USER_GUIDE.md#troubleshooting)

## Features

### 🚀 Easy Installation
Hand-curated packages optimized for WSL with one-command installation.

### 🔧 Configuration Management
- SystemD support for modern service management
- Home directory backup and restore
- Windows home directory integration (`winhome`)
- HiDPI/4K display configuration
- X server setup (VcXsrv, X410) or WSLg

### 🪟 Windows Integration
- Explorer context menu integration
- Start menu shortcuts
- Seamless file access between Windows and Linux
- Windows Terminal configuration

### 📦 Comprehensive Package Support
Categories include:
- **AI**: Copilot CLI
- **Editors**: CODE, EMACS, NEOVIM, MSEDIT
- **GUI**: Desktop environments, terminals, X servers
- **Maintenance**: Home backups
- **Programming**: C++, .NET, Go, Java, Node.js, Python, Ruby, Rust, and more
- **Services**: LAMP, SSH, SystemD, rc.local
- **Settings**: Shells, language, Explorer integration
- **Tools**: Ansible, Docker, Homebrew, PowerShell, Cloud CLIs

## Command Line Reference

```
Usage: pengwin-setup [OPTIONS] [COMMANDS] [ACTIONS]

Options:
  --help, -h                     Display help message
  --debug, -d, --verbose, -v     Run in debug/verbose mode
  -y, --yes, --assume-yes        Skip confirmations
  --noupdate                     Skip update step
  --norebuildicons              Skip rebuilding start menu icons
  -q, --quiet, --noninteractive  Run in non-interactive mode
  --multiple                     Allow multiple selections

Commands:
  update, upgrade               Update packages only
  install ACTIONS              Install packages
  uninstall, remove ACTIONS    Uninstall packages
  startmenu                    Regenerate start menu icons

Examples:
  pengwin-setup --verbose update
  pengwin-setup install GUI HIDPI
  pengwin-setup install PROGRAMMING PYTHONPI
  pengwin-setup uninstall EDITORS CODE
```

## Requirements

- **Windows 10** (version 1903 or later) or **Windows 11**
- **WSL** (Windows Subsystem for Linux) enabled
- **Pengwin** installed from Microsoft Store or direct download

## Contributing

Contributions are welcome! This is an open-source project.

### How to Contribute

1. **Report Issues**: Open an issue on GitHub for bugs or feature requests
2. **Submit Pull Requests**: Contribute code improvements
3. **Improve Documentation**: Help make documentation better
4. **Add Installers**: Create new installation scripts following our [coding conventions](.github/copilot-instructions.md)

### Development Guidelines

See [`.github/copilot-instructions.md`](.github/copilot-instructions.md) for:
- Code structure and conventions
- Script organization
- Testing requirements
- Shellcheck compliance

## Support

- 📖 **Documentation**: [USER_GUIDE.md](USER_GUIDE.md)
- 🐛 **Issues**: [GitHub Issues](https://github.com/WhitewaterFoundry/pengwin-setup/issues)
- 💬 **Discussions**: GitHub Discussions
- 🌐 **Website**: https://www.pengwin.dev/
- ❓ **Help Command**: Run `pengwin-help` in your terminal

## License

See [LICENSE](LICENSE) file for details.

## Acknowledgments

Pengwin is developed and maintained by [Whitewater Foundry](https://github.com/WhitewaterFoundry) with contributions from the community.

---

**Version**: 1.2a

For detailed information about all features, options, and troubleshooting, see the **[Complete User Guide](USER_GUIDE.md)**.
