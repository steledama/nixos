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

    # XDG portals
    xdg-desktop-portal
    xdg-desktop-portal-hyprland
  ];

  # GNOME Keyring (for credentials)
  services.gnome.gnome-keyring.enable = true;

  # Basic environment variables for Wayland
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };
}
