# home/stefano/default.nix
{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../default.nix
    ../../modules/home/wm.nix
    ../../modules/home/hyprland.nix
    ../../modules/home/niri.nix
  ];

  # User
  home.username = "stefano";
  home.homeDirectory = "/home/${config.home.username}";

  # Setup WMs with keyboard configuration
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
