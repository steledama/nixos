# nixos/home/default.nix
{
  pkgs,
  inputs,
  ...
}: {
  # Import common home modules
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
    ../modules/home/shell-config.nix
    ../modules/home/neovim.nix
    ../modules/home/alacritty.nix
    ../modules/home/yazi.nix
    ../modules/home/vscodium.nix
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
    # editor
    zed-editor
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
