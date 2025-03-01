# nixos/home/stefano/default.nix
{
  config,
  pkgs,
  neovim-config,
  ...
}: {
  imports = [
    ../default.nix
    ../../modules/home/gnome-theme.nix
    ../../modules/home/alacritty.nix
    ../../modules/home/ranger.nix
  ];

  # username
  home.username = "stefano";
  home.homeDirectory = "/home/${config.home.username}";

  # User-specific packages (additional to common ones)
  home.packages = with pkgs; [
    amule
  ];

  home.stateVersion = "23.11";
}
