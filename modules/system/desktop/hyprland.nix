# modules/system/desktop/hyprland.nix
{pkgs, ...}: {
  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Specific hyprland packages
  environment.systemPackages = with pkgs; [
    wofi # Launcher
    waybar # Status bar
    hyprpaper # Wallpaper manager for Hyprland
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
    jq # multimonitor

    # XDG portals
    xdg-desktop-portal # Desktop integration portals for sandboxed apps
    xdg-desktop-portal-hyprland # xdg-desktop-portal backend for Hyprland
    xdg-desktop-portal-gtk # GTK portal (for file dialogs)

    # File management
    nautilus # Lightweight file manager
    gvfs # Virtual filesystem
  ];

  # XDG portal config
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland
    ];
    config = {
      common.default = "gtk";
      hyprland.default = ["gtk" "hyprland"];
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
  # Basic environment variables for Wayland
  environment.sessionVariables = {
    # Firefox on wayland
    MOZ_ENABLE_WAYLAND = "1";
  };
}
