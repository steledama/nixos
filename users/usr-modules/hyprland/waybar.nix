{ config, pkgs, lib, ... }:

{
  programs.waybar = {
    enable = true;
  };

  home.file.".config/waybar/config" = {
    force = true;
    text = ''
      {
          "layer": "top",
          "position": "top",
          "height": 24,
          "modules-left": ["hyprland/workspaces"],
          "modules-center": ["hyprland/window", "clock"],
          "modules-right": ["backlight", "pulseaudio", "network", "cpu", "memory", "battery", "tray", "custom/power"],
          "hyprland/workspaces": {
              "disable-scroll": true,
              "all-outputs": false,
              "format": "{icon}",
              "format-icons": {
                  "active": "•",
                  "default": "◦"
              }
          },
          "hyprland/window": {
              "max-length": 50
          },
          "clock": {
              "format": "{:%H:%M}",
              "tooltip-format": "{:%Y-%m-%d}"
          },
          "cpu": {
              "format": "{usage}% "
          },
          "memory": {
              "format": "{}% "
          },
          "battery": {
              "states": {
                  "warning": 30,
                  "critical": 15
              },
              "format": "{capacity}% {icon}",
              "format-icons": ["", "", "", "", ""]
          },
          "network": {
              "format-wifi": "{essid} ({signalStrength}%) ",
              "format-ethernet": "{ifname}: {ipaddr}/{cidr} ",
              "format-disconnected": "Disconnected ⚠"
          },
          "pulseaudio": {
              "format": "{volume}% {icon}",
              "format-bluetooth": "{volume}% {icon}",
              "format-muted": "",
              "format-icons": {
                  "headphones": "",
                  "handsfree": "",
                  "headset": "",
                  "phone": "",
                  "portable": "",
                  "car": "",
                  "default": ["", ""]
              },
              "on-click": "pavucontrol"
          },
          "backlight": {
              "device": "intel_backlight",
              "format": "{percent}% {icon}",
              "format-icons": ["", ""]
          },
          "custom/power": {
              "format": "󰐥",
              "on-click": "wlogout",
              "tooltip": false
          }
      }
    '';
  };

  home.file.".config/waybar/style.css" = {
    force = true;
    text = ''
      * {
          border: none;
          border-radius: 0;
          font-family: "Ubuntu Nerd Font";
          font-size: 13px;
          min-height: 0;
      }

      window#waybar {
          background: rgba(43, 48, 59, 0.5);
          border-bottom: 3px solid rgba(100, 114, 125, 0.5);
          color: #ffffff;
      }

      #workspaces button {
          padding: 0 5px;
          background: transparent;
          color: #ffffff;
          border-bottom: 3px solid transparent;
      }

      #workspaces button.active {
          background: #64727D;
          border-bottom: 3px solid #ffffff;
      }

      #clock,
      #battery,
      #cpu,
      #memory,
      #network,
      #pulseaudio,
      #tray,
      #backlight,
      #custom-power {
          padding: 0 10px;
          margin: 0 5px;
      }

      #custom-power {
          color: #ff5555;
      }

      #window {
          font-weight: bold;
      }

      #battery.warning:not(.charging) {
          color: #ffffff;
          background: #f53c3c;
      }
    '';
  };
}
