# nixos/modules/system/fonts.nix
{pkgs, ...}: {
  fonts = {
    packages = with pkgs; [
      # Basic system fonts
      noto-fonts

      # Terminal fonts and special characters
      font-awesome

      # Nerd Fonts
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
    ];

    # System fonts
    enableDefaultPackages = true;

    # Default font config
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = ["JetBrainsMono Nerd Font Mono"];
        serif = ["Noto Serif"];
        sansSerif = ["Noto Sans"];
      };
    };
  };
}
