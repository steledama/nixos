# modules/system/services/xdg-portals.nix
# Configuration for XDG Desktop Portals across different desktop environments
{pkgs, ...}: {
  # Enable PID namespaces which are required by some portal implementations
  security = {
    allowUserNamespaces = true;
    apparmor.enable = false; # Can interfere with some portals
  };

  # Allow unprivileged user namespaces needed for portal sandboxing
  boot.kernel.sysctl = {
    "kernel.unprivileged_userns_clone" = 1;
  };

  # Main XDG portal configuration
  xdg.portal = {
    enable = true;

    # Install all necessary portal backends
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
      xdg-desktop-portal-wlr
      xdg-desktop-portal-hyprland
    ];

    # Configure portal implementations by desktop environment
    config = {
      # Default fallback configuration
      common = {
        default = ["gtk"];
      };

      # GNOME-specific portal configuration
      gnome = {
        default = ["gnome" "gtk"];
        "org.freedesktop.impl.portal.FileChooser" = ["gnome" "gtk"];
        "org.freedesktop.impl.portal.OpenURI" = ["gnome"];
        "org.freedesktop.impl.portal.Screenshot" = ["gnome"];
        "org.freedesktop.impl.portal.ScreenCast" = ["gnome"];
      };

      # Hyprland-specific portal configuration
      hyprland.default = ["hyprland" "gtk"];

      # Niri-specific portal configuration
      niri.default = ["wlr" "gtk"];
    };
  };

  # Enable D-Bus service and ensure all portal implementations are registered
  services.dbus = {
    enable = true;
    packages = with pkgs; [
      xdg-desktop-portal
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
      xdg-desktop-portal-wlr
      xdg-desktop-portal-hyprland
    ];
  };

  # Enable PolicyKit for permission handling
  security.polkit.enable = true;

  # Install required system packages
  environment.systemPackages = with pkgs; [
    # Core XDG utilities
    xdg-utils
    xdg-desktop-portal

    # Portal implementations
    xdg-desktop-portal-gtk
    xdg-desktop-portal-gnome
    xdg-desktop-portal-wlr
    xdg-desktop-portal-hyprland

    # GNOME integration
    gnome-settings-daemon
  ];

  # Set environment variables for proper portal usage
  environment.sessionVariables = {
    # Force GTK applications to use portals
    GTK_USE_PORTAL = "1";

    # Firefox-specific settings for better integration
    MOZ_DBUS_REMOTE = "1";
    MOZ_USE_XINPUT2 = "1";
  };
}
