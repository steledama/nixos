# home/stefano/default.nix
{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../default.nix
    # Import Niri with minimal configuration to use default shortcuts
    (import ../../modules/home/niri.nix config pkgs)
  ];

  # username
  home.username = "stefano";
  home.homeDirectory = "/home/${config.home.username}";

  # User-specific packages (additional to common ones)
  home.packages = with pkgs; [
    # Terminal
    alacritty # Default terminal used by Niri

    # Application launcher
    fuzzel # Default launcher used by Niri

    # Utilities
    swaylock # Used by Niri for screen locking

    # Your existing packages
    amule
  ];

  home.stateVersion = "23.11";
}
