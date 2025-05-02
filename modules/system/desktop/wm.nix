# modules/system/desktop/wm.nix
# System-level configuration for window managers
{pkgs, ...}: {
  # Common environment variables
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    ELECTRON_ENABLE_LOGGING = "1"; # For debugging
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
    wlr-randr # Wayland display configuration
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
}
