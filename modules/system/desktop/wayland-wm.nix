# modules/system/desktop/wayland-wm.nix
# Common base configuration for Wayland window managers like Hyprland and Niri
# This module provides shared utilities and configurations needed by most Wayland WMs
{pkgs, ...}: {
  # Environment variables common to Wayland compositors
  environment.sessionVariables = {
    # Firefox on Wayland
    MOZ_ENABLE_WAYLAND = "1";
    # Qt apps on Wayland
    QT_QPA_PLATFORM = "wayland;xcb";
    # GTK apps on Wayland
    GDK_BACKEND = "wayland,x11";
    # SDL apps on Wayland
    SDL_VIDEODRIVER = "wayland";
    # Java apps on Wayland
    _JAVA_AWT_WM_NONREPARENTING = "1";
  };

  # Common packages for Wayland window managers
  environment.systemPackages = with pkgs; [
    # App launchers and menus
    fuzzel # Application launcher
    wlogout # Logout menu

    # Status bars
    waybar # Status bar for Wayland

    # Desktop utilities
    wl-clipboard # Clipboard management
    libnotify # Desktop notifications
    grim # Screenshot utility
    slurp # Area selection for screenshots

    # Media control
    pavucontrol # PulseAudio volume control
    pamixer # Command-line audio mixer
    brightnessctl # Display brightness control

    # System utilities
    networkmanagerapplet # NetworkManager control applet
    bluez-tools # Bluetooth management tools
    swaylock # Screen locking
    swayidle # Idle management
    swaybg # Wallpaper manager

    # JSON processing (for scripts)
    jq # JSON processor

    # XDG portals for desktop integration
    xdg-desktop-portal # Desktop integration portals for sandboxed apps
    xdg-desktop-portal-gtk # GTK portal backend (for file dialogs)

    # File management
    nautilus # File manager
    gvfs # Virtual filesystem
  ];

  # XDG portal configuration
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
    config = {
      common.default = "gtk";
    };
  };

  # Basic swaylock configuration
  programs.swaylock = {
    enable = true;
    settings = {
      color = "282c34";
      show-failed-attempts = true;
      ignore-empty-password = true;
      indicator-caps-lock = true;
      clock = true;
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

  # Enable polkit security framework (required by many desktop apps)
  security.polkit.enable = true;
}
