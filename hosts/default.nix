# nixos/hosts/default.nix
{pkgs, ...}: {
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
    ../modules/system/services/keyd.nix
    ../modules/system/desktop/gnome.nix
    ../modules/system/desktop/hyprland.nix
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
    rustup
    cargo
    python3
    # Language server
    nil # Nix
    lua-language-server # Lua
    typescript-language-server # Js
    pyright # python
    # Formatter
    prettierd # JavaScript
    stylua # Lua
    alejandra # Nix
    black # Python
    isort # Python
    # Linter
    eslint # JavaScript
    lua54Packages.luacheck # Lua
    nixpkgs-fmt # Nix (alternativa ad alejandra)
    pylint # Python

    # System monitoring and diagnostics
    btop # Resource monitor (CPU, memory, disks, network, processes)
    iotop # I/O usage monitoring
    lm_sensors # Hardware sensors reading
    lsof # Tool to list open files
    pciutils # Tools for inspecting PCI devices (includes lspci)

    # System management
    efibootmgr # EFI Boot Manager utility
    usbimager # OS image USB flasher

    # Network and file
    wget # HTTP/HTTPS/FTP file retrieval
    unzip # ZIP archive extraction
    tcpdump # network sniffer
    wl-clipboard # Command-line copy/paste utilities for Wayland
    xclip # Tool to access the X clipboard from a console application
    yazi # Terminal file manager
    filezilla # ftp client

    # Tools
    gnumake # Tool to control the generation of non-source files from sources
    curl # Command line tool for transferring files with URL syntax
    ripgrep # Utility that combines the usability of The Silver Searcher with the raw speed of grep
    fd # Simple, fast and user-friendly alternative to find
    fzf # Command-line fuzzy finder written in Go
    bat # Cat(1) clone with syntax highlighting and Git integration
    eza # Modern, maintained replacement for ls

    # shell
    starship # Customizable prompt
    zoxide # Smarter cd command
    direnv # Environment manager
    neofetch # Terminal system info
  ];
}
