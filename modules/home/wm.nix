# modules/home/wm.nix
# Common home-manager configuration for Wayland window managers (Hyprland, Niri)
{ config, pkgs, lib, ... }:

let
  # Get configuration with defaults
  cfg = config.wayland-wm;

  # Import colors module for consistent theming across WMs
  colors = import ./colors.nix;

  # Create lock script that can be used by different components
  lockScreenScript = pkgs.writeShellScriptBin "lock-screen" ''
    ${pkgs.swaylock}/bin/swaylock \
      --color "${colors.background}" \
      --inside-color "${colors.background}" \
      --ring-color "${colors.blue}" \
      --inside-wrong-color "${colors.red}" \
      --ring-wrong-color "${colors.red}" \
      --inside-ver-color "${colors.yellow}" \
      --ring-ver-color "${colors.yellow}" \
      --indicator
  '';

  # Import wlogout configuration with lock script
  wlogoutConfig = import ./wlogout.nix { inherit lockScreenScript; };

  # Waybar configuration with colors
  waybarConfig = import ./waybar.nix {
    inherit pkgs colors;
  };
  
  # Semplice script per avviare SwayNC manualmente
  swayncStartScript = pkgs.writeShellScriptBin "start-swaync" ''
    #!/bin/sh
    # Crea directory di configurazione se non esiste
    mkdir -p $HOME/.config/swaync
    
    # Crea file di configurazione se non esiste
    if [ ! -f $HOME/.config/swaync/config.json ]; then
      cat > $HOME/.config/swaync/config.json << 'EOF'
{
  "$schema": "/etc/xdg/swaync/configSchema.json",
  "positionX": "right",
  "positionY": "top",
  "layer": "overlay",
  "cssPriority": "application",
  "control-center-margin-top": 10,
  "control-center-margin-bottom": 10,
  "control-center-margin-right": 10,
  "control-center-margin-left": 10,
  "notification-icon-size": 64,
  "notification-body-image-height": 100,
  "notification-body-image-width": 200,
  "timeout": 10,
  "timeout-low": 5,
  "timeout-critical": 0,
  "fit-to-screen": true,
  "control-center-width": 400,
  "notification-window-width": 400,
  "keyboard-shortcuts": true,
  "image-visibility": "when-available",
  "transition-time": 200,
  "hide-on-clear": true,
  "hide-on-action": true,
  "script-fail-notify": true,
  "widgets": [
    "title",
    "dnd",
    "notifications",
    "buttons-grid"
  ],
  "widgets-config": {
    "buttons-grid": {
      "actions": [
        {
          "label": "Clear All",
          "command": "swaync-client -C"
        },
        {
          "label": "Settings",
          "command": "gnome-control-center"
        }
      ]
    },
    "dnd": {
      "text": "Do Not Disturb"
    }
  }
}
EOF
    fi
    
    # Crea CSS se non esiste
    if [ ! -f $HOME/.config/swaync/style.css ]; then
      cat > $HOME/.config/swaync/style.css << 'EOF'
* {
  font-family: "JetBrainsMono Nerd Font", sans-serif;
  font-size: 14px;
}

.control-center {
  background-color: ${colors.background};
  border-radius: 10px;
  border: 2px solid ${colors.blue};
  color: ${colors.foreground};
}

.notification-row {
  outline: none;
  margin: 10px;
  padding: 8px;
}

.notification {
  background-color: rgba(40, 42, 54, 0.7);
  border-radius: 8px;
  border: 1px solid ${colors.blue};
  margin: 6px;
  box-shadow: 0px 2px 4px rgba(0, 0, 0, 0.3);
}

.notification-content {
  padding: 6px;
  margin: 6px;
}

.title {
  font-weight: bold;
  color: ${colors.yellow};
  margin: 6px;
}

.body {
  color: ${colors.foreground};
}

.button-container {
  margin: 8px;
}

.button {
  background-color: ${colors.black};
  color: ${colors.foreground};
  border-radius: 5px;
  border: 1px solid ${colors.blue};
  padding: 6px 10px;
  margin: 5px;
}

.button:hover {
  background-color: ${colors.blue};
  color: ${colors.background};
}

.dnd-button {
  background-color: ${colors.background};
  color: ${colors.foreground};
  border-radius: 5px;
  border: 1px solid ${colors.purple};
  padding: 6px 10px;
  margin: 5px;
}

.dnd-button:hover {
  background-color: ${colors.purple};
  color: ${colors.background};
}

.widget-dnd {
  margin: 8px;
  font-size: 15px;
}

.widget-dnd > switch {
  border-radius: 5px;
  background-color: ${colors.red};
}

.widget-dnd > switch:checked {
  background-color: ${colors.green};
}

.widget-buttons-grid {
  margin: 10px;
}
EOF
    fi
    
    # Avvia SwayNC
    ${pkgs.swaynotificationcenter}/bin/swaync
  '';
in {
  options.wayland-wm = {
    enable = lib.mkEnableOption "Enable common Wayland WM configuration";

    # Opzioni separate per ogni window manager
    enableHyprland = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Hyprland window manager";
    };

    enableNiri = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Niri window manager";
    };

    # Configurazione per la tastiera
    keyboard = {
      layout = lib.mkOption {
        type = lib.types.str;
        default = "us";
        description = "Keyboard layout";
      };

      variant = lib.mkOption {
        type = lib.types.str;
        default = "intl";
        description = "Keyboard variant";
      };

      options = lib.mkOption {
        type = lib.types.str;
        default = "ralt:compose";
        description = "Keyboard options";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Common packages for Wayland WMs
    home.packages = with pkgs; [
      # App launchers
      fuzzel

      # System utilities
      wl-clipboard
      pamixer
      brightnessctl
      grim
      slurp

      # Logout menu
      wlogout

      # Lock screen utils
      swaylock

      # Add the lockscreen script
      lockScreenScript

      # Notification center
      swaynotificationcenter
      libnotify
      
      # Script per avviare SwayNC
      swayncStartScript
    ];

    # SwayLock configuration
    programs.swaylock = {
      enable = true;
      settings = {
        color = lib.removePrefix "#" colors.background;
        clock = true;
        show-failed-attempts = true;
        ignore-empty-password = true;
        indicator-caps-lock = true;
        indicator-radius = 100;
        indicator-thickness = 7;
        line-color = lib.removePrefix "#" colors.foreground;
        ring-color = lib.removePrefix "#" colors.blue;
        inside-color = lib.removePrefix "#" colors.background;
        key-hl-color = lib.removePrefix "#" colors.green;
        separator-color = lib.removePrefix "#" colors.purple;
        text-color = lib.removePrefix "#" colors.foreground;
      };
    };

    # Waybar configuration
    programs.waybar = waybarConfig;

    # Enable Hyprland if requested
    wayland.windowManager.hyprland = lib.mkIf cfg.enableHyprland {
      enable = true;
      systemd.enable = true;
      systemd.variables = ["--systemd-activation"];
      settings = {
        # General settings
        general = {
          gaps_in = 5;
          gaps_out = 10;
          border_size = 2;
          "col.active_border" = "rgba(${colors.blue}ee)";
          "col.inactive_border" = "rgba(${colors.brightBlack}aa)";
          layout = "dwindle";
        };

        # Input configuration
        input = {
          kb_layout = cfg.keyboard.layout;
          kb_variant = cfg.keyboard.variant;
          kb_options = cfg.keyboard.options;

          follow_mouse = 1;
          touchpad = {
            natural_scroll = true;
            disable_while_typing = true;
            tap-to-click = true;
          };
        };

        # Animations
        animations = {
          enabled = true;
          bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
          animation = [
            "windows, 1, 7, myBezier"
            "windowsOut, 1, 7, default, popin 80%"
            "border, 1, 10, default"
            "fade, 1, 7, default"
            "workspaces, 1, 6, default"
          ];
        };

        # Decorations
        decoration = {
          rounding = 10;
          blur = {
            enabled = true;
            size = 5;
            passes = 3;
            new_optimizations = true;
          };
          drop_shadow = true;
          shadow_range = 15;
          shadow_render_power = 3;
          "col.shadow" = "rgba(0000001a)";
        };

        # Window layout
        dwindle = {
          pseudotile = true;
          preserve_split = true;
          force_split = 2;
        };

        # Miscellaneous configurations
        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          mouse_move_enables_dpms = true;
          key_press_enables_dpms = true;
          enable_swallow = true;
          swallow_regex = "^(Alacritty)$";
        };

        # Startup applications
        exec-once = [
          "waybar"
          "start-swaync"
        ];

        # Window rules
        windowrule = [
          "float,^(pavucontrol)$"
          "float,^(nm-connection-editor)$"
          "float,^(wlogout)$"
          "float,title:^(Picture-in-Picture)$"
          "pin,title:^(Picture-in-Picture)$"
        ];

        # Keyboard shortcuts
        bind = [
          # Basic applications
          "SUPER, T, exec, alacritty"
          "SUPER, D, exec, fuzzel"
          "SUPER, B, exec, firefox"
          "SUPER, E, exec, nautilus"
          "SUPER, N, exec, swaync-client -t -sw"

          # Window controls
          "SUPER, Q, killactive,"
          "SUPER, Space, togglefloating,"
          "SUPER, F, fullscreen,"
          "SUPER, P, pseudo,"
          "SUPER, J, togglesplit,"

          # Window focus navigation
          "SUPER, Left, movefocus, l"
          "SUPER, Right, movefocus, r"
          "SUPER, Up, movefocus, u"
          "SUPER, Down, movefocus, d"
          "SUPER, H, movefocus, l"
          "SUPER, L, movefocus, r"
          "SUPER, K, movefocus, u"
          "SUPER, J, movefocus, d"

          # Window move
          "SUPER SHIFT, Left, movewindow, l"
          "SUPER SHIFT, Right, movewindow, r"
          "SUPER SHIFT, Up, movewindow, u"
          "SUPER SHIFT, Down, movewindow, d"
          "SUPER SHIFT, H, movewindow, l"
          "SUPER SHIFT, L, movewindow, r"
          "SUPER SHIFT, K, movewindow, u"
          "SUPER SHIFT, J, movewindow, d"

          # Window resize
          "SUPER ALT, Left, resizeactive, -20 0"
          "SUPER ALT, Right, resizeactive, 20 0"
          "SUPER ALT, Up, resizeactive, 0 -20"
          "SUPER ALT, Down, resizeactive, 0 20"
          "SUPER ALT, H, resizeactive, -20 0"
          "SUPER ALT, L, resizeactive, 20 0"
          "SUPER ALT, K, resizeactive, 0 -20"
          "SUPER ALT, J, resizeactive, 0 20"

          # Window/application navigation
          "ALT, Tab, cyclenext,"
          "ALT SHIFT, Tab, cyclenext, prev"

          # Workspace navigation (numbers 1-9)
          "SUPER, 1, workspace, 1"
          "SUPER, 2, workspace, 2"
          "SUPER, 3, workspace, 3"
          "SUPER, 4, workspace, 4"
          "SUPER, 5, workspace, 5"
          "SUPER, 6, workspace, 6"
          "SUPER, 7, workspace, 7"
          "SUPER, 8, workspace, 8"
          "SUPER, 9, workspace, 9"

          # Additional workspace navigation
          "SUPER CTRL, Right, workspace, e+1"
          "SUPER CTRL, Left, workspace, e-1"
          "SUPER, Page_Down, workspace, e+1"
          "SUPER, Page_Up, workspace, e-1"

          # Moving windows between workspaces
          "SUPER SHIFT, 1, movetoworkspace, 1"
          "SUPER SHIFT, 2, movetoworkspace, 2"
          "SUPER SHIFT, 3, movetoworkspace, 3"
          "SUPER SHIFT, 4, movetoworkspace, 4"
          "SUPER SHIFT, 5, movetoworkspace, 5"
          "SUPER SHIFT, 6, movetoworkspace, 6"
          "SUPER SHIFT, 7, movetoworkspace, 7"
          "SUPER SHIFT, 8, movetoworkspace, 8"
          "SUPER SHIFT, 9, movetoworkspace, 9"
          "SUPER SHIFT, Right, movetoworkspace, e+1"
          "SUPER SHIFT, Left, movetoworkspace, e-1"
          "SUPER SHIFT, Page_Down, movetoworkspace, e+1"
          "SUPER SHIFT, Page_Up, movetoworkspace, e-1"

          # Screenshots
          "SUPER SHIFT, S, exec, grim -g \"$(slurp)\" - | wl-copy"
          ", Print, exec, grim - | wl-copy"
          "SHIFT, Print, exec, grim -g \"$(slurp)\" - | wl-copy"

          # Logout menu
          "SUPER, Escape, exec, wlogout"
        ];

        # Mouse bindings
        bindm = [
          "SUPER, mouse:272, movewindow"
          "SUPER, mouse:273, resizewindow"
        ];
      };
    };
    
    # Add Niri configuration if enabled
    xdg.configFile."niri/config.kdl".text = lib.mkIf cfg.enableNiri ''
      input {
          keyboard {
              xkb {
                  layout "${cfg.keyboard.layout}"
                  variant "${cfg.keyboard.variant}"
                  options "${cfg.keyboard.options}"
              }
          }

          touchpad {
              tap
              natural-scroll
          }

          mouse {}
          trackpoint {}
      }

      layout {
          gaps 16
          center-focused-column "never"
          preset-column-widths {
              proportion 0.33333
              proportion 0.5
              proportion 0.66667
          }
          default-column-width { proportion 0.5; }

          focus-ring {
              width 4
              active-color "#7fc8ff"
              inactive-color "#505050"
          }

          border { off }

          shadow { on }
      }

      spawn-at-startup "waybar"
      spawn-at-startup "start-swaync"
      screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

      animations {
          enable = true;
      }

      binds {
          Mod+Shift+S { show-hotkey-overlay; }
          Mod+T { spawn "alacritty"; }
          Mod+D { spawn "fuzzel"; }
          Super+Alt+L { spawn "swaylock"; }
          
          XF86AudioRaiseVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+"; }
          XF86AudioLowerVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-"; }
          XF86AudioMute        allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
          XF86AudioMicMute     allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"; }

          Mod+O repeat=false { toggle-overview; }
          Mod+BackSpace { close-window; }

          Mod+Left  { focus-column-left; }
          Mod+Down  { focus-window-down; }
          Mod+Up    { focus-window-up; }
          Mod+Right { focus-column-right; }
          Mod+H     { focus-column-left; }
          Mod+J     { focus-window-down; }
          Mod+K     { focus-window-up; }
          Mod+L     { focus-column-right; }

          Mod+Ctrl+Left  { move-column-left; }
          Mod+Ctrl+Down  { move-window-down; }
          Mod+Ctrl+Up    { move-window-up; }
          Mod+Ctrl+Right { move-column-right; }
          Mod+Ctrl+H     { move-column-left; }
          Mod+Ctrl+J     { move-window-down; }
          Mod+Ctrl+K     { move-window-up; }
          Mod+Ctrl+L     { move-column-right; }

          Mod+Home { focus-column-first; }
          Mod+End  { focus-column-last; }
          Mod+Ctrl+Home { move-column-to-first; }
          Mod+Ctrl+End  { move-column-to-last; }

          Mod+Shift+Left  { focus-monitor-left; }
          Mod+Shift+Down  { focus-monitor-down; }
          Mod+Shift+Up    { focus-monitor-up; }
          Mod+Shift+Right { focus-monitor-right; }
          Mod+Shift+H     { focus-monitor-left; }
          Mod+Shift+J     { focus-monitor-down; }
          Mod+Shift+K     { focus-monitor-up; }
          Mod+Shift+L     { focus-monitor-right; }

          Mod+Shift+Ctrl+Left  { move-column-to-monitor-left; }
          Mod+Shift+Ctrl+Down  { move-column-to-monitor-down; }
          Mod+Shift+Ctrl+Up    { move-column-to-monitor-up; }
          Mod+Shift+Ctrl+Right { move-column-to-monitor-right; }
          Mod+Shift+Ctrl+H     { move-column-to-monitor-left; }
          Mod+Shift+Ctrl+J     { move-column-to-monitor-down; }
          Mod+Shift+Ctrl+K     { move-column-to-monitor-up; }
          Mod+Shift+Ctrl+L     { move-column-to-monitor-right; }

          Mod+Page_Down      { focus-workspace-down; }
          Mod+Page_Up        { focus-workspace-up; }
          Mod+U              { focus-workspace-down; }
          Mod+I              { focus-workspace-up; }
          Mod+Ctrl+Page_Down { move-column-to-workspace-down; }
          Mod+Ctrl+Page_Up   { move-column-to-workspace-up; }
          Mod+Ctrl+U         { move-column-to-workspace-down; }
          Mod+Ctrl+I         { move-column-to-workspace-up; }

          Mod+Shift+Page_Down { move-workspace-down; }
          Mod+Shift+Page_Up   { move-workspace-up; }
          Mod+Shift+U         { move-workspace-down; }
          Mod+Shift+I         { move-workspace-up; }

          Mod+WheelScrollDown      cooldown-ms=150 { focus-workspace-down; }
          Mod+WheelScrollUp        cooldown-ms=150 { focus-workspace-up; }
          Mod+Ctrl+WheelScrollDown cooldown-ms=150 { move-column-to-workspace-down; }
          Mod+Ctrl+WheelScrollUp   cooldown-ms=150 { move-column-to-workspace-up; }

          Mod+WheelScrollRight      { focus-column-right; }
          Mod+WheelScrollLeft       { focus-column-left; }
          Mod+Ctrl+WheelScrollRight { move-column-right; }
          Mod+Ctrl+WheelScrollLeft  { move-column-left; }

          Mod+Shift+WheelScrollDown      { focus-column-right; }
          Mod+Shift+WheelScrollUp        { focus-column-left; }
          Mod+Ctrl+Shift+WheelScrollDown { move-column-right; }
          Mod+Ctrl+Shift+WheelScrollUp   { move-column-left; }

          Mod+1 { focus-workspace 1; }
          Mod+2 { focus-workspace 2; }
          Mod+3 { focus-workspace 3; }
          Mod+4 { focus-workspace 4; }
          Mod+5 { focus-workspace 5; }
          Mod+6 { focus-workspace 6; }
          Mod+7 { focus-workspace 7; }
          Mod+8 { focus-workspace 8; }
          Mod+9 { focus-workspace 9; }
          Mod+Ctrl+1 { move-column-to-workspace 1; }
          Mod+Ctrl+2 { move-column-to-workspace 2; }
          Mod+Ctrl+3 { move-column-to-workspace 3; }
          Mod+Ctrl+4 { move-column-to-workspace 4; }
          Mod+Ctrl+5 { move-column-to-workspace 5; }
          Mod+Ctrl+6 { move-column-to-workspace 6; }
          Mod+Ctrl+7 { move-column-to-workspace 7; }
          Mod+Ctrl+8 { move-column-to-workspace 8; }
          Mod+Ctrl+9 { move-column-to-workspace 9; }

          Mod+BracketLeft  { consume-or-expel-window-left; }
          Mod+BracketRight { consume-or-expel-window-right; }

          Mod+Comma  { consume-window-into-column; }
          Mod+Period { expel-window-from-column; }

          Mod+R { switch-preset-column-width; }
          Mod+Shift+R { switch-preset-window-height; }
          Mod+Ctrl+R { reset-window-height; }
          Mod+F { maximize-column; }
          Mod+Shift+F { fullscreen-window; }
          Mod+Ctrl+F { expand-column-to-available-width; }
          Mod+C { center-column; }

          Mod+Minus { set-column-width "-10%"; }
          Mod+Equal { set-column-width "+10%"; }
          Mod+Shift+Minus { set-window-height "-10%"; }
          Mod+Shift+Equal { set-window-height "+10%"; }

          Mod+V       { toggle-window-floating; }
          Mod+Shift+V { switch-focus-between-floating-and-tiling; }
          Mod+W { toggle-column-tabbed-display; }

          Print { screenshot; }
          Ctrl+Print { screenshot-screen; }
          Alt+Print { screenshot-window; }

          Mod+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }
          Mod+Shift+E { quit; }
          Ctrl+Alt+Delete { quit; }
          Mod+Shift+P { power-off-monitors; }
      }
    '';
  };
}
