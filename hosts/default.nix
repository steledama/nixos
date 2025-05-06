# nixos/hosts/default.nix
{pkgs, ...}: {
  # Import common system modules
  imports = [
    ../modules/system/zen.nix
    ../modules/system/boot.nix
    ../modules/system/nix.nix
    ../modules/system/shell.nix
    ../modules/system/fonts.nix
    ../modules/system/locale.nix # default it
    ../modules/system/hardware/keyboard.nix # default us international
    ../modules/system/hardware/sound.nix
    ../modules/system/services/print.nix
    ../modules/system/services/keyd.nix
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
    wev # Wayland event viewer

    # System management and utilities
    efibootmgr # EFI Boot Manager utility
    usbimager # OS image USB flasher
    findutils # For find command
    coreutils # For basic Unix utilities
    psmisc # Set of small useful utilities that use the proc filesystem (killall)
    zip # Compressor/archiver for creating and modifying zipfiles
    gparted # Graphical disk partitioning tool

    # Network and file
    wget # HTTP/HTTPS/FTP file retrieval
    unzip # ZIP archive extraction
    tcpdump # network sniffer
    nmap # Free and open source utility for network discovery and security auditing
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
    imagemagick # Software suite to create, edit, compose, or convert bitmap images

    # shell
    starship # Customizable prompt
    zoxide # Smarter cd command
    direnv # Environment manager
    neofetch # Fast, highly customizable system info script

    # icons
    gtk3
    hicolor-icon-theme
    adwaita-icon-theme

    # customs
    msty
    evince
  ];
}
