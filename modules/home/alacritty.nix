# nixos/modules/home/alacritty.nix

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
      # Configurazione di base
      window = {
        padding = {
          x = 8;
          y = 8;
        };
        decorations = "full";
        opacity = 1.0;
      };

      # Scrolling
      scrolling = {
        history = 10000;
        multiplier = 3;
      };

      # Font
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

      # Colori (OneDark theme)
      colors = {
        # Default colors
        primary = {
          background = "#282c34";
          foreground = "#abb2bf";
        };

        # Normal colors
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

        # Bright colors
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

      # Cursor
      cursor = {
        style = {
          shape = "Block";
          blinking = "On";
        };
        blink_interval = 750;
        unfocused_hollow = true;
      };

      # Updated shell configuration to match latest Alacritty requirements
      terminal = {
        shell = {
          program = "${pkgs.zsh}/bin/zsh";
          args = [ "-l" ];
        };
      };

      # Tutti i key bindings in un unico posto
      keyboard.bindings = [
        # Tmux navigation
        {
          key = "T";
          mods = "Control|Shift";
          action = "SpawnNewInstance";
        }

        # Scorciatoie per le sessioni tmux
        {
          key = "D";
          mods = "Control|Shift";
          chars = "\u0001\u0064"; # Usa la notazione Unicode
        }
        {
          key = "C";
          mods = "Control|Shift";
          chars = "\u0001\u0063";
        }
        {
          key = "W";
          mods = "Control|Shift";
          chars = "\u0001\u0077";
        }
        {
          key = "N";
          mods = "Control|Shift";
          chars = "\u0001\u006e";
        }
        {
          key = "P";
          mods = "Control|Shift";
          chars = "\u0001\u0070";
        }
        # Scorciatoie per split del pannello
        {
          key = "H";
          mods = "Control|Shift";
          chars = "\u0001\u005c";
        }
        {
          key = "V";
          mods = "Control|Shift";
          chars = "\u0001\u002d";
        }

        # Copy paste and clear
        {
          key = "V";
          mods = "Control";
          action = "Paste";
        }
        {
          key = "C";
          mods = "Control";
          action = "Copy";
        }
        {
          key = "L";
          mods = "Control";
          chars = "\u000c"; # clear (Ctrl+L)
        }
      ];
    };
  };
}
