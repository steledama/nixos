{ config, pkgs, ... }:

{
  programs.waybar = {
    enable = true;
    settings = [{
      layer = "top";
      position = "top";
      modules-left = [
        "custom/startmenu"
        "hyprland/window"
        "pulseaudio"
        "cpu"
        "memory"
        "idle_inhibitor"
      ];
      modules-center = [ "hyprland/workspaces" ];
      modules-right = [
        "custom/hyprbindings"
        "custom/notification"
        "custom/exit"
        "battery"
        "tray"
        "clock"
      ];

      "hyprland/workspaces" = {
        format = "{name}";
        on-scroll-up = "hyprctl dispatch workspace e+1";
        on-scroll-down = "hyprctl dispatch workspace e-1";
      };
      "clock" = {
        format = '' {:L%H:%M}'';
        tooltip = true;
        tooltip-format = "<big>{:%A, %d.%B %Y }</big>\n<tt><small>{calendar}</small></tt>";
      };
      "hyprland/window" = {
        max-length = 22;
        separate-outputs = false;
        rewrite = {
          "" = " 🙈 No Windows? ";
        };
      };
      "memory" = {
        interval = 5;
        format = " {}%";
        tooltip = true;
      };
      "cpu" = {
        interval = 5;
        format = " {usage:2}%";
        tooltip = true;
      };
      "disk" = {
        format = " {free}";
        tooltip = true;
      };
      "tray" = {
        spacing = 12;
      };
      "pulseaudio" = {
        format = "{icon} {volume}% {format_source}";
        format-bluetooth = "{volume}% {icon} {format_source}";
        format-bluetooth-muted = " {icon} {format_source}";
        format-muted = " {format_source}";
        format-source = " {volume}%";
        format-source-muted = "";
        format-icons = {
          headphone = "";
          hands-free = "";
          headset = "";
          phone = "";
          portable = "";
          car = "";
          default = [ "" "" "" ];
        };
        on-click = "pavucontrol";
      };
      "custom/exit" = {
        tooltip = false;
        format = "";
        on-click = "wlogout";
      };
      "custom/startmenu" = {
        tooltip = false;
        format = "";
        on-click = "wofi --show drun";
      };
      "custom/hyprbindings" = {
        tooltip = false;
        format = "󱕴";
        on-click = "show-hypr-bindings";
      };
      "idle_inhibitor" = {
        format = "{icon}";
        format-icons = {
          activated = "";
          deactivated = "";
        };
        tooltip = "true";
      };
      "custom/notification" = {
        tooltip = false;
        format = "{icon} {}";
        format-icons = {
          notification = "<span foreground='red'><sup></sup></span>";
          none = "";
          dnd-notification = "<span foreground='red'><sup></sup></span>";
          dnd-none = "";
          inhibited-notification = "<span foreground='red'><sup></sup></span>";
          inhibited-none = "";
          dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
          dnd-inhibited-none = "";
        };
        return-type = "json";
        exec-if = "which swaync-client";
        exec = "swaync-client -swb";
        on-click = "swaync-client -t -sw";
        escape = true;
      };
      "battery" = {
        states = {
          warning = 30;
          critical = 15;
        };
        format = "{icon} {capacity}%";
        format-charging = "󰂄 {capacity}%";
        format-plugged = "󱘖 {capacity}%";
        format-icons = [
          "󰁺"
          "󰁻"
          "󰁼"
          "󰁽"
          "󰁾"
          "󰁿"
          "󰂀"
          "󰂁"
          "󰂂"
          "󰁹"
        ];
        on-click = "";
        tooltip = false;
      };
    }];
    style = ''
      * {
        font-family: JetBrainsMono Nerd Font Mono;
        font-size: 16px;
        border-radius: 0px;
        border: none;
        min-height: 0px;
      }
      window#waybar {
        background: rgba(0,0,0,0);
      }
      #workspaces {
        color: #1E1E2E;
        background: #CBA6F7;
        margin: 4px 4px;
        padding: 5px 5px;
        border-radius: 16px;
      }
      #workspaces button {
        font-weight: bold;
        padding: 0px 5px;
        margin: 0px 3px;
        border-radius: 16px;
        color: #1E1E2E;
        background: linear-gradient(45deg, #89B4FA, #CBA6F7);
        opacity: 0.5;
        transition: all 0.3s cubic-bezier(.55,-0.68,.48,1.682);
      }
      #workspaces button.active {
        font-weight: bold;
        padding: 0px 5px;
        margin: 0px 3px;
        border-radius: 16px;
        color: #1E1E2E;
        background: linear-gradient(45deg, #89B4FA, #CBA6F7);
        transition: all 0.3s cubic-bezier(.55,-0.68,.48,1.682);
        opacity: 1.0;
        min-width: 40px;
      }
      #workspaces button:hover {
        font-weight: bold;
        border-radius: 16px;
        color: #1E1E2E;
        background: linear-gradient(45deg, #89B4FA, #CBA6F7);
        opacity: 0.8;
        transition: all 0.3s cubic-bezier(.55,-0.68,.48,1.682);
      }
      tooltip {
        background: #1E1E2E;
        border: 1px solid #CBA6F7;
        border-radius: 12px;
      }
      tooltip label {
        color: #CBA6F7;
      }
      #window, #pulseaudio, #cpu, #memory, #idle_inhibitor {
        font-weight: bold;
        margin: 4px 0px;
        margin-left: 7px;
        padding: 0px 18px;
        background: #CDD6F4;
        color: #1E1E2E;
        border-radius: 24px 10px 24px 10px;
      }
      #custom-startmenu {
        color: #A6E3A1;
        background: #313244;
        font-size: 28px;
        margin: 0px;
        padding: 0px 30px 0px 15px;
        border-radius: 0px 0px 40px 0px;
      }
      #custom-hyprbindings, #network, #battery,
      #custom-notification, #tray, #custom-exit {
        font-weight: bold;
        background: #F5C2E7;
        color: #1E1E2E;
        margin: 4px 0px;
        margin-right: 7px;
        border-radius: 10px 24px 10px 24px;
        padding: 0px 18px;
      }
      #clock {
        font-weight: bold;
        color: #1E1E2E;
        background: linear-gradient(90deg, #89DCEB, #94E2D5);
        margin: 0px;
        padding: 0px 15px 0px 30px;
        border-radius: 0px 0px 0px 40px;
      }
    '';
  };
}
