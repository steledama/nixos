{ config, pkgs, ... }:

{
  # Import common configurations
  imports = [
    ../default.nix
    ../../modules/home/gnome-theme.nix
  ];

  # User-specific packages (additional to common ones)
  home.packages = with pkgs; [
    kitty
    wezterm
    tmux
    ranger
  ];

  # username
  home.username = "stefano";
  home.homeDirectory = "/home/${config.home.username}";

  # dotfiles in ~/.config
  xdg.configFile = {
    "nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/nvim";
    "kitty".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/kitty";
    "ranger".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/ranger";
    "wezterm".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/wezterm";
    "tmux".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/tmux";
  };

  # dotfiles outside ~/.config
  # home.file = {
  #   ".tmux.conf".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/tmux/tmux.conf";
  #   ".wezterm.lua".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/wezterm/wezterm.lua";
  # };

  home.stateVersion = "23.11";
}
