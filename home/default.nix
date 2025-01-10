# Common configuration shared by all users
{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Import common home modules
  imports = [
    ../modules/home/shell/bash.nix
    ../modules/home/desktop/cursor.nix
    ../modules/home/desktop/syncthing.nix
  ];

  # Enable unfree packages
  nixpkgs.config.allowUnfree = true;

  # Common packages for all users
  home.packages = with pkgs; [
    # Browsers
    firefox
    google-chrome

    # Office and productivity
    libreoffice
    thunderbird
    obsidian

    # Design tools
    gimp
    inkscape

    # Development
    vscode

    # System utilities
    filezilla
    alacritty
    neofetch
    starship
  ];

  # Common editor configuration
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # Enable home-manager itself
  programs.home-manager = {
    enable = true;
  };
}
