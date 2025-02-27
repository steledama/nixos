# nixos/home/acquisti/default.nix

{
  config,
  pkgs,
  nvim-config,
  ...
}:

{
  imports = [
    ../default.nix
    ../../modules/home/gnome-theme.nix
    ../../modules/home/zsh.nix
    ../../modules/home/alacritty.nix
    ../../modules/home/tmux.nix
    ../../modules/home/ranger.nix
    ../../modules/home/syncthing.nix
    ../../modules/home/neovim.nix
  ];

  # username
  home.username = "acquisti";
  home.homeDirectory = "/home/${config.home.username}";

  # User-specific packages (additional to common ones)
  home.packages = with pkgs; [
    anydesk # Remote desktop software
    insomnia # API client

    # keyboard driven workflow utilities
    fzf
    bat
    ripgrep
    eza
  ];

  home.stateVersion = "23.11";
}
