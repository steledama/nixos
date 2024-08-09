{ config, pkgs, lib, ... }:

{
  programs.waybar = {
    enable = true;
    settings = [{
      layer = "top";
      position = "top";
      height = 30;
      spacing = 4;
      modules-left = [ "wlr/workspaces" ];
      modules-center = [ "clock" ];
      modules-right = [ "network" "pulseaudio" "custom/power" ];
      "wlr/workspaces" = {
        format = "{icon}";
        on-click = "activate";
        format-icons = {
          "1" = "1";
          "2" = "2";
          "3" = "3";
          "4" = "4";
          "5" = "5";
          urgent = "";
          active = "";
          default = "";
        };
      };
      clock = {
        format = "{:%a %b %d %H:%M}";
        tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
      };
      network = {
        format-wifi = "󰖩 {essid}";
        format-ethernet = "󰈀 {ipaddr}/{cidr}";
        format-linked = "󰈀 {ifname} (No IP)";
        format-disconnected = "󰖪 Disconnected";
        format-alt = "{ifname}: {ipaddr}/{cidr}";
      };
      pulseaudio = {
        format = "{icon} {volume}%";
        format-bluetooth = "{volume}% {icon}";
        format-bluetooth-muted = " {icon}";
        format-muted = "󰝟";
        format-icons = {
          headphone = "";
          "hands-free" = "";
          headset = "";
          phone = "";
          portable = "";
          car = "";
          default = [ "" "" "" ];
        };
        on-click = "pavucontrol";
      };
      "custom/power" = {
        format = "󰐥";
        on-click = "wlogout";
        tooltip = false;
      };
    }];
    style = ''
      * {
        border: none;
        border-radius: 0;
        font-family: "JetBrainsMono Nerd Font", "DejaVu Sans", sans-serif;
        font-size: 13px;
        min-height: 0;
      }

      window#waybar {
        background: rgba(0, 0, 0, 0.8);
        color: #ffffff;
      }

      #workspaces button {
        padding: 0 5px;
        background: transparent;
        color: #ffffff;
      }

      #workspaces button.active {
        background: #64727D;
        border-bottom: 2px solid #ffffff;
      }

      #clock,
      #network,
      #pulseaudio,
      #custom-power {
        padding: 0 10px;
        margin: 0 5px;
      }

      #custom-power {
        color: #ff5555;
      }
    '';
  };
}
