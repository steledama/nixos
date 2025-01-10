# Configure Cursor Theme
{ pkgs, ... }:
let
  inherit (pkgs)
    adwaita-icon-theme
    ;
in
{
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    size = 24;

    ## Adwaita (GNOME default)
    package = adwaita-icon-theme;
    name = "Adwaita";
  };
}
