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
        # dynamic_title = true;
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

      # Keybindings
      key_bindings = [
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
      ];

      # Shell
      shell = {
        program = "${pkgs.zsh}/bin/zsh";
        args = [ "-l" ];
      };
    };

    # Shortcuts  for better Alacritty/Tmux integration
    key_bindings = [
      # Tmux navigation
      {
        key = "T";
        mods = "Control|Shift";
        action = "SpawnNewInstance";
      } # Nuova istanza

      # Scorciatoie per le sessioni tmux
      {
        key = "D";
        mods = "Control|Shift";
        chars = "\\x01\\x64";
      } # Distacca sessione (tmux prefix + d)
      {
        key = "C";
        mods = "Control|Shift";
        chars = "\\x01\\x63";
      } # Nuova finestra (tmux prefix + c)
      {
        key = "W";
        mods = "Control|Shift";
        chars = "\\x01\\x77";
      } # Lista finestre (tmux prefix + w)
      {
        key = "N";
        mods = "Control|Shift";
        chars = "\\x01\\x6e";
      } # Finestra successiva (tmux prefix + n)
      {
        key = "P";
        mods = "Control|Shift";
        chars = "\\x01\\x70";
      } # Finestra precedente (tmux prefix + p)

      # Scorciatoie per split del pannello
      {
        key = "H";
        mods = "Control|Shift";
        chars = "\\x01\\x5c";
      } # Split orizzontale (tmux prefix + \)
      {
        key = "V";
        mods = "Control|Shift";
        chars = "\\x01\\x2d";
      } # Split verticale (tmux prefix + -)

      # Copia e incolla
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
    ];
  };
}
