# modules/system/desktop/niri.nix
# System-level configuration for Niri Wayland compositor
{pkgs, ...}: {
  # Enable Niri
  programs.niri = {
    enable = true;
    # System-level Niri configuration (applies globally)
    settings = {
      # Default global settings can be added here
      # These will be overridden by user-specific configurations
    };
  };

  # Environment variables
  environment.sessionVariables = {
    # Firefox on wayland
    MOZ_ENABLE_WAYLAND = "1";
    # Force use of Wayland for Qt apps
    QT_QPA_PLATFORM = "wayland;xcb";
    # Force use of Wayland for GTK apps
    GDK_BACKEND = "wayland,x11";
    # Toolkit-specific settings for better Wayland compatibility
    SDL_VIDEODRIVER = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    # XDG configuration
    XDG_CURRENT_DESKTOP = "niri";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "niri";
  };

  # Specific packages needed for Niri
  environment.systemPackages = with pkgs; [
    # Most of these packages are reused from your Hyprland configuration
    wofi # Launcher
    waybar # Status bar
    wl-clipboard # Clipboard manager
    grim # Screenshot
    slurp # Area selection

    pavucontrol # PulseAudio Volume Control
    pamixer # Pulseaudio command line mixer
    brightnessctl # This program allows you read and control device brightness
    networkmanagerapplet # NetworkManager control applet for GNOME

    wlogout # Logout menu
    swaylock # Screen locking
    bluez-tools # bluetooth
    jq # JSON processor (useful for scripts)

    # XDG portals
    xdg-desktop-portal # Desktop integration portals for sandboxed apps
    xdg-desktop-portal-gtk # GTK portal (for file dialogs)
    xdg-desktop-portal-wlr # wlroots-based compositor backend (works with Niri)

    # File management
    nautilus # Lightweight file manager
    gvfs # Virtual filesystem
  ];

  # XDG portal configuration
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
    ];
    config = {
      common.default = "gtk";
      niri.default = ["gtk" "wlr"];
    };
  };

  services = {
    # GNOME Keyring for credentials
    gnome.gnome-keyring.enable = true;
    # UPower for power management
    upower.enable = true;
    # Bluetooth support
    blueman.enable = true;
  };
  
  # Enable polkit security framework
  security.polkit.enable = true;
}
