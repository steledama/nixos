# nixos/modules/home/alacritty.nix
# This module configures Alacritty terminal emulator with custom keybindings 
# optimized for tmux workflow

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

      # Scrolling configuration
      scrolling = {
        history = 10000;
        multiplier = 3;
      };

      # Font configuration
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

      # Colors (OneDark theme)
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

      # Cursor configuration
      cursor = {
        style = {
          shape = "Block";
          blinking = "On";
        };
        blink_interval = 750;
        unfocused_hollow = true;
      };

      # Terminal shell configuration
      terminal = {
        shell = {
          program = "${pkgs.zsh}/bin/zsh";
          args = [ "-l" ];
        };
      };

      # Key bindings
      keyboard.bindings = [
        # ----- Terminal Management -----
        # Ctrl+Shift+T: Open a new Alacritty instance
        {
          key = "T";
          mods = "Control|Shift";
          action = "SpawnNewInstance";
        }

        # ----- Tmux Session Management -----
        # Ctrl+Shift+D: Send Ctrl+Space then 'd' to tmux
        # This detaches from the current tmux session
        {
          key = "D";
          mods = "Control|Shift";
          chars = "\u0001\u0064"; # Unicode for Ctrl+Space, d
        }
        
        # Ctrl+Shift+C: Send Ctrl+Space then 'c' to tmux
        # This creates a new window in tmux
        {
          key = "C";
          mods = "Control|Shift";
          chars = "\u0001\u0063"; # Unicode for Ctrl+Space, c
        }
        
        # Ctrl+Shift+W: Send Ctrl+Space then 'w' to tmux
        # This shows the window list in tmux
        {
          key = "W";
          mods = "Control|Shift";
          chars = "\u0001\u0077"; # Unicode for Ctrl+Space, w
        }
        
        # Ctrl+Shift+N: Send Ctrl+Space then 'n' to tmux
        # This navigates to the next window in tmux
        {
          key = "N";
          mods = "Control|Shift";
          chars = "\u0001\u006e"; # Unicode for Ctrl+Space, n
        }
        
        # Ctrl+Shift+P: Send Ctrl+Space then 'p' to tmux
        # This navigates to the previous window in tmux
        {
          key = "P";
          mods = "Control|Shift";
          chars = "\u0001\u0070"; # Unicode for Ctrl+Space, p
        }
        
        # ----- Tmux Pane Management -----
        # Ctrl+Shift+H: Send Ctrl+Space then '\' to tmux
        # This splits the current pane horizontally
        {
          key = "H";
          mods = "Control|Shift";
          chars = "\u0001\u005c"; # Unicode for Ctrl+Space, \
        }
        
        # Ctrl+Shift+V: Send Ctrl+Space then '-' to tmux
        # This splits the current pane vertically
        {
          key = "V";
          mods = "Control|Shift";
          chars = "\u0001\u002d"; # Unicode for Ctrl+Space, -
        }

        # ----- Clipboard Operations -----
        # Ctrl+V: Paste from clipboard
        {
          key = "V";
          mods = "Control";
          action = "Paste";
        }
        
        # Ctrl+C: Copy to clipboard
        {
          key = "C";
          mods = "Control";
          action = "Copy";
        }
        
        # ----- Terminal Operations -----
        # Ctrl+L: Clear terminal screen
        # Sends the form feed character (ASCII 12)
        {
          key = "L";
          mods = "Control";
          chars = "\u000c"; # Unicode for Ctrl+L (form feed)
        }
      ];
    };
  };
}
