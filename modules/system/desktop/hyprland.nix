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
    grim # Screenshot
    slurp # Area selection
    pavucontrol # PulseAudio Volume Control
    pamixer # Pulseaudio command line mixer
    brightnessctl # This program allows you read and control device brightness
    networkmanagerapplet # NetworkManager control applet for GNOME

    # XDG portals
    xdg-desktop-portal # Desktop integration portals for sandboxed apps
    xdg-desktop-portal-hyprland # xdg-desktop-portal backend for Hyprland
  ];

  # GNOME Keyring (for credentials)
  services.gnome.gnome-keyring.enable = true;

  # Basic environment variables for Wayland
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };
}
