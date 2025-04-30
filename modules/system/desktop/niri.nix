# modules/system/desktop/niri.nix
# Niri-specific configuration that extends the base Wayland WM setup
{ pkgs, ... }:

{
  # Import the common Wayland WM configuration
  imports = [
    ./wayland-wm.nix
  ];

  # Enable Niri
  programs.niri = {
    enable = true;
  };

  # Additional Niri-specific packages
  environment.systemPackages = with pkgs; [
    # Niri-specific utilities or packages can be added here
  ];

  # Niri-specific environment variables
  environment.sessionVariables = {
    # Specify desktop environment/session type for better compatibility
    XDG_CURRENT_DESKTOP = "niri";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "niri";
  };
}
