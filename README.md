# NixOS Configuration

A comprehensive NixOS configuration using flakes and home-manager for managing multiple hosts and users with a modular approach.

[![NixOS](https://img.shields.io/badge/NixOS-24.11-blue.svg?logo=nixos&logoColor=white)](https://nixos.org)
[![Nix Flakes](https://img.shields.io/badge/Nix-Flakes-blue.svg?logo=nixos&logoColor=white)](https://nixos.wiki/wiki/Flakes)
[![Home Manager](https://img.shields.io/badge/Home-Manager-blue.svg)](https://github.com/nix-community/home-manager)

## Quick Start

### Prerequisites

- Working NixOS installation with UEFI boot on GPT

### Initial Setup

1. **Enable flakes and git** in `/etc/nixos/configuration.nix`:

   ```nix
   nix.settings.experimental-features = ["nix-command" "flakes"];
   environment.systemPackages = with pkgs; [
     git
   ];
   ```

   Optionally, change hostname if needed:

   ```nix
   networking.hostName = "your-desired-hostname";
   ```

   Apply changes and reboot:

   ```bash
   sudo nixos-rebuild boot
   sudo reboot
   ```

2. **Clone and customize**:

   ```bash
   # Initial clone via HTTPS (works without SSH keys)
   git clone https://github.com/steledama/nixos.git
   cd nixos

   # Copy your hardware configuration
   cp /etc/nixos/hardware-configuration.nix hosts/your-hostname/hardware.nix

   # Edit flake.nix to add your hostname
   # Customize host and user configurations

   # Optional: Switch to SSH after configuring keys
   git remote set-url origin git@github.com:steledama/nixos.git
   ```

3. **First rebuild**:
   ```bash
   sudo nixos-rebuild boot --flake .
   sudo reboot
   ```

## Repository Structure

```
nixos/
├── flake.nix              # Main flake configuration with inputs and outputs
├── flake.lock             # Dependency lockfile
├── hosts/                 # Host-specific configurations
│   ├── default.nix        # Common host configurations
│   ├── pc-minibook/       # Minibook laptop configuration
│   ├── pc-sviluppo/       # Development desktop configuration
│   └── srv-norvegia/      # Server configuration
├── home/                  # Home-manager user configurations
│   ├── norvegia/          # User: norvegia
│   └── stele/             # User: stele
├── modules/               # Reusable system and user modules
│   ├── home/              # Home-manager modules
│   └── system/            # System-level modules
├── overlays/              # Custom overlays
└── pkgs/                  # Custom packages
```

## Common Commands

### System Management

```bash
# Update flake inputs
nix flake update

# Rebuild and switch to new configuration
sudo nixos-rebuild switch --flake .

# Rebuild but don't switch until reboot
sudo nixos-rebuild boot --flake .

# Garbage collection
nix-collect-garbage --delete-old
sudo nix-collect-garbage -d

# Clean bootloader entries
gcCleanup
```

### Service Management (srv-norvegia)

```bash
# Node.js server service
sudo systemctl status node-server
sudo journalctl -u node-server -f

# Automated scripts service
sudo systemctl status automated-scripts
sudo journalctl -u automated-scripts -f

# Syncthing (user service via home-manager)
systemctl --user status syncthing
systemctl --user restart syncthing
journalctl --user -u syncthing -f

# Access Syncthing web GUI
# Web interface available at: http://srv-norvegia:8384

# Docker services
make help  # Show available docker commands
```

### System Rebuild and Repository Management Workflow

⚠️ **Important**: After NixOS rebuilds, follow this sequence to avoid service conflicts:

```bash
# 1. Complete system rebuild first
sudo nixos-rebuild switch --flake .
sudo reboot  # if needed

# 2. Stop services before git operations to prevent conflicts
sudo systemctl stop automated-scripts
sudo systemctl stop node-server

# 3. Now safe to perform git operations
cd /home/norvegia
git clone <repository-url>
# or git pull in existing directories

# 4. Handle npm dependencies
cd project-directory
npm install  # or use 'nix develop' if available

# 5. Restart services
sudo systemctl start automated-scripts
sudo systemctl start node-server
```

**Why this is necessary**: The automated-scripts service runs npm install operations that can interfere with git clone/pull operations, causing file conflicts and failed operations.

> 📖 For detailed server management, see [srv-norvegia documentation](docs/srv-norvegia.md)

## Architecture Overview

### Host Management

The repository manages 2 distinct hosts:

- **pc-minibook**: Laptop with GNOME desktop environment
- **srv-norvegia**: Server without desktop environment

### Flake Configuration

- Uses NixOS unstable channel for latest packages
- Integrates home-manager as NixOS module
- Includes nixvim and zen-browser inputs
- Uses official nixpkgs for niri (no external flake needed)
- Helper functions `mkDesktopHost` and `mkServerHost` for different host types

### Module System

- **System modules** (`modules/system/`): Desktop environments, hardware configs, services
- **Home modules** (`modules/home/`): User applications, dotfiles, development tools
- **Overlays**: Custom package modifications (zen-browser)

### User Management

- Home-manager integrated as NixOS module
- Per-user configurations with shared modules
- Development tools distributed via `dev-tools.nix` module

## Adding New Components

### Adding New Hosts

1. Create directory in `hosts/`
2. Add hardware configuration and `default.nix`
3. Add to `flake.nix` using `mkDesktopHost` or `mkServerHost`

### Adding New Users

1. Create directory in `home/`
2. Create user-specific `default.nix`
3. Import relevant modules (dev-tools, desktop-apps, etc.)
4. Add to host configuration

### Creating Custom Modules

1. Add file in appropriate directory under `modules/`
2. Define options and configuration
3. Import where needed in host or user configs

> 🔧 For detailed examples and patterns, see [CLAUDE.md](CLAUDE.md)

## Cross-Platform Shortcuts

For users coming from Windows or working across different platforms, here are essential GNOME keyboard shortcuts to create a more uniform experience:

### GNOME Settings Configuration

To configure these shortcuts, go to **Settings > Keyboard > Keyboard Shortcuts > Custom Shortcuts** and add:

1. **File Manager Launcher** (Windows-like):

   - **Name**: Open Home Folder
   - **Command**: `nautilus`
   - **Shortcut**: `Super + E`
   - This mimics the Windows `Win + E` shortcut for opening the file explorer

2. **Window Switching** (Windows-like):

   - Go to **Settings > Keyboard > Keyboard Shortcuts > Navigation**
   - Find **"Switch windows"** and set it to `Alt + Tab`
   - Find **"Switch applications"** and disable it or set to a different shortcut
   - This makes `Alt + Tab` cycle through individual windows instead of applications

3. **Workspace Navigation**:
   - Go to **Settings > Keyboard > Keyboard Shortcuts > Navigation**
   - Set **"Switch to workspace on the right"** to `Ctrl + Alt + Right`
   - Set **"Switch to workspace on the left"** to `Ctrl + Alt + Left`
   - This provides consistent workspace switching across desktop environments

### Additional Cross-Platform Tips

- **Super Key**: The Windows/Super key opens the Activities overview (equivalent to Windows Start menu)
- **Alt + F2**: Opens the command runner (similar to Windows Run dialog)
- **Ctrl + Alt + T**: Opens terminal (consistent across most Linux distributions)

## Cross-Platform Development Setup


### Windows Development Environment (Chocolatey)

For Windows systems, use Chocolatey to install development tools that mirror the NixOS environment:

````powershell
# Modern browsers
choco install vivaldi

```powershell
# Core development tools
choco install vscode git nodejs-lts

# Advanced development tools
choco install lazygit

# File management and utilities
choco install 7zip.install googledrive syncthingtray
choco install windirstat usbimager

# Productivity applications
choco install obsidian libreoffice-fresh

# Graphics and media
choco install gimp inkscape foxitreader

# Gaming platforms (optional)
choco install steam epicgameslauncher goggalaxy
````

To install All at Once

```powershell
# Single command to install all essential packages
choco install vscode git nodejs-lts 7zip.install googledrive syncthingtray windirstat usbimager obsidian libreoffice-fresh gimp inkscape foxitreader lazygit vivaldi -y
```

> **Note**: This package list is based on the current working Windows development setup and provides feature parity with the NixOS configuration.

## Development Workflow

### Version Control

```bash
# Basic git workflow
git add .
git commit -m "description of changes"
git push
```

### SSH Configuration

**Generate SSH key** (if not already done):

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

**Add to GitHub**: Copy public key and add to GitHub Settings > SSH Keys:

```bash
cat ~/.ssh/id_ed25519.pub
```

**Copy SSH key to remote server** (e.g., to authorize pc-sviluppo on srv-norvegia):

```bash
ssh-copy-id norvegia@srv-norvegia
```

**Multiple accounts** - configure `~/.ssh/config`:

```
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519
```

## Detailed Documentation

For comprehensive guides on specific topics:

- **🔐 [Secrets Management](docs/secrets-management.md)**: Complete guide to managing encrypted secrets with agenix
- **🖥️ [Server Administration](docs/srv-norvegia.md)**: srv-norvegia specific services, networking, and troubleshooting
- **🔧 [Development Guide](CLAUDE.md)**: Configuration patterns, examples, and best practices for developers

## Key Features

- **Reproducible**: Flake lock ensures consistent builds across machines
- **Modular**: Reusable components for easy maintenance
- **Multi-host**: Support for different machine types and purposes
- **User-centric**: Home-manager integration for per-user customization
- **Performance**: Binary cache configuration for faster builds
- **Modern**: Latest NixOS practices with helper functions
- **Secure**: Encrypted secrets management with agenix

## License

This configuration is available under the MIT License. Feel free to use, modify, and distribute as needed.
