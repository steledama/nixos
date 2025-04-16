# modules/home/gnome-extensions.nix
# Configuration for GNOME Shell extensions
{ pkgs, config, lib, ... }:

{
  # Enable GNOME Shell extensions in home-manager
  dconf.settings = {
    # Enable GNOME Shell extensions
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "screen-rotate@nathan818fr"  # For manual screen rotation control
      ];
    };
    
    # Enable experimental features for fractional scaling
    "org/gnome/mutter" = {
      experimental-features = [ "scale-monitor-framebuffer" ];
    };
  };

  # Install GNOME Shell extensions
  home.packages = with pkgs; [
    gnomeExtensions.screen-rotate  # For manual screen rotation control
  ];
}
