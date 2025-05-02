# modules/home/niri.nix
# Niri-specific configuration
{
  config,
  lib,
  ...
}: let
  cfg = config.wm;
in {
  # Make sure the base is enabled
  config = {
    # Niri configuration
    xdg.configFile."niri/config.kdl".text = ''
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
      spawn-at-startup "swaybg" "-m" "${cfg.wallpaper.mode}" "-i" "${cfg.wallpaper.path}"
      screenshot-path "${cfg.screenshots.path}"
      binds {
          Mod+Shift+S {
              show-hotkey-overlay
          }
          Mod+M {
              spawn "alacritty"
          }
          Mod+A {
              spawn "fuzzel"
          }
          Mod+L {
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

          Alt+Tab {
              focus-column-right
          }
          Alt+Shift+Tab {
              focus-column-left
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

          Mod+Page_Down {
              focus-workspace-down
          }
          Mod+Page_Up {
              focus-workspace-up
          }

          Mod+Ctrl+Page_Down {
              move-column-to-workspace-down
          }
          Mod+Ctrl+Page_Up {
              move-column-to-workspace-up
          }

          Mod+Shift+Page_Down {
              move-workspace-down
          }
          Mod+Shift+Page_Up {
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
          Mod+Alt+E {
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
