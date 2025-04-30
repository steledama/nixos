# modules/system/desktop/niri.nix
# Minimal Niri window manager configuration that uses the default shortcuts
{
  pkgs,
  lib,
  ...
}: {
  # Import the common Wayland window manager setup
  # This provides shared utilities, XDG portals, etc.
  imports = [
    ./wayland-wm.nix
  ];

  # Enable the Niri window manager with unstable version
  programs.niri = {
    enable = true;
    # Use the unstable version for the latest features
    package = pkgs.niri-unstable;
  };

  # Niri-specific XDG portal configuration
  xdg.portal = {
    # Base configuration is enabled in wayland-wm.nix
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr # WLR-based portal for screenshots, screen sharing
    ];
    # Use WLR portal for Niri
    config.niri.default = ["gtk" "wlr"];
  };

  # Register Niri with the display manager
  services.displayManager.sessionPackages = [pkgs.niri-unstable];

  # Set default Wayland session if not already set
  services.displayManager.defaultSession = lib.mkDefault "niri";

  # Environment variables for proper Wayland/Niri integration
  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "niri";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "niri";
    NIXOS_OZONE_WL = "1";
  };
}
