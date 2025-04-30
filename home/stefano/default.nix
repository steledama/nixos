# home/stefano/default.nix
{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../default.nix
    ./niri.nix
    # Hyprland with custom layout config
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
