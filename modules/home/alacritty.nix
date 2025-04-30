# modules/home/alacritty.nix
{pkgs, ...}: {
  programs.alacritty = {
    enable = true;
    settings = {
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

      # Shell configuration - usando terminal.shell
      terminal = {
        shell = {
          program = "${pkgs.zsh}/bin/zsh";
          args = ["-l"];
        };
      };

      # Modality-based keyboard settings
      selection = {
        semantic_escape_chars = ",│`|:\"' ()[]{}<>";
        save_to_clipboard = true;
      };

      # Middle mouse paste
      mouse = {
        hide_when_typing = true;
      };

      keyboard = {
        bindings = [
          # In vi mode Ctrl+C copy selection
          {
            key = "C";
            mods = "Control";
            mode = "Vi|~Search";
            action = "Copy";
          }
          # In normal mode Ctrl+C standard
          {
            key = "C";
            mods = "Control";
            mode = "~Vi";
            action = "ReceiveChar";
          }

          # Ctrl+V allways paste
          {
            key = "V";
            mods = "Control";
            action = "Paste";
          }

          # Ctrl+Shift+Space toggle vi mode
          {
            key = "Space";
            mods = "Control|Shift";
            action = "ToggleViMode";
          }

          # Esc exit vi mode
          {
            key = "Escape";
            mode = "Vi";
            action = "ToggleViMode";
          }

          # Ctrl+Shift+T: Open a new Alacritty instance
          {
            key = "T";
            mods = "Control|Shift";
            action = "SpawnNewInstance";
          }

          # Arrow keys in vi mode
          {
            key = "J";
            mode = "Vi";
            action = "Down";
          }
          {
            key = "K";
            mode = "Vi";
            action = "Up";
          }
          {
            key = "H";
            mode = "Vi";
            action = "Left";
          }
          {
            key = "L";
            mode = "Vi";
            action = "Right";
          }

          # Space selection in vi mode
          {
            key = "Space";
            mode = "Vi";
            action = "ToggleSemanticSelection";
          }
        ];
      };

      # Cursor settings
      cursor = {
        style = {
          shape = "Block";
          blinking = "Always";
        };
        # vi mode cursor
        vi_mode_style = {
          shape = "Block";
          blinking = "Off";
        };
        blink_interval = 750;
        unfocused_hollow = true;
      };
    };
  };
}
