# srv-norvegia Server Documentation

NixOS-based development and services server running containerized applications and file synchronization services.

## Services Overview

### File Synchronization (Syncthing)
**Purpose**: Central hub for project file synchronization across multiple devices  
**Web Interface**: https://5.89.62.125/syncthing/  
**Configuration**: Managed via Home Manager  

**Management Commands**:
```bash
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
```

### Automated Scripts Service
**Purpose**: Executes automated Node.js scripts daily at 4:00 AM  
**Script Location**: `/home/acquisti/bi/scripts/automated-scripts.sh`  
**Schedule**: Daily at 04:00:00  
**User**: acquisti  

**Management Commands**:
```bash
sudo systemctl status automated-scripts
sudo journalctl -u automated-scripts -f
sudo systemctl start automated-scripts
```

### Node Server
**Purpose**: Runs server.js listening on port 3001 for data exchange between management software and websites  

**Management Commands**:
```bash
sudo systemctl status node-server
sudo systemctl start node-server
sudo systemctl stop node-server
sudo systemctl restart node-server
sudo journalctl -u node-server -f
sudo journalctl -u node-server --since "2 hours ago"
```

### Docker Services
**Purpose**: Web services managed through docker-compose with Makefile automation  
**User**: acquisti (member of docker group)  
**Configuration**: Auto-pruning enabled (weekly cleanup)  

**Management Commands**:
```bash
make help  # Show available commands
```

## Network Configuration

### Firewall Ports
| Port | Service | Purpose |
|------|---------|---------|
| 22   | SSH     | Remote administration |
| 80   | HTTP    | Nginx web server |
| 443  | HTTPS   | Nginx web server (SSL) |
| 3001 | Node Server | Management data exchange |
| 8384 | Syncthing | File synchronization web UI |
| 8385 | Baserow | Database service |
| 8443 | ToscanaTrading | Business application |
| 8444 | Flexora | Business application |

### SMB Network Shares
**Purpose**: Windows network shares mounted for legacy system integration  

**Configured Shares**:
- Scan Share: `//10.40.40.98/scan` → `/mnt/scan`
- Manuals Share: `//10.40.40.98/manuali` → `/mnt/manuali`
- Credentials: Managed by agenix (`config.age.secrets.smb-secrets.path`)

## User Configuration

**Primary User**: acquisti  
**Groups**: networkmanager, wheel, libvirtd, video, docker  
**Home Directory**: `/home/acquisti`  
**Shell**: ZSH (system default)  

## System Management

### NixOS Configuration
```bash
sudo nixos-rebuild switch --flake .
nix flake update
sudo nix-collect-garbage -d
```

### Service Monitoring
```bash
systemctl list-units --type=service --state=running
btop
ping google.com
```

## Maintenance Notes

- System uses NixOS unstable channel
- Home Manager manages user configurations  
- Docker containers auto-prune weekly
- Automated scripts run daily at 4 AM
- SMB credentials stored in user directory (excluded from git)

## Troubleshooting

### Common Issues

**ALSA Store Error**:
```bash
sudo mkdir -p /var/lib/alsa
sudo touch /var/lib/alsa/asound.state
sudo chmod 644 /var/lib/alsa/asound.state
sudo chown root:root /var/lib/alsa/asound.state
sudo alsactl store
```

**Service Status Check**:
```bash
# Check all running services
systemctl --failed
systemctl list-units --state=failed
```

**Log Analysis**:
```bash
# System logs
journalctl --since "1 hour ago"
journalctl -f

# Specific service logs
journalctl -u service-name --since "24 hours ago"
```