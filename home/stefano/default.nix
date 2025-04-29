# home/stefano/default.nix
{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../default.nix
    # Importa il modulo config di Niri (non il modulo niri)
    inputs.niri.homeModules.config

    # Hyprland config
    (import ../../modules/home/hyprland.nix {
      inherit pkgs;
      keyboardLayout = "it";
      keyboardVariant = "";
      keyboardOptions = "";
    })
    # Niri
    ./niri.nix
  ];

  # username
  home.username = "stefano";
  home.homeDirectory = "/home/${config.home.username}";

  # User-specific packages (additional to common ones)
  home.packages = with pkgs; [
    amule
  ];

  home.stateVersion = "23.11";
}
