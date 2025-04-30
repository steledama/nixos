# modules/system/desktop/hyprland.nix
# Hyprland-specific configuration that extends the base Wayland WM setup
{pkgs, ...}: {
  # Import the common Wayland WM configuration
  imports = [
    ./wayland-wm.nix
  ];

  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Hyprland-specific XDG portal configuration
  xdg.portal = {
    # Base configuration is enabled in wayland-wm.nix
    extraPortals = [pkgs.xdg-desktop-portal-hyprland];
    config.hyprland.default = ["gtk" "hyprland"];
  };

  # Additional Hyprland-specific packages
  environment.systemPackages = with pkgs; [
    # Hyprland-specific utilities
    xdg-desktop-portal-hyprland # Hyprland-specific portal backend
  ];
}
