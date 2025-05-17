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
    # cursor
    XCURSOR_SIZE = "24";
    XCURSOR_THEME = "Adwaita";
  };

  environment.systemPackages = with pkgs; [
    wlr-randr # Wayland display configuration
    wayland-utils # Diagnostic utility for Wayland
    light # Backlight control utility
    brightnessctl # Alternative backlight utility
    acpilight # Alternative for xbacklight (works on more hardware)
    xorg.xcursorthemes
  ];

  # Backlight
  hardware.acpilight.enable = true;

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

  # udev rules for Backlight
  services.udev.extraRules = ''
    # Allow members of the video group to control brightness
    SUBSYSTEM=="backlight", ACTION=="add", RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/%k/brightness"
    SUBSYSTEM=="backlight", ACTION=="add", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/brightness"
    SUBSYSTEM=="leds", ACTION=="add", KERNEL=="*::kbd_backlight", RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/leds/%k/brightness"
    SUBSYSTEM=="leds", ACTION=="add", KERNEL=="*::kbd_backlight", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/leds/%k/brightness"
  '';
}
