# modules/home/gtk.nix
# GTK theme: Adwaita-dark with a global dark preference.
#
# Niri sessions on desktop hosts need both file-based GTK settings and dconf
# keys so GTK apps, libadwaita-aware components, and portals agree on the dark
# preference.
# Adwaita-dark is intentional here: it avoids app-specific wrappers and is a
# safer baseline than custom GTK themes across desktop hosts.
{pkgs, ...}: {
  dconf = {
    enable = true;
    settings."org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "Adwaita-dark";
      icon-theme = "Adwaita";
      cursor-theme = "catppuccin-mocha-dark-cursors";
      cursor-size = 24;
    };
  };

  gtk = {
    enable = true;

    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };

    gtk4.theme = null;

    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };

    cursorTheme = {
      name = "catppuccin-mocha-dark-cursors";
      package = pkgs.catppuccin-cursors.mochaDark;
      size = 24;
    };
  };

  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    name = "catppuccin-mocha-dark-cursors";
    package = pkgs.catppuccin-cursors.mochaDark;
    size = 24;
  };

  home.sessionVariables = {
    GTK_THEME = "Adwaita-dark";
  };
}
