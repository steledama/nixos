# nixos/home/default.nix
{
  config,
  lib,
  pkgs,
  ...
}: {
  # Import common home modules
  imports = [
    ../modules/home/shell-config.nix
    ../modules/home/neovim.nix
  ];

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
