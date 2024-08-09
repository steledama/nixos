{ config, pkgs, ... }:

let
  gnomeWallpaperDir = "${pkgs.gnome.gnome-backgrounds}/share/backgrounds/gnome";
in
{
  # Install hyprpaper and gnome-backgrounds at system level
  environment.systemPackages = with pkgs; [
    hyprpaper
    gnome.gnome-backgrounds
  ];

  # Create a system-wide configuration for hyprpaper
  environment.etc."hypr/hyprpaper.conf".text = ''
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
