# nixos/home/acquisti/default.nix
{
  config,
  pkgs,
  neovim-config,
  ...
}: {
  imports = [
    ../default.nix
    ../../modules/home/syncthing.nix
    ../../modules/home/hyprland/base.nix
    ../../modules/home/hyprland/bluetooth.nix
    ../../modules/home/hyprland/multimonitor.nix
  ];

  # username
  home.username = "acquisti";
  home.homeDirectory = "/home/${config.home.username}";

  # User-specific packages (additional to common ones)
  home.packages = with pkgs; [
    anydesk # Remote desktop software
    insomnia # API client
  ];

  home.stateVersion = "23.11";
}
