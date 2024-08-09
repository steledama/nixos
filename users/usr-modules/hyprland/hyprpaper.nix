{ config, pkgs, ... }:

let
  gnomeWallpaperDir = "${pkgs.gnome.gnome-backgrounds}/share/backgrounds/gnome";
in
{
  home.packages = with pkgs; [
    hyprpaper
  ];

  # Configuration for hyprpaper
  xdg.configFile."hypr/hyprpaper.conf".text = ''
    # Preload several GNOME wallpapers
    preload = ${gnomeWallpaperDir}/adwaita-day.jpg
    preload = ${gnomeWallpaperDir}/adwaita-morning.jpg
    preload = ${gnomeWallpaperDir}/adwaita-night.jpg
    
    # Set a default wallpaper for all monitors
    wallpaper = ,${gnomeWallpaperDir}/adwaita-day.jpg
    
    # Optionally, you can set different wallpapers for different times of day
    # wallpaper = ,${gnomeWallpaperDir}/adwaita-morning.jpg
    # wallpaper = ,${gnomeWallpaperDir}/adwaita-night.jpg
    
    # You can also set different wallpapers for different monitors
    # wallpaper = DP-1,${gnomeWallpaperDir}/adwaita-day.jpg
    # wallpaper = HDMI-A-1,${gnomeWallpaperDir}/adwaita-night.jpg

    ipc = off
  '';
}
