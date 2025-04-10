# nixos/home/stefano/default.nix
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
      keyboardLayout = "it";
      keyboardVariant = "";
      keyboardOptions = "";
    })
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
