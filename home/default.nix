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
    ../modules/home/wezterm.nix
    ../modules/home/neovim.nix
    ../modules/home/ui-theme.nix
    ../modules/home/yazi.nix
    ../modules/home/hyprland.nix
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
