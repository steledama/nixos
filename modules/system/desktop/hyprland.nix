# modules/system/desktop/hyprland.nix
{
  pkgs,
  lib,
  ...
}: {
  # Enable Hyprland as main desktop environment
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # SDDM as display manager (works well with Wayland)
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "sugar-dark"; # Modern theme
  };

  # Install SDDM theme
  environment.systemPackages = with pkgs; [
    # Display manager theme
    sddm-sugar-dark

    # Core desktop components
    wofi # Launcher
    waybar # Status bar
    hyprpaper # Wallpaper manager for Hyprland
    swww # Alternative wallpaper manager

    # System utilities
    wl-clipboard # Clipboard manager
    dunst # Notification daemon
    libnotify # Notification library

    # Screen utilities
    grim # Screenshot
    slurp # Area selection
    wf-recorder # Screen recording

    # Audio controls
    pavucontrol # PulseAudio Volume Control
    pamixer # Pulseaudio command line mixer

    # Display/monitor control
    brightnessctl # Control screen brightness

    # Network management
    networkmanagerapplet # NetworkManager control applet

    # Authentication and keyring
    kdePackages.polkit-kde-agent-1 # Authentication agent

    # General utilities
    wlogout # Logout menu
    swaylock # Screen locking

    # XDG portals
    xdg-desktop-portal # Desktop integration portals for sandboxed apps
    xdg-desktop-portal-hyprland # xdg-desktop-portal backend for Hyprland
    xdg-desktop-portal-gtk # GTK portal (for file dialogs)

    # File management
    pcmanfm # Lightweight file manager
    gvfs # Virtual filesystem

    # Theming support
    qt6ct # Qt6 configuration tool
    qt6.qtwayland
    # Theme utilities
    kdePackages.qtstyleplugin-kvantum # Engine di stile
    kdePackages.breeze # Tema KDE moderno
    papirus-icon-theme # Set di icone alternativo
  ];

  # Ensure necessary services are enabled
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

  # Set proper environment variables for Wayland
  environment.sessionVariables = {
    # General Wayland configuration
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    GDK_BACKEND = "wayland,x11";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";

    # Impostazioni specifiche per Qt6
    QT_QPA_PLATFORMTHEME = "qt6ct";
    QT_STYLE_OVERRIDE = "kvantum";

    # Ensure proper cursor theme and size
    XCURSOR_THEME = "Adwaita";
    XCURSOR_SIZE = "24";
  };

  # Add SDDM to the display manager options
  services.xserver = {
    enable = true;
    displayManager = {
      defaultSession = "hyprland";
    };
  };

  # Set default session to Hyprland
  services.displayManager.sessionPackages = [pkgs.hyprland];

  # For those who need to use X applications
  programs.xwayland.enable = true;
}
