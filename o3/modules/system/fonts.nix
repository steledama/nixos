# modules/system/fonts.nix
{pkgs, ...}: {
  fonts = {
    packages = with pkgs; [
      # Basic system fonts for UI and Unicode coverage
      noto-fonts

      # Nerd Font for terminal (includes icons and glyphs)
      nerd-fonts.jetbrains-mono
    ];

    # Enable default system font packages
    enableDefaultPackages = true;

    # Font rendering configuration (no forced defaults)
    fontconfig = {
      enable = true;
    };
  };
}
