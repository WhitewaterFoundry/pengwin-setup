# Pengwin User Guide

## Table of Contents

- [Introduction](#introduction)
- [Initial Setup](#initial-setup)
  - [Prerequisites](#prerequisites)
  - [Installing WSL](#installing-wsl)
  - [Installing Pengwin](#installing-pengwin)
  - [First Launch](#first-launch)
- [Quick Start Guide](#quick-start-guide)
  - [Understanding pengwin-setup](#understanding-pengwin-setup)
  - [Interactive Mode](#interactive-mode)
  - [Non-Interactive Mode](#non-interactive-mode)
  - [Command Line Options](#command-line-options)
- [Configuration and Settings](#configuration-and-settings)
  - [Updates and Package Management](#updates-and-package-management)
  - [systemd Support](#systemd-support)
  - [Home Directory Backups](#home-directory-backups)
  - [Windows Home Access (winhome)](#windows-home-access-winhome)
  - [GUI Configuration](#gui-configuration)
  - [Desktop Environments](#desktop-environments)
- [Detailed Options Reference](#detailed-options-reference)
  - [AI Tools](#ai-tools)
  - [Editors](#editors)
  - [GUI Applications](#gui-applications)
  - [Maintenance](#maintenance)
  - [Programming Languages](#programming-languages)
  - [Services](#services)
  - [Settings](#settings)
  - [Tools](#tools)
  - [Uninstall](#uninstall)
- [Troubleshooting](#troubleshooting)
- [Additional Resources](#additional-resources)

---

## Introduction

**Pengwin** is a Linux distribution specifically optimized for Windows Subsystem for Linux (WSL). Based on Debian 13 (Trixie), it provides a curated collection of tools and configurations designed to work seamlessly with Windows, making it ideal for developers, system administrators, and Linux enthusiasts who work in a Windows environment.

The heart of Pengwin is **pengwin-setup**, a comprehensive configuration utility that allows you to easily install and configure various applications, programming languages, desktop environments, and services without dealing with complex manual installation procedures.

### Key Features

- **Pre-configured for WSL**: Optimized settings and configurations for both WSL1 and WSL2
- **Easy Package Installation**: Hand-curated add-ons and applications through an intuitive menu system
- **GUI Support**: Built-in support for X servers and desktop environments
- **Hardware Acceleration**: GPU acceleration with Direct3D 12 support for graphics and video
- **Developer Tools**: Quick installation of popular programming languages and development tools
- **Windows Integration**: Seamless integration with Windows including Explorer integration and file access
- **Windows Fonts for Linux Apps**: Unique to Pengwin - Linux GUI applications can directly use Windows fonts without additional configuration
- **Built-in Aliases**: Convenient shortcuts like `winget`, `wsl`, and `ll` commands
- **Automated Mode**: Support for scripted, non-interactive installations

---

## Initial Setup

### Prerequisites

Before installing Pengwin, you need:

- **Windows 10** (version 1903 or later) or **Windows 11**
- **Administrator access** to enable WSL
- **Internet connection** for downloading packages

### Installing WSL

If you haven't already enabled WSL on your Windows system:

1. **Open PowerShell as Administrator** and run:
   ```powershell
   wsl --install --no-distribution
   ```

2. **Restart your computer** when prompted.

3. For **manual installation** or older Windows versions:
   ```powershell
   # Enable WSL feature
   dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
   
   # Enable Virtual Machine Platform (for WSL2)
   dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
   
   # Restart your computer
   ```

4. **Set WSL2 as default** (recommended):
   ```powershell
   wsl --set-default-version 2
   ```

### Installing Pengwin

Pengwin can be installed from the Microsoft Store:

1. Open the **Microsoft Store**
2. Search for **"Pengwin"**
3. Click **"Get"** or **"Install"**
4. Wait for the download and installation to complete

### First Launch

1. **Launch Pengwin** from the Start Menu or by running `pengwin` in PowerShell/CMD

2. **Wait for initial setup** - The first launch will take a few moments as the Linux environment is set up

3. **Create a user account**:
   - You'll be prompted to create a UNIX username (lowercase, no spaces)
   - Enter and confirm a password
   - This user will have sudo privileges

4. **Initial configuration** - After account creation, you'll see the Pengwin welcome screen

---

## Quick Start Guide

### Understanding pengwin-setup

`pengwin-setup` is your central configuration tool for Pengwin. It provides:

- A **menu-driven interface** for easy navigation
- **Hand-curated packages** optimized for WSL
- **Automated installation** options for scripting
- **Package management** and update functionality

### Interactive Mode

To launch pengwin-setup in interactive mode, simply run:

```bash
pengwin-setup
```

This will:
1. Check for updates to pengwin-setup itself
2. Display the main menu with available categories
3. Allow you to navigate and select options using your keyboard

**Navigation Tips:**
- Use **Arrow Keys** to move up and down
- Press **Space** to select/deselect items (when multiple selection is enabled)
- Press **Enter** to confirm your selection
- Select **"Back"** or press **ESC** to return to the previous menu

### Non-Interactive Mode

For automation or scripting, you can install packages non-interactively:

```bash
# General syntax
pengwin-setup install CATEGORY ITEM

# Examples
pengwin-setup install PROGRAMMING NODEJS
pengwin-setup install EDITORS CODE
pengwin-setup install GUI DESKTOP XFCE
```

### Command Line Options

`pengwin-setup` supports various command-line options:

#### Options

| Option | Description |
|--------|-------------|
| `--help`, `-h` | Display help message and exit |
| `--debug`, `-d`, `--verbose`, `-v` | Run in debug/verbose mode with detailed output |
| `-y`, `--yes`, `--assume-yes` | Skip confirmations, use default answers |
| `--noupdate` | Skip the update step before showing setup |
| `--norebuildicons` | Skip rebuilding start menu icons |
| `-q`, `--quiet`, `--noninteractive` | Run in non-interactive mode |
| `--multiple` | Allow selecting multiple installers at once |

#### Commands

| Command | Description |
|---------|-------------|
| `update`, `upgrade` | Update packages only (implies `--yes` and `--noninteractive`) |
| `install ACTIONS` | Install packages without prompts or updates |
| `uninstall`, `remove ACTIONS` | Uninstall packages without prompts |
| `startmenu` | Regenerate start menu icons |

#### Examples

```bash
# Update packages with detailed output
pengwin-setup --verbose update

# Install HiDPI support without prompts
pengwin-setup install GUI HIDPI

# Install multiple items automatically
pengwin-setup --yes install PROGRAMMING PYTHONPI NODEJS

# Install Docker non-interactively
pengwin-setup --noninteractive install TOOLS DOCKER
```

---

## Configuration and Settings

### Updates and Package Management

#### Automatic Updates

When you launch pengwin-setup, it automatically:
- Checks for updates to core Pengwin packages
- Prompts you to install available updates (recommended)
- Updates the package database

#### Manual Updates

```bash
# Update all packages
pengwin-setup update

# Update specific Pengwin components
sudo apt-get update
sudo apt-get upgrade pengwin-base pengwin-setup

# Distribution upgrade (when available)
sudo apt-get dist-upgrade
```

### systemd Support

systemd is the modern init system and service manager for Linux.

#### Enabling systemd

1. Launch pengwin-setup
2. Navigate to **SERVICES → SYSTEMD**
3. Confirm to enable systemd support

**Note:** 
- systemd is fully supported in WSL2 with Pengwin's custom start-systemd implementation
- WSL1 uses `wslsystemctl` - a compatibility tool providing basic systemd functionality
- After enabling, you may need to restart Pengwin
- Pengwin automatically detects your WSL version and configures accordingly

#### Using systemd

**On WSL2:**
```bash
# Start a service
sudo systemctl start service-name

# Enable a service to start at boot
sudo systemctl enable service-name

# Check service status
sudo systemctl status service-name

# View all services
systemctl list-units --type=service

# View logs
journalctl -u service-name
```

**On WSL1:**
```bash
# WSL1 uses wslsystemctl for basic compatibility
sudo wslsystemctl start service-name
sudo wslsystemctl stop service-name
sudo wslsystemctl status service-name

# View logs with wsljournalctl
wsljournalctl
```

### Home Directory Backups

Pengwin provides a built-in backup and restore feature for your home directory.

#### Creating a Backup

1. Launch pengwin-setup
2. Navigate to **MAINTENANCE → HOMEBACKUP → Backup**
3. The backup will be saved to your Windows home directory:
   - Location: `%USERPROFILE%\Pengwin\backups\pengwin_home.tgz`
   - Windows path example: `C:\Users\YourName\Pengwin\backups\`

#### Excluding Files from Backup

Create a file `~/.pengwinbackupignore` with patterns to exclude:

```bash
# Example .pengwinbackupignore
.cache
node_modules
*.tmp
.npm
```

#### Restoring from Backup

1. Launch pengwin-setup
2. Navigate to **MAINTENANCE → HOMEBACKUP → Restore**
3. Confirm to restore from the latest backup

**Warning:** Restore will overwrite existing files in your home directory!

### Windows Home Access (winhome)

Pengwin automatically creates a symbolic link called `winhome` in your Linux home directory that points to your Windows user home directory.

#### Using winhome

```bash
# Access your Windows Documents folder
cd ~/winhome/Documents

# Copy a file from Windows to Linux
cp ~/winhome/Documents/file.txt ~/

# Edit a Windows file with a Linux editor
nano ~/winhome/Documents/notes.txt

# View your Windows Desktop
ls ~/winhome/Desktop
```

#### Environment Variables

Pengwin also exports these environment variables:
- `$wHome`: Path to Windows home directory in WSL format
- `$wHomeWinPath`: Path to Windows home directory in Windows format

```bash
# Use in scripts
echo "Windows Home: $wHome"
echo "Windows Path: $wHomeWinPath"
```

### GUI Configuration

Pengwin supports running graphical Linux applications through various methods.

#### WSLg (Windows 11 and Recent Windows 10)

**WSLg** is Microsoft's built-in GUI support for WSL, available on:
- Windows 11
- Windows 10 version 21H2 and later (with updates)

**Features:**
- Automatic GPU acceleration with Direct3D 12
- Native Windows integration
- No additional setup required
- Hardware video acceleration (VDPAU, VA-API)

**Using WSLg:**
1. Simply install and run GUI applications
2. They will appear as native Windows windows

**Pengwin's GPU and Video Acceleration (WSL2):**

Pengwin automatically configures GPU acceleration for optimal graphics and video performance:

- **Direct3D 12 Graphics**: Pengwin sets up Mesa Gallium drivers with D3D12 backend for GPU acceleration
- **Video Acceleration**: 
  - VDPAU (Video Decode and Presentation API for Unix) with d3d12 driver
  - VA-API (Video Acceleration API) with d3d12 driver
- **OpenGL Support**: Automatic configuration for both indirect and direct rendering
- **Performance**: Significantly improved graphics rendering in GUI applications and video playback

These optimizations are applied automatically in WSL2 environments without any user configuration.

**Pengwin's Unique Windows Fonts Integration:**

One of Pengwin's exclusive features is automatic Windows fonts integration. Linux GUI applications can use Windows fonts directly without any additional configuration. This means:
- All your Windows fonts (Arial, Calibri, Times New Roman, etc.) are immediately available in Linux GUI apps
- Font rendering in Linux applications matches Windows appearance
- No need to manually copy or configure fonts
- Works automatically with any Linux GUI application

This feature is unique to Pengwin and provides seamless typography consistency between Windows and Linux applications.

**Disabling WSLg** (to use alternative X servers):
1. Launch pengwin-setup
2. Navigate to **GUI → CONFIGURE → WSLG**
3. Choose to disable WSLg

#### X Server Setup (WSL1 or WSLg Alternative)

For systems without WSLg or when you prefer alternative X servers:

**Supported X Servers:**
- **VcXsrv** - Free, open-source
- **X410** - Commercial, from Microsoft Store

**Installation:**

1. Launch pengwin-setup
2. Navigate to **GUI → CONFIGURE**
3. Select **VCXSRV** or **X410**
4. Follow the installation prompts

**Configuring DISPLAY:**

The DISPLAY variable tells GUI apps where to render. Pengwin can configure this automatically:

- **From DNS** (recommended for most users)
  - No firewall configuration needed with VcXsrv
  - Automatically detects Windows host IP
  
- **From resolv.conf** (alternative method)
  - May require firewall rules
  - More reliable in some network configurations

#### HiDPI / High Resolution Display Support

If you have a 4K or high-DPI display:

1. Launch pengwin-setup
2. Navigate to **GUI → HIDPI**
3. Select your display scaling factor (100%, 150%, 200%, 250%, 300%)
4. GUI applications will automatically scale appropriately

### Desktop Environments

You can install full desktop environments in Pengwin.

#### Installing XFCE Desktop

**XFCE** is a lightweight, fast desktop environment.

1. Launch pengwin-setup
2. Navigate to **GUI → DESKTOP → XFCE**
3. Choose installation method:
   - **RDP** (Remote Desktop Protocol) - More compatible, works on WSL1 and WSL2
   - **VNC** - Alternative remote desktop option

4. After installation, launch from Start Menu:
   - Look for "Pengwin XFCE" shortcut

**Start Menu Integration:**
- Shortcuts are automatically created in your Windows Start Menu
- Located in: `Start Menu → Pengwin`

#### Using the Desktop

- The desktop runs in a window or can be full-screen
- You get a complete Linux desktop with:
  - File manager
  - Terminal emulator
  - Applications menu
  - System settings

---

## Detailed Options Reference

### AI Tools

Access the latest AI-powered command-line tools.

#### COPILOT-CLI

GitHub Copilot for the command line - AI-powered shell assistance.

**Installation:**
```bash
pengwin-setup install AI COPILOT-CLI
```

**What it does:**
- Installs GitHub Copilot CLI
- Provides natural language to shell command translation
- Helps explain complex commands

**Usage:**
```bash
# Get command suggestions (after installation)
gh copilot suggest "list all files larger than 1GB"

# Explain a command
gh copilot explain "tar -xzvf archive.tar.gz"
```

### Editors

Install popular text editors optimized for WSL.

#### CODE (Visual Studio Code)

Microsoft's popular code editor, Linux version.

**Installation:**
```bash
pengwin-setup install EDITORS CODE
```

**Features:**
- Full featured IDE
- Extensions marketplace
- Integrated terminal
- Git integration
- IntelliSense

**Note:** WSL1 users will get a compatible version automatically.

**Launching:**
```bash
code .              # Open current directory
code filename.txt   # Open specific file
```

#### NEOVIM

Modern Vim-based text editor.

**Installation:**
```bash
pengwin-setup install EDITORS NEOVIM
```

**Includes:**
- Neovim editor
- Build-essential tools for plugin compilation

**Launching:**
```bash
nvim filename.txt
```

#### EMACS

The extensible, customizable text editor.

**Installation:**
```bash
pengwin-setup install EDITORS EMACS
```

**Launching:**
```bash
emacs filename.txt
emacs -nw          # No window (terminal mode)
```

#### MSEDIT (Microsoft Edit)

Lightweight text editor integration.

**Installation:**
```bash
pengwin-setup install EDITORS MSEDIT
```

### GUI Applications

Install and configure graphical applications and libraries.

#### CONFIGURE

GUI configuration options.

**Sub-options:**
- **DISPLAY** - Configure how to get the DISPLAY variable IP
- **STARTMENU** - Regenerate Windows Start Menu shortcuts
- **VCXSRV** - Install and configure VcXsrv X server
- **X410** - Configure X410 X server (must be installed from Microsoft Store)
- **WSLG** - Enable/disable WSLg support

#### DESKTOP

Install desktop environments.

**Available Desktops:**
- **XFCE** - Lightweight, fast desktop environment
  - Includes RDP and VNC server options

#### NLI (Native Linux Interface)

Font rendering and theme improvements for better Linux GUI experience.

**Installation:**
```bash
pengwin-setup install GUI NLI
```

#### GUILIB

Install essential GUI libraries required by graphical applications.

**Installation:**
```bash
pengwin-setup install GUI GUILIB
```

**Includes:**
- Basic X11 libraries
- Mesa utilities
- D-Bus configuration
- Prerequisite for most GUI applications

#### HIDPI

Configure high DPI display support.

**Installation:**
```bash
pengwin-setup install GUI HIDPI
```

**Options:**
- 100% (no scaling)
- 150% scaling
- 200% scaling
- 250% scaling
- 300% scaling

#### TERMINAL

Install alternative terminal emulators.

**Available Terminals:**
- **WINTERM** - Windows Terminal configuration
- **WSLTTY** - wsltty terminal emulator
- **TILIX** - Tiling terminal emulator
- **GTERM** - GNOME Terminal
- **XFTERM** - XFCE Terminal
- **TERMINATOR** - Advanced terminal with split panes
- **KONSO** - Konsole (KDE terminal)

#### SYNAPTIC

Synaptic Package Manager - GUI for package management.

**Installation:**
```bash
pengwin-setup install GUI SYNAPTIC
```

**Features:**
- Graphical interface for apt
- Search and install packages
- View package details and dependencies

#### WINTHEME

Apply Windows theme to Linux GUI applications.

**Installation:**
```bash
pengwin-setup install GUI WINTHEME
```

Makes GTK applications match your Windows theme.

#### WSLG

Enable or disable WSLg support.

**Installation:**
```bash
pengwin-setup install GUI WSLG
```

Toggle WSLg on systems that support it.

### Maintenance

Various system maintenance tasks.

#### HOMEBACKUP

Backup and restore your home directory.

**Installation:**
```bash
pengwin-setup install MAINTENANCE HOMEBACKUP
```

**Features:**
- Backup to Windows home directory
- Exclude files with `.pengwinbackupignore`
- Restore from previous backup
- Automatic backup timestamping

**Locations:**
- Backup saved to: `%USERPROFILE%\Pengwin\backups\`
- Old backups are renamed with timestamps

### Programming Languages

Install development environments for various programming languages.

#### C++

C/C++ development tools for Visual Studio and CLion.

**Installation:**
```bash
pengwin-setup install PROGRAMMING C++
```

**Includes:**
- GCC/G++ compiler
- GDB debugger
- Build tools
- Support for remote development from Visual Studio and CLion

#### DOTNET

.NET Core SDK from Microsoft.

**Installation:**
```bash
pengwin-setup install PROGRAMMING DOTNET
```

**Features:**
- Latest .NET Core SDK
- Optional NuGet package manager
- C# and F# support

**Usage:**
```bash
dotnet new console -n MyApp
dotnet build
dotnet run
```

#### GO

Go programming language from Google.

**Installation:**
```bash
pengwin-setup install PROGRAMMING GO
```

**Features:**
- Latest stable Go version
- Automatic PATH configuration
- Go modules support

**Usage:**
```bash
go version
go run main.go
```

#### JAVA

Java development with SDKMan for version management.

**Installation:**
```bash
pengwin-setup install PROGRAMMING JAVA
```

**Features:**
- SDKMan! installation
- Manage multiple Java versions
- Access to various JDK distributions

**Usage:**
```bash
sdk list java              # List available versions
sdk install java 17.0.5-tem
sdk use java 17.0.5-tem
```

#### JETBRAINS

Support for JetBrains IDEs (IntelliJ IDEA, PyCharm, etc.).

**Installation:**
```bash
pengwin-setup install PROGRAMMING JETBRAINS
```

**Features:**
- Required libraries for JetBrains tools
- Optimized settings for WSL

#### JOOMLA

Development environment for Joomla CMS.

**Installation:**
```bash
pengwin-setup install PROGRAMMING JOOMLA
```

**Includes:**
- LAMP stack (if not already installed)
- Joomla dependencies
- Development tools

#### LATEX

TeX Live for LaTeX document preparation.

**Installation:**
```bash
pengwin-setup install PROGRAMMING LATEX
```

**Features:**
- Full TeX Live distribution
- Common LaTeX packages
- PDF generation support

**Usage:**
```bash
pdflatex document.tex
xelatex document.tex
```

#### NIM

Nim programming language via choosenim.

**Installation:**
```bash
pengwin-setup install PROGRAMMING NIM
```

**Features:**
- Latest Nim compiler
- Nimble package manager
- Version management with choosenim

**Usage:**
```bash
nim c hello.nim
nim c -r hello.nim    # Compile and run
```

#### NODEJS

Node.js and npm package manager.

**Installation:**
```bash
# Install Node.js
pengwin-setup install PROGRAMMING NODEJS

# Choose version manager and version
pengwin-setup install PROGRAMMING NODEJS NVM LATEST
```

**Options:**
- **NVERMAN** - Node Version Manager installation
- **NVM** - nvm (alternative version manager)
- **LATEST** - Latest Node.js version
- **LTS** - Long Term Support version

**Usage:**
```bash
node --version
npm --version
npm install -g package-name
```

#### PYTHONPI

Python 3.13 and package management tools.

**Installation:**
```bash
pengwin-setup install PROGRAMMING PYTHONPI
```

**Sub-options:**
- **PYENV** - Python version manager
- **PYTHONPIP** - Latest pip package manager
- **POETRY** - Modern Python dependency management

**Usage:**
```bash
python3 --version
pip3 install package-name

# With pyenv
pyenv install 3.11.0
pyenv global 3.11.0

# With poetry
poetry new my-project
poetry add requests
```

#### RUBY

Ruby programming language via rbenv.

**Installation:**
```bash
pengwin-setup install PROGRAMMING RUBY
```

**Features:**
- rbenv for version management
- ruby-build for installing Ruby versions
- Optional Rails framework

**Usage:**
```bash
rbenv install 3.2.0
rbenv global 3.2.0
ruby --version

# Install Rails (if selected)
gem install rails
```

#### RUST

Rust programming language via rustup.

**Installation:**
```bash
pengwin-setup install PROGRAMMING RUST
```

**Features:**
- Latest Rust toolchain
- Cargo package manager
- rustup for version management

**Usage:**
```bash
rustc --version
cargo --version
cargo new my-project
cargo build
cargo run
```

### Services

Enable and configure system services.

#### LAMP

Linux, Apache, MySQL (MariaDB), PHP stack.

**Installation:**
```bash
pengwin-setup install SERVICES LAMP
```

**MySQL Version Options:**
- **BUILTIN** - Default Debian version
- **10.6** - MariaDB 10.6
- **10.7** - MariaDB 10.7
- **10.8** - MariaDB 10.8
- **10.9** - MariaDB 10.9

**Features:**
- Apache web server
- MariaDB database
- PHP
- Automatic configuration

**Usage:**
```bash
sudo service apache2 start
sudo service mysql start

# Access web server
# http://localhost in Windows browser
```

#### RCLOCAL

Enable rc.local support for running scripts at launch.

**Installation:**
```bash
pengwin-setup install SERVICES RCLOCAL
```

**Features:**
- Run custom scripts at Pengwin startup
- Located at `/etc/rc.local`
- Scripts in `/etc/boot.d/` run automatically

**Usage:**
```bash
# Edit rc.local
sudo nano /etc/rc.local

# Add scripts to boot.d
sudo nano /etc/boot.d/my-script.sh
sudo chmod +x /etc/boot.d/my-script.sh
```

#### SSH

OpenSSH server for remote access.

**Installation:**
```bash
pengwin-setup install SERVICES SSH
```

**Features:**
- OpenSSH server
- Automatic port configuration
- Optional start at login

**Usage:**
```bash
sudo service ssh start
sudo service ssh status

# Connect from another machine
ssh username@windows-ip-address -p port
```

#### SYSTEMD

Enable systemd init system.

**Installation:**
```bash
pengwin-setup install SERVICES SYSTEMD
```

**Features:**
- Full systemd support (WSL2)
- Compatibility layer (WSL1)
- Service management with systemctl

**Usage:**
```bash
sudo systemctl start service-name
sudo systemctl enable service-name
sudo systemctl status service-name
```

### Settings

Customize your Pengwin environment.

#### EXPLORER

Windows Explorer integration.

**Installation:**
```bash
pengwin-setup install SETTINGS EXPLORER
```

**Features:**
- Right-click folders in Windows Explorer
- "Open in Pengwin" context menu option
- Direct folder access from Windows

**Usage:**
1. Right-click any folder in Windows Explorer
2. Select "Open in Pengwin"
3. Pengwin terminal opens in that directory

#### COLORTOOL

Windows Console color scheme configuration.

**Installation:**
```bash
pengwin-setup install SETTINGS COLORTOOL
```

**Features:**
- Install Microsoft's ColorTool
- Set color schemes for Windows Terminal
- Multiple themes available

#### LANGUAGE

Change system language and keyboard settings.

**Installation:**
```bash
pengwin-setup install SETTINGS LANGUAGE
```

**Features:**
- Set system locale
- Configure keyboard layout
- Install language packs

**Usage:**
- Select your preferred language from the list
- Changes take effect on next login

#### MOTD

Configure Message of the Day behavior.

**Installation:**
```bash
pengwin-setup install SETTINGS MOTD
```

**Options:**
- Enable/disable MOTD
- Customize welcome messages
- Control information display at login

#### SHELLS

Install alternative shells and shell improvements.

**Installation:**
```bash
pengwin-setup install SETTINGS SHELLS
```

**Available Shells:**
- **BASH-RL** - Bash with readline improvements
- **CSH** - C Shell
- **FISH** - Friendly Interactive Shell
- **ZSH** - Z Shell with oh-my-zsh

**Features:**

**Bash with Readline:**
- Better command completion
- History improvements
- Syntax highlighting

**Fish:**
- Auto-suggestions
- Syntax highlighting
- Web-based configuration
```bash
fish_config  # Launch web interface
```

**Zsh with oh-my-zsh:**
- Extensive plugin system
- Themes
- Advanced completion
```bash
# oh-my-zsh is installed automatically
# Configure in ~/.zshrc
```

**Changing Default Shell:**
```bash
chsh -s /usr/bin/zsh
chsh -s /usr/bin/fish
chsh -s /bin/bash
```

### Tools

Additional utilities and servers.

#### ANSIBLE

Ansible automation platform.

**Installation:**
```bash
pengwin-setup install TOOLS ANSIBLE
```

**Features:**
- Latest Ansible
- Required dependencies
- Ready to deploy playbooks

**Usage:**
```bash
ansible --version
ansible-playbook playbook.yml
```

#### CLOUDCLI

Cloud management CLI tools.

**Installation:**
```bash
pengwin-setup install TOOLS CLOUDCLI
```

**Available Tools:**
- **TERRAFORM** - Infrastructure as Code tool
- **KUBERNETES** - kubectl for Kubernetes management
- **AWS CLI** - Amazon Web Services CLI
- **Azure CLI** - Microsoft Azure CLI

**Usage:**
```bash
# After installation
terraform --version
kubectl version
aws --version
az --version
```

#### DOCKER

Secure bridge to Docker Desktop.

**Installation:**
```bash
pengwin-setup install TOOLS DOCKER
```

**Requirements:**
- Docker Desktop must be installed on Windows
- WSL2 integration must be enabled in Docker Desktop

**Features:**
- Docker CLI configured to use Docker Desktop
- Seamless integration with Windows Docker
- Access to Windows Docker containers

**Usage:**
```bash
docker --version
docker ps
docker run hello-world
```

#### FZF

Command-line fuzzy finder.

**Installation:**
```bash
pengwin-setup install TOOLS FZF
```

**Features:**
- Fast fuzzy searching
- Command history search (Ctrl+R)
- File and directory finding
- Integration with many tools

**Usage:**
```bash
# Search command history
Ctrl+R

# Find files
find . | fzf

# Fuzzy cd
cd **<TAB>
```

#### HOMEBREW

The Homebrew package manager for Linux.

**Installation:**
```bash
pengwin-setup install TOOLS HOMEBREW
```

**Features:**
- Access to Homebrew package repository
- Easy installation of software
- Automatic dependency management

**Usage:**
```bash
brew install package-name
brew search package-name
brew upgrade
```

#### POWERSHELL

PowerShell for Linux.

**Installation:**
```bash
pengwin-setup install TOOLS POWERSHELL
```

**Features:**
- Microsoft PowerShell Core
- Cross-platform PowerShell experience
- Access to PowerShell modules

**Usage:**
```bash
pwsh
# PowerShell prompt appears
PS> Get-Command
PS> exit
```

### Uninstall

Remove applications and packages installed by pengwin-setup.

**Interactive Mode:**
```bash
pengwin-setup
# Select UNINSTALL from main menu
# Choose category and items to remove
```

**Non-Interactive Mode:**
```bash
pengwin-setup uninstall CATEGORY ITEM

# Examples
pengwin-setup uninstall EDITORS CODE
pengwin-setup uninstall PROGRAMMING NODEJS
pengwin-setup uninstall TOOLS DOCKER
```

**Features:**
- Complete removal of packages
- Cleanup of configuration files
- Removal of shortcuts and integrations

**Note:** Uninstalling will not remove user data or configurations in your home directory unless they were created by the installer.

---

## Troubleshooting

### Common Issues and Solutions

#### pengwin-setup Won't Start

**Problem:** Error about Windows PATH not available

**Solution:**
1. Make sure you're not running pengwin-setup with `sudo`
2. Check `/etc/wsl.conf` - ensure `appendWindowsPath=true` or the line is not present
3. Restart Pengwin: `wsl --terminate Pengwin` in PowerShell, then restart

#### GUI Applications Won't Start

**Problem:** Error about DISPLAY variable

**Solution:**
1. Check if WSLg is available (Windows 11 or recent Windows 10):
   ```bash
   echo $DISPLAY
   # Should show something like :0
   ```

2. If using X server:
   - Ensure X server is running on Windows
   - Check firewall settings
   - Reconfigure with: `pengwin-setup install GUI CONFIGURE VCXSRV`

3. Test with a simple GUI app:
   ```bash
   sudo apt-get install x11-apps
   xeyes
   ```

#### Package Installation Fails

**Problem:** Errors during package installation

**Solution:**
1. Update package lists:
   ```bash
   sudo apt-get update
   ```

2. Fix broken packages:
   ```bash
   sudo apt-get install -f
   sudo dpkg --configure -a
   ```

3. Clear apt cache:
   ```bash
   sudo apt-get clean
   sudo apt-get update
   ```

#### systemd Services Won't Start

**Problem:** systemctl commands fail

**Solution:**
1. Ensure systemd is enabled:
   ```bash
   pengwin-setup install SERVICES SYSTEMD
   ```

2. Check WSL version:
   ```bash
   wsl -l -v
   # Pengwin should show version 2 for full systemd support
   ```

3. Restart Pengwin completely:
   ```bash
   # In PowerShell
   wsl --terminate Pengwin
   ```

#### Slow Performance

**Problem:** Pengwin feels slow

**Solution:**
1. If on WSL1, consider upgrading to WSL2:
   ```powershell
   # In PowerShell as Administrator
   wsl --set-version Pengwin 2
   ```

2. Check antivirus exclusions:
   - Add WSL directories to Windows Defender exclusions
   - Exclude: `%USERPROFILE%\AppData\Local\Packages\`

3. Avoid working on Windows filesystem from WSL:
   - Slow: `/mnt/c/Users/...`
   - Fast: `~/` (WSL filesystem)

#### Can't Access Windows Files

**Problem:** Cannot access /mnt/c or winhome

**Solution:**
1. Check if DrvFs is mounted:
   ```bash
   mount | grep drvfs
   ```

2. Manually mount if needed:
   ```bash
   sudo mkdir -p /mnt/c
   sudo mount -t drvfs C: /mnt/c
   ```

3. Check wsl.conf automount settings:
   ```bash
   cat /etc/wsl.conf
   # Should have:
   # [automount]
   # enabled = true
   ```

#### Docker Integration Not Working

**Problem:** Docker commands fail

**Solution:**
1. Ensure Docker Desktop is running on Windows
2. Enable WSL2 integration in Docker Desktop:
   - Open Docker Desktop Settings
   - Go to Resources → WSL Integration
   - Enable integration with Pengwin
3. Restart Docker Desktop and Pengwin

#### Network Issues

**Problem:** Cannot connect to internet

**Solution:**
1. Check DNS resolution:
   ```bash
   cat /etc/resolv.conf
   ping 8.8.8.8
   ```

2. Reset WSL network:
   ```powershell
   # In PowerShell as Administrator
   wsl --shutdown
   netsh winsock reset
   netsh int ip reset
   ```

3. Check Windows firewall settings

#### Backup/Restore Issues

**Problem:** Backup fails or restore doesn't work

**Solution:**
1. Check available disk space in Windows:
   ```bash
   df -h ~/winhome
   ```

2. Ensure backup directory exists:
   ```bash
   ls -la ~/winhome/Pengwin/backups/
   ```

3. Check file permissions:
   ```bash
   # Backup should be readable
   ls -la ~/winhome/Pengwin/backups/pengwin_home.tgz
   ```

#### Updates Fail

**Problem:** Cannot update packages or pengwin-setup

**Solution:**
1. Fix held packages:
   ```bash
   sudo apt-mark unhold pengwin-base pengwin-setup
   ```

2. Update and upgrade:
   ```bash
   sudo apt-get update
   sudo apt-get upgrade
   ```

3. If distribution upgrade is needed:
   ```bash
   sudo apt-get dist-upgrade
   ```

### Getting Help

If you continue to experience issues:

1. **Check the GitHub Issues**: https://github.com/WhitewaterFoundry/pengwin-setup/issues
2. **Community Support**: Join the Pengwin community on GitHub Discussions
3. **Documentation**: Run `pengwin-help` command for additional resources
4. **Verbose Output**: Run pengwin-setup with `--debug` flag for detailed information:
   ```bash
   pengwin-setup --debug install CATEGORY ITEM
   ```

---

## Additional Resources

### Official Links

- **Pengwin Website**: https://www.whitewaterfoundry.com
- **GitHub Repository**: https://github.com/WhitewaterFoundry/pengwin-setup
- **Documentation**: Run `pengwin-help` in your terminal
- **Microsoft Store Page**: Search for "Pengwin" in Microsoft Store

### Related Documentation

- **WSL Documentation**: https://docs.microsoft.com/windows/wsl/
- **WSL2 Installation**: https://docs.microsoft.com/windows/wsl/install
- **Docker Desktop WSL2**: https://docs.docker.com/desktop/windows/wsl/

### Useful Commands

#### Pengwin-Specific Commands

```bash
# Get help with pengwin-setup
pengwin-setup --help

# Open Pengwin GitHub repository in browser
pengwin-help

# Switch to development branch (for testing)
switch2dev

# Switch to next release branch
switch2next
```

#### Built-in Aliases

Pengwin includes convenient aliases:

```bash
# Long listing format
ll                           # Alias for 'ls -al'

# Use Windows package manager from Linux
winget <command>             # Access Windows winget

# WSL command
wsl <command>                # Run WSL commands

# Clear screen without scrolling issues
clear                        # Fixed to 'clear -x'
```

#### System Commands

```bash
# Display pengwin-setup version
pengwin-setup --help | head -n 1

# View pengwin-setup completion options (bash)
source /usr/share/bash-completion/completions/pengwin-setup

# Check WSL version
wsl -l -v                    # In PowerShell

# Restart Pengwin
wsl --terminate Pengwin      # In PowerShell

# Access Pengwin from PowerShell
wsl -d Pengwin

# List all installed packages
dpkg -l

# Search for a package
apt search package-name

# Get package information
apt show package-name
```

### Tips and Best Practices

1. **Keep Pengwin Updated**: Regularly run `pengwin-setup update` to keep your system current

2. **Use WSL2**: WSL2 provides better performance and full Linux kernel compatibility

3. **Work in WSL Filesystem**: For best performance, keep your projects in the WSL filesystem (`~/`) rather than Windows filesystem (`/mnt/c/`)

4. **Backup Regularly**: Use the built-in backup feature before major changes

5. **Learn the Shortcuts**: Use `pengwin-setup install` for quick, scriptable installations

6. **Explore Available Options**: Run `pengwin-setup --help` to see all available categories and options

7. **Use Multiple Shells**: Try different shells like Fish or Zsh to find what works best for you

8. **Integrate with Windows**: Take advantage of Windows integration features like Explorer context menu

9. **Document Custom Changes**: Keep notes of manual configurations outside of pengwin-setup

10. **Check Compatibility**: When installing software manually, ensure it's compatible with WSL

### Community Contributions

Pengwin is open source and welcomes contributions:

- **Report Bugs**: Open an issue on GitHub
- **Request Features**: Suggest new installers or improvements
- **Submit Pull Requests**: Contribute code improvements
- **Improve Documentation**: Help make the documentation better

### Version Information

This guide covers **pengwin-setup version 1.2a** and later. Features and options may vary in different versions. Always refer to the built-in help (`pengwin-setup --help`) for the most accurate information for your installed version.

---

**Last Updated**: November 2025

**License**: This guide is provided as-is for the Pengwin community. Pengwin and pengwin-setup are open-source projects. See the LICENSE file in the repository for details.
