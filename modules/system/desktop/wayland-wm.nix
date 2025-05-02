# modules/system/desktop/wayland-wm.nix
# System-level configuration for Wayland window managers
{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.wayland-wm;
in {
  options.wayland-wm = {
    enable = lib.mkEnableOption "Enable Wayland window managers";
  };

  config = lib.mkIf cfg.enable {
    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      ELECTRON_OZONE_PLATFORM_HINT = "wayland";
      ELECTRON_ENABLE_LOGGING = "1"; # Per il debug
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      WLR_NO_HARDWARE_CURSORS = "1";
      LIBGL_DEBUG = "verbose";
    };

    # Ensure XDG Portal is set up correctly
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
      ];
    };

    # Common packages needed by Wayland WMs at system level
    environment.systemPackages = with pkgs; [
      wlr-randr # CLI for configuring displays on Wayland
      wayland-utils # Wayland utilities (wayland-info)
      wl-clipboard # Command-line copy/paste utilities for Wayland
      pamixer # Pulseaudio command line mixer
      brightnessctl # read and control device brightness
    ];

    # Ensure polkit is available for authentication dialogs
    security.polkit.enable = true;

    # Services needed by Wayland compositors
    services = {
      # Required for XDG desktop integration
      dbus.enable = true;

      # Optional services that most Wayland setups need
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };
    };
  };
}
