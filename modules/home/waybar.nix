# modules/home/waybar.nixe
{
  pkgs,
  scripts,
  colors,
}: {
  enable = true;
  systemd.enable = false;
  settings = {
    mainBar = {
      layer = "top";
      position = "top";
      height = 30;
      modules-left = ["custom/menu" "custom/workspaces"];
      modules-center = ["custom/datetime"];
      modules-right = ["custom/notifications" "custom/keymap" "pulseaudio" "network" "battery" "custom/wlogout" "tray"];

      "custom/workspaces" = {
        format = "{icon}";
        exec = "${pkgs.coreutils}/bin/seq 1 9 | ${pkgs.jq}/bin/jq -R -s 'split(\"\\n\") | map(select(. != \"\")) | map({\"text\": ., \"tooltip\": (\"Workspace \" + .), \"class\": \"workspace-\" + .})'";
        return-type = "json";
        interval = 1;
        on-click = "sleep 0.1 && ${pkgs.coreutils}/bin/echo 'workspace-clicked' > /tmp/waybar-workspace-click";
        on-scroll-up = "${pkgs.coreutils}/bin/echo 'workspace-next' > /tmp/waybar-workspace-scroll";
        on-scroll-down = "${pkgs.coreutils}/bin/echo 'workspace-prev' > /tmp/waybar-workspace-scroll";
      };

      "custom/menu" = {
        format = "󰀻";
        tooltip = "Menu Applicazioni";
        on-click = "fuzzel";
      };

      "custom/datetime" = {
        exec = "LC_ALL=it_IT.UTF-8 date +'%A %d %B %H:%M'";
        interval = 30;
        format = "{}";
        tooltip = false;
      };

      "custom/notifications" = {
        format = "󰂚";
        tooltip = "Centro Notifiche";
        on-click = "swaync-client -t -sw";
        on-click-right = "swaync-client -C";
      };

      "tray" = {
        spacing = 10;
      };

      "network" = {
        format-wifi = "  {essid}";
        format-disconnected = "󰤭 ";
        tooltip-format = "{ifname}: {ipaddr}/{cidr}";
      };

      "pulseaudio" = {
        format = "{icon} {volume}%";
        format-muted = "󰖁 ";
        format-icons = {
          default = ["󰕿" "󰖀" "󰕾"];
        };
        on-click = "pavucontrol";
      };

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

      "custom/wlogout" = {
        format = "⏻";
        tooltip = false;
        on-click = "wlogout";
      };
    };
  };

  style = ''
    * {
      font-family: "JetBrainsMono Nerd Font";
      font-size: 14px;
    }

    window#waybar {
      background-color: rgba(40, 44, 52, 0.9);
      color: ${colors.foreground};
    }

    #custom-workspaces button {
      padding: 0 5px;
      color: ${colors.foreground};
      background-color: transparent;
      border-bottom: 3px solid transparent;
    }

    #custom-workspaces button.active {
      background-color: rgba(97, 175, 239, 0.2);
      border-bottom: 3px solid ${colors.blue};
      font-weight: bold;
    }

    #custom-workspaces button {
      font-size: 14px;
      padding: 0 8px;
      margin: 0 2px;
      transition: all 0.3s ease;
    }

    #custom-menu {
      color: ${colors.blue};
      font-size: 18px;
      padding: 0 10px;
      margin: 0 8px 0 4px;
      background-color: rgba(97, 175, 239, 0.1);
      border-radius: 5px;
    }

    #custom-menu:hover {
      background-color: rgba(97, 175, 239, 0.3);
      border-radius: 5px;
    }

    #clock, #battery, #pulseaudio, #network, #tray, #custom-keymap, #bluetooth, #custom-date, #custom-wlogout, #custom-notifications {
      padding: 0 10px;
      margin: 0 4px;
    }

    #custom-notifications {
      color: ${colors.green};
      font-size: 16px;
    }

    #custom-datetime {
      font-weight: bold;
      color: ${colors.yellow};
      min-width: 250px; /* Larghezza minima per evitare spostamenti */
    }

    #custom-wlogout {
      color: ${colors.red};
      font-size: 16px;
    }

    #network {
      color: ${colors.green};
    }

    #pulseaudio {
      color: ${colors.purple};
    }

    #battery {
      color: ${colors.yellow};
    }

    #battery.warning {
      color: ${colors.yellow};
      animation: blink 1s infinite;
    }

    #battery.critical {
      color: ${colors.red};
      animation: blink 0.5s infinite;
    }

    @keyframes blink {
      to {
        opacity: 0.5;
      }
    }

    #custom-notifications:hover,
    #pulseaudio:hover,
    #network:hover,
    #bluetooth:hover,
    #custom-wlogout:hover {
      background-color: rgba(97, 175, 239, 0.2);
      border-radius: 5px;
    }
  '';
}
