# nixos/hosts/default.nix
{
  config,
  lib,
  pkgs,
  ...
}: {
  # Import common system modules
  imports = [
    ../modules/system/zen.nix
    ../modules/system/boot.nix
    ../modules/system/locale.nix
    ../modules/system/nix.nix
    ../modules/system/shell.nix
    ../modules/system/fonts.nix
    ../modules/system/hardware/sound.nix
    ../modules/system/services/print.nix
    ../modules/system/desktop/gnome.nix
  ];

  # Common system configurations
  nixpkgs.config.allowUnfree = true;

  # Common system packages
  environment.systemPackages = with pkgs; [
    # Development tools
    git # Version control
    lazygit # Git TUI frontend
    gcc # C compiler
    direnv # Shell extension that manages your environment
    openssl # Cryptographic library that implements the SSL and TLS protocols
     # Base
    nodejs
    python3
    # Language server
    nil # Nix
    lua-language-server # Lua
    typescript-language-server # Js
    pyright # python
    # Formatter
    prettierd        # JavaScript
    stylua           # Lua
    alejandra        # Nix
    black            # Python
    isort            # Python
    # Linter
    eslint           # JavaScript
    lua54Packages.luacheck         # Lua
    nixpkgs-fmt      # Nix (alternativa ad alejandra)
    pylint           # Python
    
    # System monitoring and diagnostics
    btop # Resource monitor (CPU, memory, disks, network, processes)
    iotop # I/O usage monitoring
    lm_sensors # Hardware sensors reading
    lsof # Tool to list open files
    pciutils # Tools for inspecting PCI devices (includes lspci)

    # System management
    efibootmgr # EFI Boot Manager utility
    usbimager # OS image USB flasher

    # Network and file utilities
    wget # HTTP/HTTPS/FTP file retrieval
    unzip # ZIP archive extraction
    tcpdump

    # System tools
    gnumake
    curl
    ripgrep
    fd
    fzf
    bat
    eza
  ];
}
