# modules/system/desktop/niri.nix
# Niri window manager configuration for NixOS
# This module extends wayland-wm.nix with Niri-specific configuration
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

  # Enable the Niri window manager
  programs.niri = {
    enable = true;
    # Specify the unstable version
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

  # Niri-specific system packages
  environment.systemPackages = with pkgs; [
    # Additional tools specifically useful with Niri
    xwayland-satellite-unstable # Improved XWayland support
  ];

  # GDM (GNOME Display Manager) configuration
  services.displayManager.sessionPackages = [pkgs.niri-unstable];

  # Set default Wayland session if not already set
  services.displayManager.defaultSession = lib.mkDefault "niri";

  # Make sure Niri is available as a system-wide session
  environment.sessionVariables = {
    # Proper Wayland integration for Niri
    XDG_CURRENT_DESKTOP = "niri";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "niri";
    NIXOS_OZONE_WL = "1";
  };
}
