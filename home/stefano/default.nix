# home/stefano/default.nix
{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../default.nix
    # Hyprland config
    (import ../../modules/home/hyprland.nix {
      inherit pkgs;
      keyboardLayout = "it";
      keyboardVariant = "";
      keyboardOptions = "";
    })
  ];

  # Abilita e configura Niri per questo utente
  # Commenta queste righe per disattivare Niri
  programs.niri = {
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
    };
  };

  # username
  home.username = "stefano";
  home.homeDirectory = "/home/${config.home.username}";

  # User-specific packages (additional to common ones)
  home.packages = with pkgs; [
    amule
  ];

  home.stateVersion = "23.11";
}
