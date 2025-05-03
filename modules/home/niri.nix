# modules/home/niri-minimal.nix
{
  config,
  lib,
  ...
}: let
  cfg = config.wm;
in {
  config = {
    # Niri configuration
    programs.niri.settings = {
      # Input configuration
      input = {
        keyboard.xkb = {
          layout = cfg.keyboard.layout;
          variant = cfg.keyboard.variant;
          options = cfg.keyboard.options;
        };
        touchpad = {
          tap = true;
          natural-scroll = true;
        };
        mouse = {};
      };

      # Layout configuration
      layout = {
        gaps = 16;
        center-focused-column = "never";
        preset-column-widths = [
          {proportion = 0.33333;}
          {proportion = 0.5;}
          {proportion = 0.66667;}
        ];
        default-column-width = {
          proportion = 0.5;
        };
        focus-ring = {
          width = 4;
          active.color = "#7fc8ff";
          inactive.color = "#505050";
        };
        border.width = 2;
        shadow.enable = true;
      };

      # Screenshot path
      screenshot-path = cfg.screenshots.path;

      # Spawn programs at startup
      spawn-at-startup = [
        {command = ["waybar"];}
        {command = ["swaync"];}
        {command = ["swaybg" "-m" cfg.wallpaper.mode "-i" cfg.wallpaper.path];}
      ];

      # Key bindings
      binds = {
        # Hotkey overlay - mostra la lista dei tasti
        "Mod+Shift+S" = {action = {show-hotkey-overlay = {};};};

        # Terminal - spawn alacritty
        "Mod+M" = {action = {spawn = "alacritty";};};

        # Application menu - spawn fuzzel
        "Mod+A" = {action = {spawn = "fuzzel";};};

        # Notifications - avvia swaync-client
        "Mod+N" = {action = {spawn = "swaync-client -t -sw";};};

        # Lock screen - usa il nostro script comune
        "Mod+L" = {action = {spawn = "screen-locker";};};

        # Logout menu
        "Mod+Escape" = {action = {spawn = "wlogout";};};

        # Audio controls
        "XF86AudioRaiseVolume" = {action = {spawn = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+"];};};
        "XF86AudioLowerVolume" = {action = {spawn = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-"];};};
        "XF86AudioMute" = {action = {spawn = ["wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"];};};

        # Overview
        "Mod+O" = {action = {toggle-overview = {};};};

        # Window management
        "Mod+BackSpace" = {action = {close-window = {};};};

        # Window navigation
        "Alt+Tab" = {action = {focus-column-right = {};};};
        "Alt+Shift+Tab" = {action = {focus-column-left = {};};};

        # Direction-based navigation
        "Mod+Left" = {action = {focus-column-left = {};};};
        "Mod+Down" = {action = {focus-window-down = {};};};
        "Mod+Up" = {action = {focus-window-up = {};};};
        "Mod+Right" = {action = {focus-column-right = {};};};

        # Window movement
        "Mod+Ctrl+Left" = {action = {move-column-left = {};};};
        "Mod+Ctrl+Down" = {action = {move-window-down = {};};};
        "Mod+Ctrl+Up" = {action = {move-window-up = {};};};
        "Mod+Ctrl+Right" = {action = {move-column-right = {};};};

        # Monitor focus
        "Mod+Shift+Left" = {action = {focus-monitor-left = {};};};
        "Mod+Shift+Down" = {action = {focus-monitor-down = {};};};
        "Mod+Shift+Up" = {action = {focus-monitor-up = {};};};
        "Mod+Shift+Right" = {action = {focus-monitor-right = {};};};

        # Move to monitor
        "Mod+Shift+Ctrl+Left" = {action = {move-column-to-monitor-left = {};};};
        "Mod+Shift+Ctrl+Down" = {action = {move-column-to-monitor-down = {};};};
        "Mod+Shift+Ctrl+Up" = {action = {move-column-to-monitor-up = {};};};
        "Mod+Shift+Ctrl+Right" = {action = {move-column-to-monitor-right = {};};};

        # Workspace navigation
        "Mod+Page_Down" = {action = {focus-workspace-down = {};};};
        "Mod+Page_Up" = {action = {focus-workspace-up = {};};};

        # Move to workspace
        "Mod+Ctrl+Page_Down" = {action = {move-column-to-workspace-down = {};};};
        "Mod+Ctrl+Page_Up" = {action = {move-column-to-workspace-up = {};};};

        # Workspace focus
        "Mod+1" = {action = {focus-workspace = 1;};};
        "Mod+2" = {action = {focus-workspace = 2;};};
        "Mod+3" = {action = {focus-workspace = 3;};};
        "Mod+4" = {action = {focus-workspace = 4;};};
        "Mod+5" = {action = {focus-workspace = 5;};};
        "Mod+6" = {action = {focus-workspace = 6;};};
        "Mod+7" = {action = {focus-workspace = 7;};};
        "Mod+8" = {action = {focus-workspace = 8;};};
        "Mod+9" = {action = {focus-workspace = 9;};};

        # Move to workspace
        "Mod+Ctrl+1" = {action = {move-column-to-workspace = 1;};};
        "Mod+Ctrl+2" = {action = {move-column-to-workspace = 2;};};
        "Mod+Ctrl+3" = {action = {move-column-to-workspace = 3;};};
        "Mod+Ctrl+4" = {action = {move-column-to-workspace = 4;};};
        "Mod+Ctrl+5" = {action = {move-column-to-workspace = 5;};};
        "Mod+Ctrl+6" = {action = {move-column-to-workspace = 6;};};
        "Mod+Ctrl+7" = {action = {move-column-to-workspace = 7;};};
        "Mod+Ctrl+8" = {action = {move-column-to-workspace = 8;};};
        "Mod+Ctrl+9" = {action = {move-column-to-workspace = 9;};};

        # Consume/Expel window management
        "Mod+BracketLeft" = {action = {consume-or-expel-window-left = {};};};
        "Mod+BracketRight" = {action = {consume-or-expel-window-right = {};};};

        # Column operations
        "Mod+Comma" = {action = {consume-window-into-column = {};};};
        "Mod+Period" = {action = {expel-window-from-column = {};};};
        "Mod+R" = {action = {switch-preset-column-width = {};};};
        "Mod+F" = {action = {maximize-column = {};};};
        "Mod+Shift+F" = {action = {fullscreen-window = {};};};
        "Mod+C" = {action = {center-column = {};};};

        # Size adjustments
        "Mod+Minus" = {action = {set-column-width = "-10%";};};
        "Mod+Equal" = {action = {set-column-width = "+10%";};};
        "Mod+Shift+Minus" = {action = {set-window-height = "-10%";};};
        "Mod+Shift+Equal" = {action = {set-window-height = "+10%";};};

        # Window modes
        "Mod+V" = {action = {toggle-window-floating = {};};};
        "Mod+Shift+V" = {action = {switch-focus-between-floating-and-tiling = {};};};
        "Mod+Space" = {action = {toggle-column-tabbed-display = {};};};

        # Screenshots
        "Print" = {action = {screenshot = {};};};
        "Ctrl+Print" = {action = {screenshot-screen = {};};};
        "Alt+Print" = {action = {screenshot-window = {};};};

        # System
        "Mod+Shift+P" = {action = {power-off-monitors = {};};};
        "Mod+Alt+E" = {action = {quit = {};};};
        "Ctrl+Alt+Delete" = {action = {quit = {};};};
      };
    };
  };
}
