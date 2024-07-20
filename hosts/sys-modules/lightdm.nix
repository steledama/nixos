{ config, pkgs, ... }:

{
  # Abilita il Display Manager LightDM
  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    desktopManager.gnome.enable = true;  # Manteniamo GNOME come desktop environment
    displayManager.defaultSession = "gnome";
  };

  # Forza l'uso di X11 invece di Wayland
  services.xserver.displayManager.gdm.wayland = false;
}