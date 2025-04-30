# modules/home/niri.nix
# Minimal home-manager configuration for Niri window manager
# Using default Niri shortcuts and built-in functionality
config: pkgs: {
  # Just provide the necessary packages to support Niri
  # Without any custom configuration or scripts
  home.packages = with pkgs; [
    # Essential Wayland utilities
    wl-clipboard # Clipboard tools
    swaylock # Screen locking
    alacritty # Default terminal
    fuzzel # Default application launcher
  ];

  # Make sure the config directory exists but don't override it
  # This allows Niri to create and manage its own default config
  home.file.".config/niri/.keep".text = "";
}
