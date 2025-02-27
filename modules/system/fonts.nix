# nixos/modules/system/fonts.nix

{ pkgs, ... }:

{
  fonts = {
    packages = with pkgs; [
      # Basic system fonts
      noto-fonts

      # Font per terminale e caratteri speciali
      font-awesome

      # Nerd Fonts
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
    ];

    # Abilita i font di sistema
    enableDefaultPackages = true;

    # Configurazione dei font di default
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "JetBrainsMono Nerd Font Mono" ];
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
      };
    };
  };
}
