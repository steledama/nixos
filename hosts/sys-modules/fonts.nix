{ config, pkgs, ... }:

{
  fonts = {
    fontconfig = {
      enable = true;
      antialias = true;
      hinting = {
        enable = true;
        style = "slight";
      };
      subpixel = {
        lcdfilter = "default";
        rgba = "rgb";
      };
    };
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      mplus-outline-fonts.githubRelease
      dina-font
      proggyfonts
      ubuntu_font_family
      dejavu_fonts
      font-awesome
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];
    fontconfig.defaultFonts = {
      serif = [ "DejaVu Serif" "Noto Serif" ];
      sansSerif = [ "DejaVu Sans" "Noto Sans" ];
      monospace = [ "DejaVu Sans Mono" "Noto Sans Mono" ];
    };
  };
}
