{ config, pkgs, ... }:

{
  imports = [
    ./hyprland.nix # Compositor
    ./waybar.nix # Bar
    ./dunst.nix # Notification Manager
    ./wofi.nix # App Launcher
    ./screenshots.nix # Screenshots
    ./hyprpaper.nix # Wallpaper
    ./wlogout.nix # logout manager
  ];
}
