# nixos/modules/home/ui-theme.nix
{ ... }: {

  # cross-desktop environmnet variables
  home.sessionVariables = { };

  # GTK config for non-GNOME apps
  gtk = {
    enable = true;
  };
}
