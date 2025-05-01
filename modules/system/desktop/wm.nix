# modules/system/desktop/wm.nix
# System-level configuration for window managers
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
    # Common environment variables
    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      ELECTRON_OZONE_PLATFORM_HINT = "wayland";
      ELECTRON_ENABLE_LOGGING = "1"; # Per il debug
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      WLR_NO_HARDWARE_CURSORS = "1";
      LIBGL_DEBUG = "verbose";
    };

    # XDG Portal
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
      ];
    };

    environment.systemPackages = with pkgs; [
      wlr-randr # Config display Wayland
      wayland-utils # Diagnostic utility for Wayland
    ];

    # Common services
    security.polkit.enable = true;
    services.dbus.enable = true;

    # Pipewire
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
