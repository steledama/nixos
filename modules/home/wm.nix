# modules/home/wm.nix
# Common home-manager configuration for Wayland window managers (Hyprland, Niri)
{
  config,
  pkgs,
  lib,
  ...
}: let
  # Get configuration with defaults
  cfg = config.wayland-wm;
in {
  options.wayland-wm = {
    enable = lib.mkEnableOption "Enable common Wayland WM configuration";

    # window managers options
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

    # Keyboard layout
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

      # Notification center - solo il pacchetto, nessuna configurazione personalizzata
      swaynotificationcenter
      libnotify
    ];

    # SwayLock configuration
    programs.swaylock = {
      enable = true;
      settings = {
        clock = true;
        show-failed-attempts = true;
        ignore-empty-password = true;
        indicator-caps-lock = true;
        indicator-radius = 100;
        indicator-thickness = 7;
      };
    };

    # Waybar configuration
    programs.waybar = {
      enable = true;
      systemd.enable = false;
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 32;
          margin = "5 5 0 5";
          spacing = 4;

          modules-left = ["custom/menu" "network"];
          modules-center = ["custom/datetime"];
          modules-right = ["custom/notifications" "pulseaudio" "battery" "custom/wlogout" "tray"];

          # Menu button
          "custom/menu" = {
            format = "󰀻";
            tooltip = "Application Menu";
            on-click = "fuzzel";
          };

          # Date and time
          "custom/datetime" = {
            exec = "date +'%A, %B %d  %H:%M'";
            interval = 30;
            format = "{}";
            tooltip = false;
          };

          # Notification center
          "custom/notifications" = {
            format = "󰂚";
            tooltip = "Notifications";
            on-click = "swaync-client -t -sw";
            on-click-right = "swaync-client -C";
          };

          # System tray
          "tray" = {
            spacing = 10;
          };

          # Network status
          "network" = {
            format-wifi = "  {essid}";
            format-ethernet = "󰈀 Connected";
            format-disconnected = "󰤭 Disconnected";
            tooltip-format = "{ifname}: {ipaddr}/{cidr}";
            on-click = "nm-connection-editor";
          };

          # Audio control
          "pulseaudio" = {
            format = "{icon} {volume}%";
            format-muted = "󰖁 Muted";
            format-icons = {
              default = ["󰕿" "󰖀" "󰕾"];
            };
            on-click = "pavucontrol";
          };

          # Battery status
          "battery" = {
            format = "{icon} {capacity}%";
            format-icons = ["󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
            format-charging = "󰂄 {capacity}%";
            interval = 30;
            states = {
              warning = 30;
              critical = 15;
            };
          };

          # Logout button
          "custom/wlogout" = {
            format = "⏻";
            tooltip = "Session";
            on-click = "wlogout";
          };
        };
      };

      style = ''
        * {
          font-family: "JetBrainsMono Nerd Font";
          font-size: 14px;
          transition: 0.2s ease;
        }

        window#waybar {
          background-color: rgba(26, 27, 38, 0.8);
          border-radius: 12px;
          border: 2px solid rgba(122, 162, 247, 0.2);
          box-shadow: 0 2px 6px rgba(21, 22, 30, 0.5);
        }

        #custom-menu {
          font-size: 18px;
          color: #7aa2f7;
          padding: 0 12px;
          margin: 4px 8px 4px 4px;
          border-radius: 10px;
        }

        #custom-menu:hover {
          background-color: rgba(122, 162, 247, 0.13);
        }

        #custom-datetime {
          color: #c0caf5;
          font-weight: bold;
          font-size: 14.5px;
          min-width: 250px;
          text-shadow: 0 1px 2px rgba(21, 22, 30, 0.25);
        }

        #custom-notifications {
          font-size: 16px;
          color: #e0af68;
          margin-right: 6px;
          border-radius: 8px;
          padding: 0 10px;
        }

        #custom-notifications:hover {
          background-color: rgba(224, 175, 104, 0.13);
        }

        #custom-wlogout {
          font-size: 16px;
          color: #f7768e;
          margin: 0 2px 0 6px;
          border-radius: 8px;
          padding: 0 10px;
        }

        #custom-wlogout:hover {
          background-color: rgba(247, 118, 142, 0.13);
        }

        #network {
          color: #7dcfff;
          border-radius: 8px;
          padding: 0 12px;
        }

        #network:hover {
          background-color: rgba(125, 207, 255, 0.13);
        }

        #network.disconnected {
          color: #f7768e;
        }

        #pulseaudio {
          color: #9ece6a;
          border-radius: 8px;
          padding: 0 12px;
        }

        #pulseaudio:hover {
          background-color: rgba(158, 206, 106, 0.13);
        }

        #pulseaudio.muted {
          color: #f7768e;
        }

        #battery {
          color: #bb9af7;
          border-radius: 8px;
          padding: 0 12px;
        }

        #battery:hover {
          background-color: rgba(187, 154, 247, 0.13);
        }

        #battery.warning {
          color: #e0af68;
          animation: pulse 1.5s infinite;
        }

        #battery.critical {
          color: #f7768e;
          animation: pulse 0.8s infinite;
        }

        @keyframes pulse {
          0% { opacity: 1; }
          50% { opacity: 0.6; }
          100% { opacity: 1; }
        }

        #tray {
          margin-left: 4px;
          padding: 0 10px;
        }

        #tray > .passive {
          -gtk-icon-effect: dim;
        }

        #tray > .needs-attention {
          -gtk-icon-effect: highlight;
        }

        /* Button hover effects */
        #clock, #battery, #pulseaudio, #network, #tray, #custom-keymap, #bluetooth, #custom-datetime, #custom-wlogout, #custom-notifications {
          margin: 4px;
          padding: 0 10px;
        }

        #custom-menu, #pulseaudio, #network, #battery, #custom-notifications, #custom-wlogout {
          border-radius: 8px;
          transition: all 0.2s ease;
        }

        /* Modules separator (subtle dot) */
        #battery, #network, #pulseaudio, #custom-notifications {
          margin-left: 5px;
          margin-right: 5px;
        }
      '';
    };

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

        # Startup applications - avvio di SwayNC senza configurazione
        exec-once = [
          "waybar"
          "swaync" # Avvia SwayNC con la configurazione predefinita
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
          default-column-width {
              proportion 0.5
          }
          focus-ring {
              width 4
              active-color "#7fc8ff"
              inactive-color "#505050"
          }
          border {
              off
          }
          shadow {
              on
          }
      }
      spawn-at-startup "waybar"
      spawn-at-startup "swaync"
      screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"
      binds {
          Mod+Shift+S {
              show-hotkey-overlay
          }
          Mod+Return {
              spawn "alacritty"
          }
          Mod+A {
              spawn "fuzzel"
          }
          Super+L {
              spawn "swaylock"
          }
          Mod+N {
              spawn "swaync-client -t -sw"
          }
          XF86AudioRaiseVolume allow-when-locked=true {
              spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+"
          }
          XF86AudioLowerVolume allow-when-locked=true {
              spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-"
          }
          XF86AudioMute allow-when-locked=true {
              spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"
          }
          XF86AudioMicMute allow-when-locked=true {
              spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"
          }
          Mod+O repeat=false {
              toggle-overview
          }
          Mod+BackSpace {
              close-window
          }
          Mod+Left {
              focus-column-left
          }
          Mod+Down {
              focus-window-down
          }
          Mod+Up {
              focus-window-up
          }
          Mod+Right {
              focus-column-right
          }
          Mod+H {
              focus-column-left
          }
          Mod+J {
              focus-window-down
          }
          Mod+K {
              focus-window-up
          }
          Mod+L {
              focus-column-right
          }
          Mod+Ctrl+Left {
              move-column-left
          }
          Mod+Ctrl+Down {
              move-window-down
          }
          Mod+Ctrl+Up {
              move-window-up
          }
          Mod+Ctrl+Right {
              move-column-right
          }
          Mod+Ctrl+H {
              move-column-left
          }
          Mod+Ctrl+J {
              move-window-down
          }
          Mod+Ctrl+K {
              move-window-up
          }
          Mod+Ctrl+L {
              move-column-right
          }
          Mod+Home {
              focus-column-first
          }
          Mod+End {
              focus-column-last
          }
          Mod+Ctrl+Home {
              move-column-to-first
          }
          Mod+Ctrl+End {
              move-column-to-last
          }
          Mod+Shift+Left {
              focus-monitor-left
          }
          Mod+Shift+Down {
              focus-monitor-down
          }
          Mod+Shift+Up {
              focus-monitor-up
          }
          Mod+Shift+Right {
              focus-monitor-right
          }
          Mod+Shift+H {
              focus-monitor-left
          }
          Mod+Shift+J {
              focus-monitor-down
          }
          Mod+Shift+K {
              focus-monitor-up
          }
          Mod+Shift+L {
              focus-monitor-right
          }
          Mod+Shift+Ctrl+Left {
              move-column-to-monitor-left
          }
          Mod+Shift+Ctrl+Down {
              move-column-to-monitor-down
          }
          Mod+Shift+Ctrl+Up {
              move-column-to-monitor-up
          }
          Mod+Shift+Ctrl+Right {
              move-column-to-monitor-right
          }
          Mod+Shift+Ctrl+H {
              move-column-to-monitor-left
          }
          Mod+Shift+Ctrl+J {
              move-column-to-monitor-down
          }
          Mod+Shift+Ctrl+K {
              move-column-to-monitor-up
          }
          Mod+Shift+Ctrl+L {
              move-column-to-monitor-right
          }
          Mod+Page_Down {
              focus-workspace-down
          }
          Mod+Page_Up {
              focus-workspace-up
          }
          Mod+U {
              focus-workspace-down
          }
          Mod+I {
              focus-workspace-up
          }
          Mod+Ctrl+Page_Down {
              move-column-to-workspace-down
          }
          Mod+Ctrl+Page_Up {
              move-column-to-workspace-up
          }
          Mod+Ctrl+U {
              move-column-to-workspace-down
          }
          Mod+Ctrl+I {
              move-column-to-workspace-up
          }
          Mod+Shift+Page_Down {
              move-workspace-down
          }
          Mod+Shift+Page_Up {
              move-workspace-up
          }
          Mod+Shift+U {
              move-workspace-down
          }
          Mod+Shift+I {
              move-workspace-up
          }
          Mod+WheelScrollDown cooldown-ms=150 {
              focus-workspace-down
          }
          Mod+WheelScrollUp cooldown-ms=150 {
              focus-workspace-up
          }
          Mod+Ctrl+WheelScrollDown cooldown-ms=150 {
              move-column-to-workspace-down
          }
          Mod+Ctrl+WheelScrollUp cooldown-ms=150 {
              move-column-to-workspace-up
          }
          Mod+WheelScrollRight {
              focus-column-right
          }
          Mod+WheelScrollLeft {
              focus-column-left
          }
          Mod+Ctrl+WheelScrollRight {
              move-column-right
          }
          Mod+Ctrl+WheelScrollLeft {
              move-column-left
          }
          Mod+Shift+WheelScrollDown {
              focus-column-right
          }
          Mod+Shift+WheelScrollUp {
              focus-column-left
          }
          Mod+Ctrl+Shift+WheelScrollDown {
              move-column-right
          }
          Mod+Ctrl+Shift+WheelScrollUp {
              move-column-left
          }
          Mod+1 {
              focus-workspace 1
          }
          Mod+2 {
              focus-workspace 2
          }
          Mod+3 {
              focus-workspace 3
          }
          Mod+4 {
              focus-workspace 4
          }
          Mod+5 {
              focus-workspace 5
          }
          Mod+6 {
              focus-workspace 6
          }
          Mod+7 {
              focus-workspace 7
          }
          Mod+8 {
              focus-workspace 8
          }
          Mod+9 {
              focus-workspace 9
          }
          Mod+Ctrl+1 {
              move-column-to-workspace 1
          }
          Mod+Ctrl+2 {
              move-column-to-workspace 2
          }
          Mod+Ctrl+3 {
              move-column-to-workspace 3
          }
          Mod+Ctrl+4 {
              move-column-to-workspace 4
          }
          Mod+Ctrl+5 {
              move-column-to-workspace 5
          }
          Mod+Ctrl+6 {
              move-column-to-workspace 6
          }
          Mod+Ctrl+7 {
              move-column-to-workspace 7
          }
          Mod+Ctrl+8 {
              move-column-to-workspace 8
          }
          Mod+Ctrl+9 {
              move-column-to-workspace 9
          }
          Mod+BracketLeft {
              consume-or-expel-window-left
          }
          Mod+BracketRight {
              consume-or-expel-window-right
          }
          Mod+Comma {
              consume-window-into-column
          }
          Mod+Period {
              expel-window-from-column
          }
          Mod+R {
              switch-preset-column-width
          }
          Mod+Shift+R {
              switch-preset-window-height
          }
          Mod+Ctrl+R {
              reset-window-height
          }
          Mod+F {
              maximize-column
          }
          Mod+Shift+F {
              fullscreen-window
          }
          Mod+Ctrl+F {
              expand-column-to-available-width
          }
          Mod+C {
              center-column
          }
          Mod+Minus {
              set-column-width "-10%"
          }
          Mod+Equal {
              set-column-width "+10%"
          }
          Mod+Shift+Minus {
              set-window-height "-10%"
          }
          Mod+Shift+Equal {
              set-window-height "+10%"
          }
          Mod+V {
              toggle-window-floating
          }
          Mod+Shift+V {
              switch-focus-between-floating-and-tiling
          }
          Mod+W {
              toggle-column-tabbed-display
          }
          Print {
              screenshot
          }
          Ctrl+Print {
              screenshot-screen
          }
          Alt+Print {
              screenshot-window
          }
          Mod+Escape allow-inhibiting=false {
              toggle-keyboard-shortcuts-inhibit
          }
          Mod+Shift+E {
              quit
          }
          Ctrl+Alt+Delete {
              quit
          }
          Mod+Shift+P {
              power-off-monitors
          }
      }
    '';
  };
}
