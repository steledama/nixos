{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Packages for custom themes
    catppuccin-gtk
    catppuccin-cursors
    papirus-icon-theme
  ];

  dconf.settings = {
    "org/gnome/shell/extensions/user-theme" = {
      name = "Catppuccin-Mocha-Standard-Blue-Dark"; # Default is "Adwaita"
    };

    "org/gnome/desktop/interface" = {
      gtk-theme = "Catppuccin-Mocha-Standard-Blue-Dark"; # Default is "Adwaita"
      icon-theme = "Papirus-Dark"; # Default is "Adwaita"
      cursor-theme = "Adwaita";
    };
  };
}
