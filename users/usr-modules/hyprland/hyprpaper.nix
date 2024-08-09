{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    hyprpaper
  ];

  # Configuration for hyprpaper
  xdg.configFile."hypr/hyprpaper.conf".text = ''
    ipc = off
  '';
}
