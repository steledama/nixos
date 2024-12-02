{ pkgs, ... }:
{
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        dimensions = {
          columns = 110;
          lines = 36;
        };
        padding = {
          x = 15;
          y = 15;
        };
        opacity = 0.9;
      };

      font = {
        normal.family = "DejaVu Sans Mono";
        bold.family = "DejaVu Sans Mono";
        italic.family = "DejaVu Sans Mono";
        bold_italic.family = "DejaVu Sans Mono";
        size = 14;
      };

      colors = {
        primary = {
          background = "#1E1E2E";
          foreground = "#CDD6F4";
        };
        cursor = {
          text = "#1E1E2E";
          cursor = "#F5E0DC";
        };
        normal = {
          black = "#45475A";
          red = "#F38BA8";
          green = "#A6E3A1";
          yellow = "#F9E2AF";
          blue = "#89B4FA";
          magenta = "#F5C2E7";
          cyan = "#94E2D5";
          white = "#BAC2DE";
        };
        bright = {
          black = "#585B70";
          red = "#F38BA8";
          green = "#A6E3A1";
          yellow = "#F9E2AF";
          blue = "#89B4FA";
          magenta = "#F5C2E7";
          cyan = "#94E2D5";
          white = "#A6ADC8";
        };
      };

      cursor.style = "Beam";

      keyboard.bindings = [
        {
          key = "V";
          mods = "Control|Shift";
          action = "Paste";
        }
        {
          key = "C";
          mods = "Control|Shift";
          action = "Copy";
        }
        {
          key = "Plus";
          mods = "Control|Shift";
          action = "IncreaseFontSize";
        }
        {
          key = "Minus";
          mods = "Control|Shift";
          action = "DecreaseFontSize";
        }
        {
          key = "Key0";
          mods = "Control";
          action = "ResetFontSize";
        }
      ];
    };
  };
}
