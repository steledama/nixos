# home/stefano/default.nix
{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../default.nix
    # Niri
    (import ../../modules/home/niri.nix {
      inherit pkgs;
      keyboardLayout = "it";
      keyboardVariant = "";
      keyboardOptions = "";
    })
    # Hyprland
    (import ../../modules/home/hyprland.nix {
      inherit pkgs;
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
