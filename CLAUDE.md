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

The repository manages 2 hosts:
- `pc-minibook`: Laptop with GNOME desktop environment  
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

# Syncthing (user service via home-manager)
systemctl --user status syncthing
systemctl --user restart syncthing
journalctl --user -u syncthing -f

# Access Syncthing web GUI
# Web interface available at: http://srv-norvegia:8384

# Docker services
make help  # Show available docker commands
```

## Architecture Overview

### Flake Configuration
- Uses NixOS unstable channel
- Integrates home-manager as NixOS module
- Includes nixvim and zen-browser inputs
- Modular host configuration with `mkHost` helper function

### Module System
- **System modules**: Located in `modules/system/`
  - Desktop environments (GNOME)
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
- Syncthing for file synchronization (user service via home-manager)
- SMB network shares for legacy system integration
- Firewall configured for specific services (ports 22, 80, 443, 3001, 8384, etc.)

#### Syncthing Architecture
**Service Design**: Syncthing runs as a user service via home-manager:
- **User-centric**: Runs under the `norvegia` user account
- **Home-manager integration**: Configured through `modules/home/syncthing.nix`
- **Simple permissions**: Direct file access under user's home directory

**Configuration**:
- Syncthing service runs under `norvegia` user
- Configuration and data stored in `/home/norvegia/.config/syncthing/`
- Web GUI accessible at `0.0.0.0:8384` for remote management
- Service managed via systemd user session

**File Access Pattern**:
```bash
# Syncthing user service directories
/home/norvegia/.config/syncthing/    # service configuration
/home/norvegia/Sync/                 # synced folders (example)

# Service management (as norvegia user)
systemctl --user status syncthing
systemctl --user restart syncthing
```

### Desktop Features
- GNOME desktop environment on pc-minibook
- Custom keyboard shortcuts for cross-platform compatibility
- Hardware-specific optimizations per host
- Zen browser integration via overlay

## Key Configuration Patterns

### Adding New Hosts
1. **Create host directory**: `hosts/new-hostname/`
2. **Copy hardware config**: `cp /etc/nixos/hardware-configuration.nix hosts/new-hostname/hardware.nix`
3. **Create host config**: `hosts/new-hostname/default.nix`
   ```nix
   {config, ...}: {
     imports = [
       ./hardware.nix
       ../default.nix
       # Add specific modules for this host
       ../../modules/system/hardware/amd.nix  # or intel.nix
       ../../modules/system/services/ssh.nix
     ];
     
     networking.hostName = "new-hostname";
     users.users.username = {
       isNormalUser = true;
       extraGroups = ["wheel" "networkmanager"];
     };
     
     home-manager.users.username = import ../../home/username;
     system.stateVersion = "24.11";
   }
   ```
4. **Add to flake**: Update `flake.nix` nixosConfigurations
   ```nix
   new-hostname = mkDesktopHost "new-hostname";  # or mkServerHost
   ```

### Adding New Users
1. **Create user directory**: `home/new-user/`
2. **Create user config**: `home/new-user/default.nix`
   ```nix
   {inputs, ...}: {
     imports = [
       ../default.nix
       ../../modules/home/shell-config.nix
       ../../modules/home/dev-tools.nix
       ../../modules/home/desktop-apps.nix  # if desktop user
     ];
     
     home.stateVersion = "24.11";
   }
   ```
3. **Link in host config**: Add to host's `home-manager.users`

### Custom Services Examples
```nix
# Example: Adding a new systemd service
systemd.services.my-service = {
  description = "My Custom Service";
  after = ["network.target"];
  wantedBy = ["multi-user.target"];
  
  serviceConfig = {
    ExecStart = "${pkgs.nodejs}/bin/node /path/to/script.js";
    User = "myuser";
    Restart = "always";
    RestartSec = "10";
  };
};
```

### Module Creation Pattern
```nix
# modules/system/services/my-service.nix
{config, lib, pkgs, ...}: 
with lib; {
  options.services.myService = {
    enable = mkEnableOption "My Service";
    port = mkOption {
      type = types.port;
      default = 3000;
    };
  };
  
  config = mkIf config.services.myService.enable {
    # Service implementation
  };
}
```

### Secrets Management
The repository uses traditional file-based credential management for simplicity:

**SMB Credentials Example**:
Create a credentials file at `/home/user/.smb-credentials`:
```
username=your_username
password=your_password
domain=your_domain
```

Set appropriate permissions:
```bash
chmod 600 /home/user/.smb-credentials
chown user:user /home/user/.smb-credentials
```

**SSH Key Management**:
SSH keys are managed manually for simplicity and reliability:

**Generate SSH key** (if not already done):
```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

**Add to GitHub**: Copy public key and add to GitHub Settings > SSH Keys:
```bash
cat ~/.ssh/id_ed25519.pub
```

**Copy SSH key to remote server** (e.g., to authorize pc-minibook on srv-norvegia):
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

- SSH config is managed by home-manager for convenience
- After system reinstalls, regenerate keys and re-authorize them


## System Reinstallation Workflow

### Critical Steps After NixOS Rebuild (srv-norvegia)

When performing initial system setup or major rebuilds, follow this sequence to avoid service conflicts:

1. **Complete NixOS rebuild first**:
   ```bash
   sudo nixos-rebuild switch --flake .
   sudo reboot  # if needed
   ```

2. **Stop interfering services before git operations**:
   ```bash
   # Stop services that may interfere with git clone/npm install
   sudo systemctl stop automated-scripts
   sudo systemctl stop node-server
   # Note: Keep syncthing running unless specific conflicts occur
   ```

3. **Perform git operations**:
   ```bash
   # Now safe to clone/pull repositories
   git clone <repository-url>
   # or git pull in existing directories
   ```

4. **Handle npm dependencies in NixOS environment**:
   ```bash
   # Use nix develop if available, or ensure build tools are accessible
   cd project-directory
   npm install
   ```

5. **Restart services**:
   ```bash
   sudo systemctl start automated-scripts
   sudo systemctl start node-server
   ```

### Common Issues and Solutions

**Service Interference with Git Operations**:
- **Problem**: automated-scripts service runs npm install during git clone operations, causing conflicts
- **Solution**: Always stop automated-scripts and node-server services before git clone/pull operations
- **Detection**: Look for "error: the following files have changes" during git operations

**npm Install Failures in NixOS**:
- **Problem**: Missing system dependencies (tar, build tools) for native modules
- **Solution**: Use `nix develop` environment or ensure system packages include necessary build tools
- **Common missing**: tar, gcc, python3, node-gyp dependencies

**SSH Host Key Verification**:
- **Problem**: Host key changes after system rebuild cause SSH connection failures
- **Solution**: Remove old host keys with `ssh-keygen -R <hostname>` and `ssh-keygen -R <ip>`
- **Prevention**: Document host key fingerprints for verification

### Syncthing Service Recovery

**User Service Timeout Prevention**:
User services may go into timeout/sleep mode. Enable linger to keep services active:
```bash
# Enable linger for the user (run once after system setup)
sudo loginctl enable-linger norvegia

# Verify linger status
loginctl show-user norvegia | grep Linger
```

**Service Restart** (if needed after directory conflicts):
```bash
systemctl --user stop syncthing
systemctl --user start syncthing
# Verify GUI accessibility at http://srv-norvegia:8384
```

## Important Notes

- All configurations are declarative and reproducible
- Use `sudo nixos-rebuild switch --flake .` from the repository root
- **Always stop automated services before git operations to prevent conflicts**
- Service configurations support both development and production environments
- Secrets are managed securely with agenix encryption (no plain text credentials)
- Docker services auto-prune weekly on server configurations
- **After major rebuilds, expect to resolve SSH host key verification issues**