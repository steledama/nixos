# nixos/home/stele/default.nix
{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../default.nix
    ../../modules/home/wm.nix
  ];
  # User
  home.username = "stele";
  home.homeDirectory = "/home/${config.home.username}";

  # Setup WMs with keyboard configuration
  wayland-wm = {
    enable = true;
    enableHyprland = false;
    enableNiri = true;
  };

  # User-specific packages (additional to common ones)
  home.packages = with pkgs; [
  ];

  home.stateVersion = "23.11";
}
