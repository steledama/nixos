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
    ../modules/home/bash.nix
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
