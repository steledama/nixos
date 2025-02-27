{ config, pkgs, ... }:

{
  # Import common configurations
  imports = [
    ../default.nix
    ../../modules/home/syncthing.nix
    ../../modules/home/gnome-theme.nix
    ../../modules/home/zsh.nix
    ../../modules/home/tmux.nix
    ../../modules/home/kitty.nix
    ../../modules/home/ranger.nix
  ];

  # User-specific packages (additional to common ones)
  home.packages = with pkgs; [
    anydesk # Remote desktop software
    insomnia # API client
    # keyboard driven workflow
    kitty
    wezterm
    tmux
    ranger
    fzf
    bat
    ripgrep
    eza
  ];

  # username
  home.username = "acquisti";
  home.homeDirectory = "/home/${config.home.username}";

  # dotfiles in ~/.config
  xdg.configFile = {
    "nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/nvim";
  };

  home.stateVersion = "23.11";
}
