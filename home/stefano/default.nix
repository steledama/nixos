# home/stefano/default.nix
{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../default.nix
    # Import Niri and Hyprland modules directly
    ../../modules/home/niri.nix
    ../../modules/home/hyprland.nix
  ];

  # username
  home.username = "stefano";
  home.homeDirectory = "/home/${config.home.username}";

  # Setup keyboard configuration for Wayland WMs
  wayland-wm = {
    enable = true;
    keyboard = {
      layout = "it";
      variant = "";
      options = "";
    };
  };

  # User-specific packages (additional to common ones)
  home.packages = with pkgs; [
    amule
  ];

  home.stateVersion = "23.11";
}
