# Common configuration shared by all hosts
{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Import common system modules
  imports = [
    ../modules/system/boot.nix
    ../modules/system/locale.nix
    ../modules/system/nix.nix
    ../modules/system/fonts.nix
    ../modules/system/hardware/sound.nix
    ../modules/system/services/keyd.nix
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
    nil # Nix language server
    alejandra # Code formatter for nix
    direnv # Shell extension that manages your environment
    openssl # Cryptographic library that implements the SSL and TLS protocols

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

    # Strumenti essenziali
    ripgrep
    fd
    gnumake
    curl

    # LSP e formatter
    typescript-language-server
    prettierd
    lua-language-server
    marksman # Markdown language server
    eslint
    pyright # Python LSP
    black # Python formatter
  ];
}
