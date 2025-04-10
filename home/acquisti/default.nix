# nixos/home/acquisti/default.nix
{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../default.nix
    # Hyprland keyboard layout config
    (import ../../modules/home/hyprland.nix {
      inherit pkgs config lib;
      keyboardLayout = "no";
      keyboardVariant = "";
      keyboardOptions = "compose:ralt";
    })
    ../../modules/home/syncthing.nix
  ];
  # username
  home.username = "acquisti";
  home.homeDirectory = "/home/${config.home.username}";

  # User-specific packages (additional to common ones)
  home.packages = with pkgs; [
    anydesk # Remote desktop software
    insomnia # API client
  ];

  home.stateVersion = "23.11";
}
