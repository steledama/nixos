{ config, pkgs, ... }:

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
    # preload = ~/.config/hypr/wallpapers/mountain.jpeg
    # preload = ~/.config/hypr/wallpapers/mountainDark.jpg  
    # preload = ~/.config/hypr/wallpapers/nixLogo.png 
    preload = ~/.config/hypr/wallpapers/rainNight.png 

    # if more than one preload is desired then continue to preload other backgrounds
    # preload = /path/to/next_image.png
    # .. more preloads

    # set the default wallpaper(s) seen on initial workspace(s) --depending on the number of monitors used
    # Get list of monitors via `htprctl monitors`
    wallpaper = eDP-1,~/.config/hypr/wallpapers/rainNight.png
    # wallpaper = HDMI-A-2,~/.config/hypr/wallpapers/rainNight.png
    # wallpaper = HDMI-A-1,~/.config/hypr/wallpapers/rainNight.png
    # if more than one monitor in use, can load a 2nd image
    # wallpaper = monitor2,/path/to/next_image.png
    # .. more monitors

    #enable splash text rendering over the wallpaper
    splash = true

    #fully disable ipc, if on it might lead to worse battery life
    ipc = off
  '';
}
