# NixOS Configuration

A comprehensive NixOS configuration using flakes and home-manager for managing multiple hosts and users with a modular approach.

[![NixOS](https://img.shields.io/badge/NixOS-24.11%20(unstable)-blue.svg?logo=nixos&logoColor=white)](https://nixos.org)
[![Nix Flakes](https://img.shields.io/badge/Nix-Flakes-blue.svg?logo=nixos&logoColor=white)](https://nixos.wiki/wiki/Flakes)
[![Hosts](https://img.shields.io/badge/Hosts-2-green.svg)](#host-management)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](#license)

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
│   └── srv-norvegia/      # Server configuration
├── home/                  # Home-manager user configurations
│   ├── norvegia/          # User: norvegia
│   └── stele/             # User: stele
├── modules/               # Reusable system and user modules
│   ├── home/              # Home-manager modules
│   └── system/            # System-level modules
└── compose/               # 🐳 Docker infrastructure (srv-norvegia)
    ├── compose.*.yml      # Service definitions
    ├── Makefile           # Management commands
    ├── .env.example       # Configuration template
    └── nginx/             # Nginx configuration
```

### Docker Services (srv-norvegia)

Docker infrastructure for Business Intelligence system (migrated from [bi repository](https://github.com/steledama/bi)):

```bash
cd compose/
make up-all      # Start all services
make status      # View services and URLs
```

**Services**: Baserow (database), WordPress/WooCommerce sites, nginx reverse proxy

📋 **Full documentation**: See [`CLAUDE.md`](CLAUDE.md#docker-compose-infrastructure)

## Common Commands

### System Management

```bash
# Update and rebuild
nix flake update
sudo nixos-rebuild switch --flake .

# Cleanup
nix-collect-garbage --delete-old && sudo nix-collect-garbage -d
# Additional system cleanup as needed
```

### Service Management

For detailed service management on srv-norvegia, see srv-norvegia documentation in the docs directory.

**Main Services:**
- `scriptsauto`: Automated Node.js scripts execution (daily at 4 AM)
- `controlp`: Node.js control panel server

### Development Workflow

**Basic Git Commands:**
```bash
git add . && git commit -m "description" && git push
```

For detailed SSH setup, multi-account configuration, and advanced workflows, see the development guide.

## Architecture Overview

### Host Management

The repository manages 2 distinct hosts:

- **pc-minibook**: Laptop with GNOME desktop environment
- **srv-norvegia**: Server without desktop environment

### Flake Configuration

- Uses NixOS unstable channel for latest packages
- Integrates home-manager as NixOS module

### Module System

- **System modules** (`modules/system/`): Desktop environments, hardware configs, services
- **Home modules** (`modules/home/`): User applications, dotfiles, development tools

### User Management

- Home-manager integrated as NixOS module
- Per-user configurations with shared modules
- Development tools distributed via `dev-tools.nix` module

## Extending the Configuration

For adding new hosts, users, or custom modules, see detailed guides and examples in the development documentation.


## Detailed Documentation

For comprehensive guides on specific topics, see the documentation files in the repository:

- **🖥️ Server Administration**: srv-norvegia specific services, networking, and troubleshooting
- **🔧 Development Guide**: Configuration patterns, examples, and best practices for developers

## Key Features

- **Reproducible**: Flake lock ensures consistent builds across machines
- **Modular**: Reusable components for easy maintenance
- **Multi-host**: Support for different machine types and purposes
- **User-centric**: Home-manager integration for per-user customization
- **Performance**: Binary cache configuration for faster builds
- **Modern**: Latest NixOS practices and clean configuration structure
- **Secure**: Traditional file-based credential management

## Cross-Platform Setup

### GNOME Shortcuts for Cross-Platform Users

For users coming from Windows, configure these GNOME shortcuts in **Settings > Keyboard > Keyboard Shortcuts**:

- **File Manager**: `Super + E` → `nautilus` (mimics Windows Win + E)
- **Window Switching**: Set "Switch windows" to `Alt + Tab` (cycle individual windows)
- **Workspace Navigation**: `Ctrl + Alt + Left/Right` for workspace switching

### Windows Development Environment (Chocolatey)

For Windows systems, install development tools that mirror the NixOS environment:

```powershell
# Essential packages
choco install vscode git nodejs-lts 7zip.install googledrive syncthingtray windirstat usbimager obsidian libreoffice-fresh gimp inkscape foxitreader lazygit vivaldi -y
```

## License

This configuration is available under the MIT License. Feel free to use, modify, and distribute as needed.
