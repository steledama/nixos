# nixos/modules/home/gnome-theme.nix
{pkgs, ...}: {
  home.packages = with pkgs; [
    # Packages for custom themes
    # catppuccin-gtk
    # catppuccin-cursors
    # papirus-icon-theme
  ];
  dconf.settings = {
    "org/gnome/shell/extensions/user-theme" = {
      # Default is "Adwaita"
      name = "Adwaita";
      # name = "Catppuccin-Mocha-Standard-Blue-Dark";
    };
    "org/gnome/desktop/interface" = {
      # Default is "Adwaita"
      gtk-theme = "Adwaita";
      # gtk-theme = "Catppuccin-Mocha-Standard-Blue-Dark";
      # Default is "Adwaita"
      icon-theme = "Adwaita";
      # icon-theme = "Papirus-Dark";
      cursor-theme = "Adwaita";
    };
  };
}
