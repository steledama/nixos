# modules/system/desktop/wm.nix
# System-level configuration for Wayland window managers
{pkgs, ...}: {
  # Common environment variables for Wayland compositors
  environment.sessionVariables = {
    # Wayland-specific variables for applications
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    QT_QPA_PLATFORM = "wayland;xcb"; # Prefer Wayland for Qt apps
    SDL_VIDEODRIVER = "wayland"; # Use Wayland for SDL apps

    # Debugging and diagnostic variables
    ELECTRON_ENABLE_LOGGING = "1";
    LIBGL_DEBUG = "verbose";

    # NVIDIA-specific settings
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    WLR_NO_HARDWARE_CURSORS = "1";

    # Cursor configuration
    XCURSOR_SIZE = "24";
    XCURSOR_THEME = "Adwaita";
  };

  # Wayland utilities and tools
  environment.systemPackages = with pkgs; [
    # Display and configuration tools
    wlr-randr # Wayland display configuration utility
    wayland-utils # Diagnostic utilities for Wayland

    # Backlight control tools
    light # Simple backlight controller
    brightnessctl # Another backlight utility with more features
    acpilight # Alternative for xbacklight (works on more hardware)

    # Cursor themes
    xorg.xcursorthemes
  ];

  # Enable ACPI backlight control
  hardware.acpilight.enable = true;

  # PipeWire audio system
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # Uncomment if you need JACK compatibility
    # jack.enable = true;
  };

  # udev rules for backlight control permissions
  services.udev.extraRules = ''
    # Allow members of the video group to control screen brightness
    SUBSYSTEM=="backlight", ACTION=="add", RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/%k/brightness"
    SUBSYSTEM=="backlight", ACTION=="add", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/brightness"

    # Allow members of the video group to control keyboard backlight
    SUBSYSTEM=="leds", ACTION=="add", KERNEL=="*::kbd_backlight", RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/leds/%k/brightness"
    SUBSYSTEM=="leds", ACTION=="add", KERNEL=="*::kbd_backlight", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/leds/%k/brightness"
  '';

  # NOTE: The following settings are handled in xdg-portals.nix:
  # - services.dbus.enable
  # - security.polkit.enable
  # - XDG portal configuration
}
