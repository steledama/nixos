# modules/home/alacritty.nix
# Minimal configuration with default settings
{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.alacritty = {
    enable = true;
    settings = {
      # Basic window configuration
      window = {
        padding = {
          x = 8;
          y = 8;
        };
        decorations = "full";
        opacity = 1.0;
      };
      
      # Basic font configuration
      font = {
        normal = {
          family = "JetBrainsMono Nerd Font";
          style = "Regular";
        };
        bold = {
          family = "JetBrainsMono Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "JetBrainsMono Nerd Font";
          style = "Italic";
        };
        size = 13.0;
      };
      
      # Simplified OneDark theme
      colors = {
        primary = {
          background = "#282c34";
          foreground = "#abb2bf";
        };
        
        normal = {
          black = "#282c34";
          red = "#e06c75";
          green = "#98c379";
          yellow = "#e5c07b";
          blue = "#61afef";
          magenta = "#c678dd";
          cyan = "#56b6c2";
          white = "#abb2bf";
        };
        
        bright = {
          black = "#545862";
          red = "#e06c75";
          green = "#98c379";
          yellow = "#e5c07b";
          blue = "#61afef";
          magenta = "#c678dd";
          cyan = "#56b6c2";
          white = "#c8ccd4";
        };
      };
      
      # Shell configuration
      terminal = {
        shell = {
          program = "${pkgs.zsh}/bin/zsh";
          args = [ "-l" ];
        };
      };
      
      # No custom keybindings for now
      # keyboard.bindings = [];
    };
  };
}
