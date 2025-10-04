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

# Clean bootloader entries
sudo /run/current-system/bin/switch-to-configuration boot
sudo nvim /boot/loader/loader.conf
```

### Production Update Workflow (srv-norvegia)

For production environments, follow this safe update procedure to minimize service disruption:

**Step 1: Prepare for update**
```bash
# Verify current service status
cd /home/norvegia/nixos/compose
make status
sudo systemctl status scriptsauto controlp

# Stop Docker services gracefully
make down-all

# Stop Node.js services
sudo systemctl stop scriptsauto
sudo systemctl stop controlp
```

**Step 2: Update and rebuild**
```bash
# Update flake inputs (optional)
cd /home/norvegia/nixos
nix flake update

# Rebuild using boot mode (safer for production)
sudo nixos-rebuild boot --flake .
```

**Step 3: Apply changes and restart**
```bash
# Schedule reboot (apply changes)
sudo reboot
```

**Step 4: Post-reboot verification**

*Automated checks (no root required):*
```bash
# 1. Verify Docker services
cd /home/norvegia/nixos/compose && make status

# 2. Verify user service
systemctl --user status syncthing
```

*Manual verification (requires sudo):*
```bash
# 3. Verify Node.js system services
sudo systemctl status scriptsauto controlp

# 4. Check for failed services system-wide
systemctl --failed
```

**Notes:**
- `scriptsauto` shows `inactive (dead)` when not running - this is normal (timer-based, executes at 4:00 AM)
- Check `scriptsauto.timer` status to verify schedule: `sudo systemctl status scriptsauto.timer`

**Quick update (development/testing only)**
```bash
# For non-critical updates, direct switch is acceptable:
sudo nixos-rebuild switch --flake .
# Note: Docker will restart automatically, containers may experience brief downtime
```

**Best Practices:**
- ✅ Always use `boot` mode for production updates
- ✅ Stop Docker containers gracefully before rebuild
- ✅ Plan updates during low-traffic periods
- ✅ Verify all services after reboot
- ⚠️ Use `switch` mode only for development/testing or minor config changes

### Host-Specific Commands

The repository manages 2 hosts:

- `pc-minibook`: Laptop with GNOME desktop environment
- `srv-norvegia`: Server without desktop environment

### Service Management (srv-norvegia)

#### Syncthing (File Synchronization)
**Purpose**: Central hub for project file synchronization across devices
**Web Interface**: http://srv-norvegia:8384 or https://5.89.62.125/syncthing/

```bash
# Service management
systemctl --user status syncthing
systemctl --user restart syncthing
systemctl --user stop syncthing
systemctl --user start syncthing

# Service logs
journalctl --user -u syncthing -f
journalctl --user -u syncthing --since "2 hours ago"

# Enable/disable auto start
systemctl --user enable syncthing
systemctl --user disable syncthing

# Enable linger to prevent service timeout (run once after setup)
sudo loginctl enable-linger norvegia
```

#### Automated Scripts Service (scriptsauto)
**Purpose**: Executes automated Node.js scripts daily at 4:00 AM
**Script Location**: `/home/norvegia/bi/scripts/scripts-auto.sh`
**Schedule**: Daily at 04:00:00
**User**: norvegia

```bash
sudo systemctl status scriptsauto
sudo systemctl start scriptsauto
sudo journalctl -u scriptsauto -f
sudo journalctl -u scriptsauto --since "24 hours ago"
```

#### Control Panel Server (controlp)
**Purpose**: Runs server.js listening on port 3001 for data exchange between management software and websites

```bash
sudo systemctl status controlp
sudo systemctl start controlp
sudo systemctl stop controlp
sudo systemctl restart controlp
sudo journalctl -u controlp -f
sudo journalctl -u controlp --since "2 hours ago"
```

#### Docker Services
**Purpose**: Web services managed through docker-compose with Makefile automation
**User**: norvegia (member of docker group)
**Configuration**: Auto-pruning enabled (weekly cleanup)

```bash
cd /home/norvegia/nixos/compose
make help     # Show available commands
make up-all   # Start all services
make status   # View running services
```

### Docker Compose Infrastructure

**🐳 Docker infrastructure migrated from [BI repository](https://github.com/steledama/bi)**

All Docker services for Business Intelligence system are managed in `compose/` directory:

```bash
# Navigate to compose directory
cd /home/norvegia/nixos/compose

# Start all services
make up-all

# Stop all services
make down-all

# View service status
make status

# Show all available commands
make help
```

**Directory Structure**:
```
compose/
├── .env                     # Infrastructure credentials (gitignored)
├── .env.example            # Template with documentation
├── compose.baserow.yml     # Baserow database
├── compose.toscana.yml     # Toscana Trading WordPress
├── compose.flexora.yml     # Flexora WordPress
├── compose.nginx.yml       # Nginx reverse proxy
├── compose.n8n.yml         # n8n automation (experimental)
├── compose.librechat.yml   # LibreChat (experimental)
├── Makefile                # Command shortcuts
└── nginx/                  # Nginx configuration files
```

**Configuration Files**:
- `.env` (gitignored): Contains DB passwords, SMTP credentials, ports
- `.env.example` (versionato): Template with detailed comments
- Business logic credentials: See `/home/norvegia/bi/.env`

**Services**:
- **Baserow**: http://5.89.62.125:8385 (low-code database)
- **Toscana Trading**: https://5.89.62.125:8443 (WordPress/WooCommerce)
- **Flexora**: https://5.89.62.125:8444 (WordPress/WooCommerce)
- **n8n**, **LibreChat**: Experimental, not in production

**First Setup**:
```bash
cd /home/norvegia/nixos/compose
cp .env.example .env
# Edit .env with real credentials
make up-all
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

**NixOS-based development and services server** running containerized applications and file synchronization.

**Infrastructure:**
- Docker services via compose (Baserow, WordPress/WooCommerce sites)
- Node.js applications with automated service management
- Syncthing for file synchronization (user service via home-manager)
- SMB network shares for legacy system integration
- Nginx reverse proxy with SSL

**Network Configuration:**

| Port | Service | Purpose |
|------|---------|---------|
| 22   | SSH     | Remote administration |
| 80   | HTTP    | Nginx web server |
| 443  | HTTPS   | Nginx web server (SSL) |
| 3001 | Control Panel | Management data exchange |
| 8384 | Syncthing | File sync web UI |
| 8385 | Baserow | Database service |
| 8443 | ToscanaTrading | Business application |
| 8444 | Flexora | Business application |

**SMB Network Shares:**
- Scan: `//10.40.40.98/scan` → `/mnt/scan`
- Manuals: `//10.40.40.98/manuali` → `/mnt/manuali`
- Credentials: `/home/norvegia/.smb-credentials` (gitignored)

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
# Linux/macOS
ssh-copy-id norvegia@srv-norvegia

# Windows PowerShell
Get-Content ~/.ssh/id_ed25519.pub | ssh norvegia@srv-norvegia "cat >> ~/.ssh/authorized_keys"
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
   sudo systemctl stop scriptsauto
   sudo systemctl stop controlp
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
   sudo systemctl start scriptsauto
   sudo systemctl start controlp
   ```

### Common Issues and Solutions

**Service Interference with Git Operations**:

- **Problem**: scriptsauto service runs npm install during git clone operations, causing conflicts
- **Solution**: Always stop scriptsauto and controlp services before git clone/pull operations
- **Detection**: Look for "error: the following files have changes" during git operations

**npm Install Failures in NixOS**:

- **Problem**: Missing system dependencies (tar, build tools) for native modules
- **Solution**: Use `nix develop` environment or ensure system packages include necessary build tools
- **Common missing**: tar, gcc, python3, node-gyp dependencies

**SSH Host Key Verification**:

- **Problem**: Host key changes after system rebuild cause SSH connection failures
- **Solution**: Remove old host keys with `ssh-keygen -R <hostname>` and `ssh-keygen -R <ip>`
- **Prevention**: Document host key fingerprints for verification

### System Monitoring and Troubleshooting

#### Service Status Checks
```bash
# Check all running services
systemctl list-units --type=service --state=running
systemctl --failed
systemctl list-units --state=failed

# System monitoring
btop
ping google.com
```

#### Log Analysis
```bash
# System logs
journalctl --since "1 hour ago"
journalctl -f

# Specific service logs
journalctl -u service-name --since "24 hours ago"
```

#### Common Issues

**ALSA Store Error**:
```bash
sudo mkdir -p /var/lib/alsa
sudo touch /var/lib/alsa/asound.state
sudo chmod 644 /var/lib/alsa/asound.state
sudo chown root:root /var/lib/alsa/asound.state
sudo alsactl store
```

**Syncthing Service Recovery**:
If user service goes into timeout/sleep mode, linger should already be enabled. If issues persist:
```bash
# Verify linger status
loginctl show-user norvegia | grep Linger

# Re-enable if needed
sudo loginctl enable-linger norvegia

# Restart service
systemctl --user restart syncthing
```

## Important Notes

- All configurations are declarative and reproducible
- Use `sudo nixos-rebuild switch --flake .` from the repository root
- **Always stop automated services before git operations to prevent conflicts**
- Service configurations support both development and production environments
- Secrets managed via traditional file-based approach (`.smb-credentials`, `.env` files)
- Docker services auto-prune weekly on server configurations
- **After major rebuilds, expect to resolve SSH host key verification issues**

## Automation Limitations

**Commands requiring sudo password cannot be automated via Claude Code:**
- `sudo nixos-rebuild switch/boot --flake .`
- `sudo systemctl status/start/stop/restart <service>`
- `systemctl --failed` (system-wide check)
- Any command requiring root privileges

**Commands that CAN be automated (no sudo required):**
- Docker operations: `cd /home/norvegia/nixos/compose && make status/up-all/down-all`
- User services: `systemctl --user status/start/stop/restart <service>`
- Git operations: `git status/add/commit/push/pull`
- File operations: read/edit/write files in user directories
- NixOS queries: `nix flake update`, `nix-collect-garbage --delete-old`

## Maintenance Notes (srv-norvegia)

- System uses NixOS unstable channel
- Home Manager manages user configurations
- Docker containers auto-prune weekly
- Automated scripts run daily at 4 AM
- SMB credentials stored in `/home/norvegia/.smb-credentials` (gitignored)
- User: norvegia (groups: networkmanager, wheel, libvirtd, video, docker)
- Shell: ZSH (system default)
