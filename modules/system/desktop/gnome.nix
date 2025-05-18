# modules/system/desktop/gnome.nix
# Configurazione GNOME ultra-minimalista per garantire il funzionamento del sistema
{pkgs, ...}: {
  # Enable solo GNOME Desktop Manager - configurazione minima
  services.xserver.desktopManager.gnome.enable = true;

  # Pacchetti di base necessari per il funzionamento
  environment.systemPackages = with pkgs; [
    # Solo pochi pacchetti essenziali
    gnome-tweaks
    gtk3
    gsettings-desktop-schemas
  ];

  # Mantieni GVFS per la funzionalità base di file
  services.gvfs.enable = true;
}
