# nixos/home/stefano/default.nix
{
  config,
  pkgs,
  neovim-config,
  ...
}: {
  imports = [
    ../default.nix
    ../../modules/home/zsh.nix
    ../../modules/home/alacritty.nix
    ../../modules/home/tmux.nix
    ../../modules/home/ranger.nix
    ../../modules/home/gnome-theme.nix
  ];

  # username
  home.username = "stefano";
  home.homeDirectory = "/home/${config.home.username}";

  # User-specific packages (additional to common ones)
  home.packages = with pkgs; [
  ];

  home.stateVersion = "23.11";
}
