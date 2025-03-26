# nixos/modules/home/ui-theme.nix
{...}: {
  # Configurazione GNOME tramite dconf
  dconf.settings = {
    "org/gnome/shell/extensions/user-theme" = {
      name = "Adwaita";
    };
    "org/gnome/desktop/interface" = {
      gtk-theme = "Adwaita";
      icon-theme = "Adwaita";
      cursor-theme = "Adwaita";
      cursor-size = 24;
    };
  };

  # cross-desktop environmnet variables
  home.sessionVariables = {
    XCURSOR_THEME = "Adwaita";
    XCURSOR_SIZE = "24";
  };

  # GTK config for non-GNOME apps
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita";
    };
    iconTheme = {
      name = "Adwaita";
    };
    cursorTheme = {
      name = "Adwaita";
      size = 24;
    };
  };
}
