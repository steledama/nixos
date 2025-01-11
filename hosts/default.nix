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
    ../modules/system/desktop/gnome.nix
    ../modules/system/hardware/sound.nix
    ../modules/system/boot.nix
    ../modules/system/fonts.nix
    ../modules/system/locale.nix
    ../modules/system/nix.nix
    ../modules/system/services/print.nix
  ];

  # Common system configurations
  nixpkgs.config.allowUnfree = true;

  # Common system packages
  environment.systemPackages = with pkgs; [
    git # Version control
    lazygit # Git frontend
    neovim # Terminal editor
    nixd # Nix language server
    nixfmt-rfc-style # Code formater for nix
    wget # Tool for retrieving files using HTTP, HTTPS, and FTP
    unzip # An extraction utility for archives compressed in .zip format
    usbimager # Utility to flash os iso images on usb drive
    gcc # C compiler
    lsof # Tool to list open files
    efibootmgr # utility to manage (EFI) Boot Manager
    direnv # Shell extension that manages your environment
  ];
}
