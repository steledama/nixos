# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## NixOS Configuration Structure

This is a comprehensive NixOS configuration repository using flakes and home-manager for managing multiple hosts and users. The configuration follows a modular approach with clear separation of concerns.

### Repository Structure

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

## Common Development Commands

### System Management

```bash
# Update flake inputs
nix flake update

# Rebuild and switch to new configuration
sudo nixos-rebuild switch --flake .

# Rebuild for specific host (if hostname differs)
sudo nixos-rebuild switch --flake .#hostname

# Rebuild but don't switch until reboot
sudo nixos-rebuild boot --flake .

# Garbage collection
nix-collect-garbage --delete-old
sudo nix-collect-garbage -d

# Clean bootloader entries (aliased as gcCleanup)
gcCleanup
```

### Host-Specific Commands

The repository manages 4 hosts:
- `pc-game`: Gaming desktop with Niri window manager
- `pc-minibook`: Laptop with Niri window manager  
- `pc-sviluppo`: Development desktop with GNOME
- `srv-norvegia`: Server without desktop environment

### Service Management (srv-norvegia)

```bash
# Node.js server service
sudo systemctl status node-server
sudo systemctl restart node-server
sudo journalctl -u node-server -f

# Automated scripts service
sudo systemctl status automated-scripts
sudo journalctl -u automated-scripts -f

# Syncthing (user service)
systemctl --user status syncthing
systemctl --user restart syncthing
journalctl --user -u syncthing -f

# Docker services
make help  # Show available docker commands
```

## Architecture Overview

### Flake Configuration
- Uses NixOS unstable channel
- Integrates home-manager as NixOS module
- Includes nixvim and zen-browser inputs
- Uses official nixpkgs for niri (no external flake needed)
- Modular host configuration with `mkHost` helper function

### Module System
- **System modules**: Located in `modules/system/`
  - Desktop environments (GNOME, Hyprland, Niri)
  - Hardware configurations (AMD, Intel, NVIDIA)
  - Services (Docker, SSH, SMB, etc.)
- **Home modules**: Located in `modules/home/`
  - Applications and dotfiles
  - Desktop applications and window managers
  - Development tools and shell configurations

### User Management
- Home-manager integrated as NixOS module
- Per-user configurations in `home/` directory
- Shared modules for common configurations

### Server Configuration (srv-norvegia)
- Runs containerized services via Docker
- Node.js applications with automated service management
- Syncthing for file synchronization
- SMB network shares for legacy system integration
- Firewall configured for specific services (ports 22, 80, 443, 3001, 8384, etc.)

### Desktop Features
- Multi-desktop environment support (GNOME, Hyprland, Niri)
- Niri uses official nixpkgs package (fast, pre-compiled)
- Custom keyboard shortcuts for cross-platform compatibility
- Hardware-specific optimizations per host
- Zen browser integration via overlay

## Key Configuration Patterns

### Adding New Hosts
1. Create directory in `hosts/`
2. Add hardware configuration
3. Create `default.nix` with host-specific settings
4. Add to `flake.nix` nixosConfigurations

### Adding New Users
1. Create directory in `home/`
2. Create user-specific `default.nix`
3. Import in host configuration

### Custom Services
- Node.js services use flake-aware wrappers
- Automatic dependency management with npm
- Systemd integration with proper security settings
- Environment variables and path management

### Secrets Management
The repository uses `agenix` for secure secrets management:
- Secrets are encrypted and stored safely in the `secrets/` directory
- Each host must be configured with `age.identityPaths` and secret definitions
- Use `nix-shell -p agenix --run "agenix -e <secret-file>"` to encrypt secrets
- Runtime secrets are available in `/run/secrets/` on target hosts
- See `docs/gestione-segreti.md` for detailed usage instructions

## Important Notes

- All configurations are declarative and reproducible
- Use `sudo nixos-rebuild switch --flake .` from the repository root
- Service configurations support both development and production environments
- Secrets are managed securely with agenix encryption (no plain text credentials)
- Docker services auto-prune weekly on server configurations