# Configure Cursor Theme
{ pkgs, ... }:
let
  inherit (pkgs)
    bibata-cursors
    adwaita-icon-theme
    libsForQt5
    vanilla-dmz
    capitaine-cursors
    numix-cursor-theme
    paper-icon-theme
    elementary-xfce-icon-theme
    ;
in
{
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    size = 24;

    # Uncomment ONE of the following themes:

    ## Bibata Modern Ice (Default)
    # package = bibata-cursors;
    # name = "Bibata-Modern-Ice";

    ## Bibata Modern Classic
    # package = bibata-cursors;
    # name = "Bibata-Modern-Classic";

    ## Bibata Original Classic
    # package = bibata-cursors;
    # name = "Bibata-Original-Classic";

    ## Bibata Original Ice
    # package = bibata-cursors;
    # name = "Bibata-Original-Ice";

    ## Adwaita (GNOME default)
    package = adwaita-icon-theme;
    name = "Adwaita";

    ## Breeze (KDE default)
    # package = libsForQt5.breeze-qt5;
    # name = "breeze_cursors";

    ## Vanilla DMZ (White)
    # package = vanilla-dmz;
    # name = "Vanilla-DMZ";

    ## Vanilla DMZ (Black)
    # package = vanilla-dmz;
    # name = "Vanilla-DMZ-AA";

    ## Capitaine Cursors
    # package = capitaine-cursors;
    # name = "capitaine-cursors";

    ## Numix Cursor
    # package = numix-cursor-theme;
    # name = "Numix-Cursor";

    ## Paper
    # package = paper-icon-theme;
    # name = "Paper";

    ## Xcursor Elementary Theme
    # package = elementary-xfce-icon-theme;
    # name = "elementary";
  };
}
