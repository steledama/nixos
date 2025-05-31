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
    ../modules/home/yazi.nix
    ../modules/home/zed.nix
  ];

  # Common packages for all users
  home.packages = with pkgs; [
    # Browsers
    firefox # web browser
    zen-browser # alternative browser
    google-chrome # web browser by google
    libreoffice # productivity suite
    thunderbird # email client
    obsidian # knowledge base
    inkscape # vector graphics editor
    ghostty # terminal emulator
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
