# nixos/hosts/default.nix
{pkgs, ...}: {
  # Import common system modules (server-oriented)
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

  # Common system packages (server-oriented)
  environment.systemPackages = with pkgs; [
    # Development tools
    git # Version control
    lazygit # Git TUI frontend
    gcc # C compiler
    direnv # Shell extension that manages your environment
    openssl # Cryptographic library that implements the SSL and TLS protocols
    # Base
    nodejs # Event-driven I/O framework for the V8 JavaScript engine
    rustup # Rust toolchain installer
    cargo # Downloads your Rust project's dependencies and builds your project
    python3 # High-level dynamically-typed programming language
    # Language server
    nil # Nix
    nixd # Nix
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
    findutils # For find command
    coreutils # For basic Unix utilities
    psmisc # Set of small useful utilities that use the proc filesystem (killall)
    zip # Compressor/archiver for creating and modifying zipfiles

    # Network and file
    wget # HTTP/HTTPS/FTP file retrieval
    unzip # ZIP archive extraction
    tcpdump # network sniffer
    ncurses # Free software emulation of curses in SVR4 and more
    nmap # Free and open source utility for network discovery and security auditing
    wl-clipboard # Command-line copy/paste utilities for Wayland
    xclip # Tool to access the X clipboard from a console application
    yazi # Terminal file manager

    # Tools
    gnumake # Tool to control the generation of non-source files from sources
    curl # Command line tool for transferring files with URL syntax
    ripgrep # Utility that combines the usability of The Silver Searcher with the raw speed of grep
    fzf # Command-line fuzzy finder written in Go
    imagemagick # Software suite to create, edit, compose, or convert bitmap images

    # shell
    starship # Customizable prompt
    zoxide # Smarter cd command
    direnv # Environment manager
    neofetch # Fast, highly customizable system info script

    # icons (minimal for CLI apps that might need them)
    hicolor-icon-theme # Default fallback theme used by implementations of the icon theme specification
    adwaita-icon-theme
  ];
}
