{ config, pkgs, ... }:

let
  wallpaperDir = "${config.home.homeDirectory}/.config/hypr/wallpapers";
in
{
  home.packages = with pkgs; [
    hyprpaper
  ];

  # Copy wallpapers to .config/hypr/wallpapers
  home.file.".config/hypr/wallpapers" = {
    source = ./wallpapers;
    recursive = true;
  };

  # Configuration for hyprpaper
  xdg.configFile."hypr/hyprpaper.conf".text = ''
    ipc = off
    preload = ${wallpaperDir}/
    # We don't set a static wallpaper here, as it will be managed by the script
  '';
}
