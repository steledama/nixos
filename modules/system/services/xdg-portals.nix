# modules/system/services/xdg-portals.nix
{pkgs, ...}: {
  services.dbus.enable = true;

  environment.systemPackages = with pkgs; [
    xdg-utils
    xdg-desktop-portal
  ];

  # Configurazione completa di XDG Portal
  xdg.portal = {
    enable = true;

    # Installa tutti i portali necessari
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
      xdg-desktop-portal-wlr
      xdg-desktop-portal-hyprland
    ];

    # Configurazione specifica per ogni ambiente desktop
    config = {
      # Configurazione per GNOME
      gnome = {
        default = ["gnome" "gtk"];
        "org.freedesktop.impl.portal.FileChooser" = ["gnome" "gtk"];
        "org.freedesktop.impl.portal.OpenURI" = ["gnome"];
      };

      # Configurazione per Niri (mantenendo quella che già hai)
      niri.default = ["gtk" "wlr"];

      # Configurazione per Hyprland
      hyprland.default = ["gtk" "hyprland"];
    };
  };

  # Assicurati che le variabili di sessione corrette siano impostate
  environment.variables = {
    # Forza le applicazioni GTK ad usare il portale
    GTK_USE_PORTAL = "1";
  };
}
