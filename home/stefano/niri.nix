# home/stefano/niri.nix
{pkgs, ...}: {
  # Configurazione utente di Niri
  programs.niri = {
    enable = true;
    settings = {
      # Configurazione tastiera
      input.keyboard.xkb = {
        layout = "it";
        variant = "";
        options = "";
      };

      # Variabili d'ambiente
      environment = {
        "MOZ_ENABLE_WAYLAND" = "1";
        "QT_QPA_PLATFORM" = "wayland;xcb";
        "GDK_BACKEND" = "wayland,x11";
        "SDL_VIDEODRIVER" = "wayland";
        "_JAVA_AWT_WM_NONREPARENTING" = "1";
        "XDG_CURRENT_DESKTOP" = "niri";
        "XDG_SESSION_TYPE" = "wayland";
        "XDG_SESSION_DESKTOP" = "niri";
        "NIXOS_OZONE_WL" = "1";
      };

      # Altre configurazioni specifiche per Niri...
    };
  };
}
