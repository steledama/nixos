{ pkgs, ... }:

{
  fonts = {
    packages = with pkgs; [
      # Basic system fonts
      noto-fonts
      # Font per terminale e caratteri speciali
      font-awesome
      # Nerd Font per Starship
      nerd-fonts.fira-code
    ];
  };
}
