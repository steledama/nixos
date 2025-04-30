# home/stefano/default.nix
{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../default.nix
    # Window managers configuration
    # You can enable any of these - Niri is currently set as primary
    # (import ../../modules/home/hyprland.nix {
    #   inherit pkgs;
    #   keyboardLayout = "it";
    #   keyboardVariant = "";
    #   keyboardOptions = "";
    # })

    # Import the Niri configuration with explicit parameters
    (import ../../modules/home/niri.nix config pkgs)
  ];

  # username
  home.username = "stefano";
  home.homeDirectory = "/home/${config.home.username}";

  # User-specific packages (additional to common ones)
  home.packages = with pkgs; [
    amule
    # Add any additional packages specific to this user
  ];

  home.stateVersion = "23.11";
}
