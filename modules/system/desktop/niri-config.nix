# modules/system/desktop/niri-config.nix
# Niri configuration that reproduces the default settings
{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.niri = {
    # Basic configuration following default niri config.kdl
    settings = {
      # Input configuration
      input = {
        keyboard = {
          xkb = {
            # Empty default, will use system settings
          };
        };

        # Libinput settings - match default config
        touchpad = {
          enable = true;
          tap = true;
          natural-scroll = true;
        };

        mouse = {
          enable = true;
        };

        trackpoint = {
          enable = true;
        };

        # Input focus behavior
        warp-mouse-to-focus = false;
        focus-follows-mouse.enable = false;
      };

      # Layout settings
      layout = {
        # Set gaps around windows in logical pixels
        gaps = 16;

        # Default focus behavior
        center-focused-column = "never";

        # Column width presets
        preset-column-widths = [
          { proportion = 0.33333; }
          { proportion = 0.5; }
          { proportion = 0.66667; }
        ];

        # Default column width
        default-column-width = {
          proportion = 0.5;
        };

        # Focus ring configuration
        focus-ring = {
          enable = true;
          width = 4;
          active-color = "#7fc8ff";
          inactive-color = "#505050";
        };

        # Border configuration (disabled by default)
        border = {
          enable = false;
          width = 4;
          active-color = "#ffc87f";
          inactive-color = "#505050";
        };

        # Shadow configuration (disabled by default)
        shadow = {
          enable = false;
          softness = 30;
          spread = 5;
          offset = {
            x = 0;
            y = 5;
          };
          color = "#0007";
        };

        # Struts (disabled in default config)
        struts = {
          left = 0;
          right = 0;
          top = 0;
          bottom = 0;
        };
      };

      # Start waybar at startup (default behavior)
      spawn-at-startup = [
        "waybar"
      ];

      # Screenshot path
      screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

      # Animation settings (enabled by default)
      animations = {
        enable = true;
      };

      # Window rules
      window-rules = [
        # WezTerm initial configure bug workaround
        {
          matches = [
            { app-id = "^org\\.wezfurlong\\.wezterm$"; }
          ];
          default-column-width = {};
        }
        # Firefox picture-in-picture floating
        {
          matches = [
            { 
              app-id = "firefox$";
              title = "^Picture-in-Picture$";
            }
          ];
          open-floating = true;
        }
      ];

      # Hotkey binds - match default config
      binds = {
        # Help overlay
        "Mod+Shift+Slash" = {
          action = { show-hotkey-overlay = null; };
        };

        # Basic applications
        "Mod+T" = {
          action = { spawn = "alacritty"; };
          hotkey-overlay.title = "Open a Terminal: alacritty";
        };
        "Mod+D" = {
          action = { spawn = "fuzzel"; };
          hotkey-overlay.title = "Run an Application: fuzzel";
        };
        "Super+Alt+L" = {
          action = { spawn = "swaylock"; };
          hotkey-overlay.title = "Lock the Screen: swaylock";
        };

        # Media keys
        "XF86AudioRaiseVolume" = {
          action = { spawn = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+"]; };
          allow-when-locked = true;
        };
        "XF86AudioLowerVolume" = {
          action = { spawn = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-"]; };
          allow-when-locked = true;
        };
        "XF86AudioMute" = {
          action = { spawn = ["wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"]; };
          allow-when-locked = true;
        };
        "XF86AudioMicMute" = {
          action = { spawn = ["wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"]; };
          allow-when-locked = true;
        };

        # Overview
        "Mod+O" = {
          action = { toggle-overview = null; };
          repeat = false;
        };

        # Window management
        "Mod+Q" = { action = { close-window = null; }; };

        # Focus navigation
        "Mod+Left" = { action = { focus-column-left = null; }; };
        "Mod+Down" = { action = { focus-window-down = null; }; };
        "Mod+Up" = { action = { focus-window-up = null; }; };
        "Mod+Right" = { action = { focus-column-right = null; }; };
        "Mod+H" = { action = { focus-column-left = null; }; };
        "Mod+J" = { action = { focus-window-down = null; }; };
        "Mod+K" = { action = { focus-window-up = null; }; };
        "Mod+L" = { action = { focus-column-right = null; }; };

        # Window movement
        "Mod+Ctrl+Left" = { action = { move-column-left = null; }; };
        "Mod+Ctrl+Down" = { action = { move-window-down = null; }; };
        "Mod+Ctrl+Up" = { action = { move-window-up = null; }; };
        "Mod+Ctrl+Right" = { action = { move-column-right = null; }; };
        "Mod+Ctrl+H" = { action = { move-column-left = null; }; };
        "Mod+Ctrl+J" = { action = { move-window-down = null; }; };
        "Mod+Ctrl+K" = { action = { move-window-up = null; }; };
        "Mod+Ctrl+L" = { action = { move-column-right = null; }; };

        # Column movement
        "Mod+Home" = { action = { focus-column-first = null; }; };
        "Mod+End" = { action = { focus-column-last = null; }; };
        "Mod+Ctrl+Home" = { action = { move-column-to-first = null; }; };
        "Mod+Ctrl+End" = { action = { move-column-to-last = null; }; };

        # Monitor focus
        "Mod+Shift+Left" = { action = { focus-monitor-left = null; }; };
        "Mod+Shift+Down" = { action = { focus-monitor-down = null; }; };
        "Mod+Shift+Up" = { action = { focus-monitor-up = null; }; };
        "Mod+Shift+Right" = { action = { focus-monitor-right = null; }; };
        "Mod+Shift+H" = { action = { focus-monitor-left = null; }; };
        "Mod+Shift+J" = { action = { focus-monitor-down = null; }; };
        "Mod+Shift+K" = { action = { focus-monitor-up = null; }; };
        "Mod+Shift+L" = { action = { focus-monitor-right = null; }; };

        # Move column to monitor
        "Mod+Shift+Ctrl+Left" = { action = { move-column-to-monitor-left = null; }; };
        "Mod+Shift+Ctrl+Down" = { action = { move-column-to-monitor-down = null; }; };
        "Mod+Shift+Ctrl+Up" = { action = { move-column-to-monitor-up = null; }; };
        "Mod+Shift+Ctrl+Right" = { action = { move-column-to-monitor-right = null; }; };
        "Mod+Shift+Ctrl+H" = { action = { move-column-to-monitor-left = null; }; };
        "Mod+Shift+Ctrl+J" = { action = { move-column-to-monitor-down = null; }; };
        "Mod+Shift+Ctrl+K" = { action = { move-column-to-monitor-up = null; }; };
        "Mod+Shift+Ctrl+L" = { action = { move-column-to-monitor-right = null; }; };

        # Workspace navigation
        "Mod+Page_Down" = { action = { focus-workspace-down = null; }; };
        "Mod+Page_Up" = { action = { focus-workspace-up = null; }; };
        "Mod+U" = { action = { focus-workspace-down = null; }; };
        "Mod+I" = { action = { focus-workspace-up = null; }; };
        
        # Move column to workspace
        "Mod+Ctrl+Page_Down" = { action = { move-column-to-workspace-down = null; }; };
        "Mod+Ctrl+Page_Up" = { action = { move-column-to-workspace-up = null; }; };
        "Mod+Ctrl+U" = { action = { move-column-to-workspace-down = null; }; };
        "Mod+Ctrl+I" = { action = { move-column-to-workspace-up = null; }; };

        # Move workspace
        "Mod+Shift+Page_Down" = { action = { move-workspace-down = null; }; };
        "Mod+Shift+Page_Up" = { action = { move-workspace-up = null; }; };
        "Mod+Shift+U" = { action = { move-workspace-down = null; }; };
        "Mod+Shift+I" = { action = { move-workspace-up = null; }; };

        # Mouse wheel binds
        "Mod+WheelScrollDown" = {
          action = { focus-workspace-down = null; };
          cooldown-ms = 150;
        };
        "Mod+WheelScrollUp" = {
          action = { focus-workspace-up = null; };
          cooldown-ms = 150;
        };
        "Mod+Ctrl+WheelScrollDown" = {
          action = { move-column-to-workspace-down = null; };
          cooldown-ms = 150;
        };
        "Mod+Ctrl+WheelScrollUp" = {
          action = { move-column-to-workspace-up = null; };
          cooldown-ms = 150;
        };
        
        "Mod+WheelScrollRight" = { action = { focus-column-right = null; }; };
        "Mod+WheelScrollLeft" = { action = { focus-column-left = null; }; };
        "Mod+Ctrl+WheelScrollRight" = { action = { move-column-right = null; }; };
        "Mod+Ctrl+WheelScrollLeft" = { action = { move-column-left = null; }; };

        # Shifted scroll
        "Mod+Shift+WheelScrollDown" = { action = { focus-column-right = null; }; };
        "Mod+Shift+WheelScrollUp" = { action = { focus-column-left = null; }; };
        "Mod+Ctrl+Shift+WheelScrollDown" = { action = { move-column-right = null; }; };
        "Mod+Ctrl+Shift+WheelScrollUp" = { action = { move-column-left = null; }; };

        # Workspace number binds
        "Mod+1" = { action = { focus-workspace = 1; }; };
        "Mod+2" = { action = { focus-workspace = 2; }; };
        "Mod+3" = { action = { focus-workspace = 3; }; };
        "Mod+4" = { action = { focus-workspace = 4; }; };
        "Mod+5" = { action = { focus-workspace = 5; }; };
        "Mod+6" = { action = { focus-workspace = 6; }; };
        "Mod+7" = { action = { focus-workspace = 7; }; };
        "Mod+8" = { action = { focus-workspace = 8; }; };
        "Mod+9" = { action = { focus-workspace = 9; }; };
        
        "Mod+Ctrl+1" = { action = { move-column-to-workspace = 1; }; };
        "Mod+Ctrl+2" = { action = { move-column-to-workspace = 2; }; };
        "Mod+Ctrl+3" = { action = { move-column-to-workspace = 3; }; };
        "Mod+Ctrl+4" = { action = { move-column-to-workspace = 4; }; };
        "Mod+Ctrl+5" = { action = { move-column-to-workspace = 5; }; };
        "Mod+Ctrl+6" = { action = { move-column-to-workspace = 6; }; };
        "Mod+Ctrl+7" = { action = { move-column-to-workspace = 7; }; };
        "Mod+Ctrl+8" = { action = { move-column-to-workspace = 8; }; };
        "Mod+Ctrl+9" = { action = { move-column-to-workspace = 9; }; };

        # Window column operations
        "Mod+BracketLeft" = { action = { consume-or-expel-window-left = null; }; };
        "Mod+BracketRight" = { action = { consume-or-expel-window-right = null; }; };
        "Mod+Comma" = { action = { consume-window-into-column = null; }; };
        "Mod+Period" = { action = { expel-window-from-column = null; }; };

        # Column size operations
        "Mod+R" = { action = { switch-preset-column-width = null; }; };
        "Mod+Shift+R" = { action = { switch-preset-window-height = null; }; };
        "Mod+Ctrl+R" = { action = { reset-window-height = null; }; };
        "Mod+F" = { action = { maximize-column = null; }; };
        "Mod+Shift+F" = { action = { fullscreen-window = null; }; };
        "Mod+Ctrl+F" = { action = { expand-column-to-available-width = null; }; };
        "Mod+C" = { action = { center-column = null; }; };

        # Column width adjustments
        "Mod+Minus" = { action = { set-column-width = "-10%"; }; };
        "Mod+Equal" = { action = { set-column-width = "+10%"; }; };

        # Window height adjustments
        "Mod+Shift+Minus" = { action = { set-window-height = "-10%"; }; };
        "Mod+Shift+Equal" = { action = { set-window-height = "+10%"; }; };

        # Floating window controls
        "Mod+V" = { action = { toggle-window-floating = null; }; };
        "Mod+Shift+V" = { action = { switch-focus-between-floating-and-tiling = null; }; };

        # Tabbed column display mode
        "Mod+W" = { action = { toggle-column-tabbed-display = null; }; };

        # Screenshot
        "Print" = { action = { screenshot = null; }; };
        "Ctrl+Print" = { action = { screenshot-screen = null; }; };
        "Alt+Print" = { action = { screenshot-window = null; }; };

        # Keyboard shortcuts inhibit toggle (escape hatch)
        "Mod+Escape" = { 
          action = { toggle-keyboard-shortcuts-inhibit = null; };
          allow-inhibiting = false;
        };

        # Quit actions
        "Mod+Shift+E" = { action = { quit = null; }; };
        "Ctrl+Alt+Delete" = { action = { quit = null; }; };

        # Power off monitors
        "Mod+Shift+P" = { action = { power-off-monitors = null; }; };
      };
    };
  };
}