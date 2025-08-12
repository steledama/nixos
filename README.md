# NixOS Configuration

A comprehensive NixOS configuration using flakes and home-manager for managing multiple hosts and users with a modular approach.

[![NixOS](https://img.shields.io/badge/NixOS-24.11-blue.svg?logo=nixos&logoColor=white)](https://nixos.org)
[![Nix Flakes](https://img.shields.io/badge/Nix-Flakes-blue.svg?logo=nixos&logoColor=white)](https://nixos.wiki/wiki/Flakes)
[![Home Manager](https://img.shields.io/badge/Home-Manager-blue.svg)](https://github.com/nix-community/home-manager)

## Quick Start

### Prerequisites
- Working NixOS installation with UEFI boot on GPT
- Git enabled in system configuration

### Initial Setup

1. **Enable flakes** in `/etc/nixos/configuration.nix`:
   ```nix
   nix.settings.experimental-features = ["nix-command" "flakes"];
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
   sudo nixos-rebuild switch --flake .
   ```

## Repository Structure

```
nixos/
├── flake.nix              # Main flake configuration with inputs and outputs
├── flake.lock             # Dependency lockfile
├── hosts/                 # Host-specific configurations
│   ├── default.nix        # Common host configurations
│   ├── pc-game/           # Gaming desktop configuration
│   ├── pc-minibook/       # Minibook laptop configuration
│   ├── pc-sviluppo/       # Development desktop configuration
│   └── srv-norvegia/      # Server configuration
├── home/                  # Home-manager user configurations
│   ├── acquisti/          # User: acquisti
│   ├── stefano/           # User: stefano
│   ├── stele/             # User: stele
│   └── sviluppo/          # User: sviluppo
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

# Syncthing (user service)
systemctl --user status syncthing
journalctl --user -u syncthing -f

# Docker services
make help  # Show available docker commands
```

> 📖 For detailed server management, see [srv-norvegia documentation](docs/srv-norvegia.md)

## Architecture Overview

### Host Management
The repository manages 4 distinct hosts:
- **pc-game**: Gaming desktop with Niri window manager
- **pc-minibook**: Laptop with Niri window manager  
- **pc-sviluppo**: Development desktop with GNOME
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

**Multiple accounts** - configure `~/.ssh/config`:
```
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519
```

## Detailed Documentation

For comprehensive guides on specific topics:

- **🔐 [Secrets Management](docs/gestione-segreti.md)**: Complete guide to managing encrypted secrets with agenix
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