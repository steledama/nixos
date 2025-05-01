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

  # Setup WMs
  wayland-wm = {
    enable = true;
    # keyboard
    keyboard = {
      layout = "it";
      variant = "";
      options = "";
    };
    # Wallpaper (To find the correct output names for each system, you should run wlr-randr or niri msg outputs when running Niri to see the available outputs.)
    wallpaper = {
      outputColors = {
        "DP-3" = "#000000";
        # "HDMI-A-1" = "#660033";
      };
    };
  };

  # User-specific packages (additional to common ones)
  home.packages = with pkgs; [
    amule
  ];

  home.stateVersion = "23.11";
}
