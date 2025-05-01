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
    ../../modules/home/niri.nix
  ];
  # User
  home.username = "stele";
  home.homeDirectory = "/home/${config.home.username}";

  # Setup WMs (default us keyboard)
  wayland-wm = {
    enable = true;
    # Wallpaper (To find the correct output names for each system, you should run wlr-randr or niri msg outputs when running Niri to see the available outputs.)
    wallpaper = {
      outputColors = {
        "DS-1" = "#000000";
        # "DP-2" = "#660033";
      };
    };
  };

  # User-specific packages (additional to common ones)
  home.packages = with pkgs; [
  ];

  home.stateVersion = "23.11";
}
