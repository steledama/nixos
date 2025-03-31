# modules/home/hyprland.nix
# Modulo unificato per Hyprland che include base, bluetooth e multimonitor
{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  # Script per il menu delle scorciatoie
  shortcutMenuScript = pkgs.writeShellScriptBin "hyprland-shortcut-menu" ''
    #!/usr/bin/env bash

    # Extremely simplified approach to show Hyprland shortcuts
    # This simply shows the configuration itself, which is much more reliable

    # Function to extract shortcuts from Hyprland config
    extract_shortcuts() {
      # Store direct references to our configured bindings - these are exactly what we defined in the Nix file
      cat << EOF
    SUPER + Return => Launch Terminal
    SUPER + R => Open Application Launcher
    SUPER + B => Launch Firefox
    SUPER + E => Open File Manager
    SUPER + Q => Close Active Window
    SUPER + Space => Toggle Floating Window

    SUPER + Left => Focus Left
    SUPER + Right => Focus Right
    SUPER + Up => Focus Up
    SUPER + Down => Focus Down

    ALT + Tab => Switch to Next Window
    ALT + Shift + Tab => Switch to Previous Window

    SUPER + 1-9 => Switch to Workspace 1-9
    SUPER + CTRL + Left => Previous Workspace
    SUPER + CTRL + Right => Next Workspace

    SUPER + SHIFT + 1-9 => Move Window to Workspace 1-9
    SUPER + SHIFT + Left => Move Window to Previous Workspace
    SUPER + SHIFT + Right => Move Window to Next Workspace

    SUPER + M => Configure Monitors (Unified Workspace Mode)
    SUPER + W => Change Wallpaper on External Monitor
    SUPER + F1 => Show This Help Menu
    SUPER + SHIFT + E => Exit Hyprland
    EOF
    }

    # Show the shortcuts menu with transparency
    extract_shortcuts | ${pkgs.wofi}/bin/wofi \
      --dmenu \
      --prompt "Hyprland Shortcuts" \
      --width 800 \
      --height 600 \
      --cache-file /dev/null \
      --insensitive \
      --style="window {opacity: 0.9; border-radius: 10px;} #outer-box {margin: 10px;} #input {margin: 5px; border-radius: 5px;} #entry {border-radius: 5px;}"
  '';

  # Script per lo sfondo casuale
  randomWallpaperScript = pkgs.writeShellScriptBin "hyprland-random-wallpaper" ''
    #!/usr/bin/env bash

    # Simple wallpaper script for Hyprland
    # This script finds a random wallpaper from the user's wallpaper directory
    # and sets it as the wallpaper for different monitors

    # Simple, consistent wallpaper directory
    WALLPAPER_DIR="$HOME/wallpapers"
    TEMP_CONFIG="/tmp/hyprpaper.conf"

    # Create the wallpaper directory if it doesn't exist
    ${pkgs.coreutils}/bin/mkdir -p "$WALLPAPER_DIR"

    # Find a random wallpaper
    RANDOM_WALLPAPER=$(${pkgs.findutils}/bin/find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) 2>/dev/null | ${pkgs.coreutils}/bin/shuf -n 1)

    if [ -z "$RANDOM_WALLPAPER" ]; then
      echo "No wallpapers found in $WALLPAPER_DIR"
      # Create a default dark wallpaper if none found
      TEMP_WALLPAPER="/tmp/default-wallpaper.png"
      ${pkgs.imagemagick}/bin/convert -size 2560x1080 xc:#282c34 "$TEMP_WALLPAPER"
      RANDOM_WALLPAPER="$TEMP_WALLPAPER"
      echo "Created a default dark wallpaper"
    fi

    # Create a solid black background for the laptop monitor
    BLACK_WALLPAPER="/tmp/black-wallpaper.png"
    ${pkgs.imagemagick}/bin/convert -size 1920x1080 xc:#282c34 "$BLACK_WALLPAPER"

    # Terminate any existing hyprpaper instances
    if command -v ${pkgs.procps}/bin/pkill > /dev/null 2>&1; then
      ${pkgs.procps}/bin/pkill -f hyprpaper
    else
      # Alternative process termination if pkill is not available
      for pid in $(${pkgs.procps}/bin/ps -ef | ${pkgs.gnugrep}/bin/grep hyprpaper | ${pkgs.gnugrep}/bin/grep -v grep | ${pkgs.gawk}/bin/awk '{print $2}'); do
        kill -9 $pid 2>/dev/null
      done
    fi

    # Wait for the process to terminate
    sleep 1

    # Generate a hyprpaper configuration
    echo "preload = $RANDOM_WALLPAPER" > "$TEMP_CONFIG"
    echo "preload = $BLACK_WALLPAPER" >> "$TEMP_CONFIG"

    # Apply wallpapers based on monitor name
    for monitor in $(${pkgs.hyprland}/bin/hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '.[].name'); do
      if [ "$monitor" = "eDP-1" ]; then
        # Laptop display gets dark background
        echo "wallpaper = $monitor,$BLACK_WALLPAPER" >> "$TEMP_CONFIG"
      elif [ "$monitor" = "DP-1" ] || [ "$monitor" = "HDMI-A-1" ]; then
        # External display gets the random wallpaper
        echo "wallpaper = $monitor,$RANDOM_WALLPAPER" >> "$TEMP_CONFIG"
      else
        # Default for any other monitor
        echo "wallpaper = $monitor,$RANDOM_WALLPAPER" >> "$TEMP_CONFIG"
      fi
    done

    # Start hyprpaper with the new configuration
    ${pkgs.hyprpaper}/bin/hyprpaper --config "$TEMP_CONFIG" &

    echo "Set wallpapers: Main monitor: $RANDOM_WALLPAPER, Laptop: Dark theme"
  '';

  # Script per configurare i monitor
  monitorConfigScript = pkgs.writeShellScriptBin "hyprland-monitor-config" ''
    #!/usr/bin/env bash

    # Monitor configuration script for Hyprland
    # Simplified to handle only a few specific configurations

    # Get current monitor information
    MONITORS=$(${pkgs.hyprland}/bin/hyprctl monitors -j)
    NUM_MONITORS=$(echo "$MONITORS" | ${pkgs.jq}/bin/jq '. | length')

    # Detect if we're at home (HDMI) or at work (DisplayPort)
    if ${pkgs.coreutils}/bin/cat /sys/class/drm/*/status | ${pkgs.gnugrep}/bin/grep -q "^DP-[0-9] connected"; then
      CONNECTION="DisplayPort"
      EXTERNAL_MONITOR="DP-1"
    elif ${pkgs.coreutils}/bin/cat /sys/class/drm/*/status | ${pkgs.gnugrep}/bin/grep -q "^HDMI-[0-9] connected"; then
      CONNECTION="HDMI"
      EXTERNAL_MONITOR="HDMI-A-1"
    else
      CONNECTION="Unknown"
      EXTERNAL_MONITOR=""
    fi

    # Function to apply monitor configs
    apply_monitor_config() {
      PROFILE="$1"
      case "$PROFILE" in
        "laptop-only")
          # Solo laptop - monitor interno
          ${pkgs.hyprland}/bin/hyprctl keyword monitor "eDP-1,1920x1080,0x0,1"
          ${pkgs.hyprland}/bin/hyprctl keyword monitor ",disable"
          ;;
        "external-only")
          # Solo monitor esterno
          ${pkgs.hyprland}/bin/hyprctl keyword monitor "eDP-1,disable"
          ${pkgs.hyprland}/bin/hyprctl keyword monitor "$EXTERNAL_MONITOR,2560x1080,0x0,1"
          ;;
        "dual-stack")
          # Monitor esterno in alto, laptop in basso (centrato)
          # Configura il monitor esterno (2560x1080) in alto
          ${pkgs.hyprland}/bin/hyprctl keyword monitor "$EXTERNAL_MONITOR,2560x1080,0x0,1"
          
          # Calcola l'offset per centrare il monitor del laptop (1920x1080) sotto il monitor esterno
          # (2560 - 1920) / 2 = 320 pixel di offset sul lato X
          ${pkgs.hyprland}/bin/hyprctl keyword monitor "eDP-1,1920x1080,320x1080,1"
          ;;
        "dual-mirror")
          # Modalità mirror (stesso contenuto su entrambi)
          ${pkgs.hyprland}/bin/hyprctl keyword monitor "eDP-1,1920x1080,0x0,1"
          ${pkgs.hyprland}/bin/hyprctl keyword monitor "$EXTERNAL_MONITOR,preferred,0x0,1,mirror,eDP-1"
          ;;
        *)
          echo "Profilo non valido: $PROFILE"
          return 1
          ;;
      esac

      # Dopo aver cambiato configurazione, aggiorna lo sfondo
      ${randomWallpaperScript}/bin/hyprland-random-wallpaper

      # Notifica l'utente del cambio di profilo
      ${pkgs.libnotify}/bin/notify-send "Monitor" "Profilo $PROFILE applicato ($CONNECTION)"
    }

    # Show profile selector with current status
    select_profile() {
      OPTIONS="laptop-only\nexternal-only\ndual-stack\ndual-mirror"
      SELECTION=$(echo -e "$OPTIONS" | ${pkgs.wofi}/bin/wofi --dmenu --prompt "Monitor ($NUM_MONITORS rilevati, $CONNECTION)" --width 300 --height 200 --cache-file /dev/null)

      if [ -n "$SELECTION" ]; then
        apply_monitor_config "$SELECTION"
      fi
    }

    # Main execution
    select_profile
  '';

  # Script per wlogout
  wlogoutScript = pkgs.writeShellScriptBin "hyprland-logout" ''
    #!/usr/bin/env bash
    
    # Basic wlogout script with clean configuration
    ${pkgs.wlogout}/bin/wlogout \
      --protocol layer-shell \
      --buttons-per-row 3 \
      --column-spacing 20 \
      --row-spacing 20 \
      --margin-top 300 \
      --margin-bottom 300 \
      --margin-left 300 \
      --margin-right 300
  '';
in {
  # Pacchetti necessari per tutti i componenti di Hyprland
  home.packages = with pkgs; [
    # Script creati appositamente
    shortcutMenuScript
    randomWallpaperScript
    monitorConfigScript
    wlogoutScript
    
    # Pacchetti per il multimonitor
    jq
    brightnessctl
    libnotify
    
    # Pacchetti per il bluetooth
    blueman
    bluez-tools
    
    # Wlogout
    wlogout
    
    # Hyprpaper per gestione sfondi
    hyprpaper
  ];

  # Configurazione Hyprland
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    # Disabilitiamo la sessione di waybar che viene avviata da systemd per evitare barre doppie
    systemd.variables = ["--systemd-activation"];
    settings = {
      # Impostazioni generali comuni
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee)";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
      };

      # Configurazione input con tastiera italiana
      input = {
        kb_layout = "it";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = true;
          disable_while_typing = true;
          tap-to-click = true;
        };
      };

      # Rilevamento automatico dei monitor all'avvio
      monitor = [
        "eDP-1,1920x1080,0x0,1" # Monitor laptop integrato
        ",preferred,auto,1" # Configurazione automatica per monitor esterni
      ];

      # Animazioni
      animations = {
        enabled = true;
        animation = [
          "windows, 1, 3, default"
          "border, 1, 3, default"
          "fade, 1, 3, default"
          "workspaces, 1, 3, default"
        ];
      };

      # Decorazioni finestre
      decoration = {
        rounding = 10;
      };

      # Disposizione finestre
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      # Regole finestre
      windowrulev2 = [
        "float,class:^(pavucontrol)$"
        "float,title:^(Hyprland Shortcuts)$"
        "size 800 600,title:^(Hyprland Shortcuts)$"
        "center,title:^(Hyprland Shortcuts)$"
        "float,class:^(nm-connection-editor)$"
        "float,class:^(org.gnome.Calculator)$"
        "float,class:^(blueman-manager)$"
        "center,class:^(blueman-manager)$"
        "fullscreen,class:^(wlogout)$"
      ];

      # Variabili d'ambiente base
      env = [
        "XCURSOR_SIZE,24"
        "XCURSOR_THEME,Adwaita"
        "GDK_BACKEND,wayland,x11"
        "QT_QPA_PLATFORM,wayland;xcb"
      ];

      xwayland = {
        force_zero_scaling = true;
      };

      # Configurazioni varie
      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        mouse_move_enables_dpms = true; # Riattiva lo schermo con movimento del mouse
        key_press_enables_dpms = true; # Riattiva lo schermo con pressione tasti
        enable_swallow = true; # Consente di sostituire finestre con i loro processi figli (utile per terminali)
        swallow_regex = "^(wezterm)$"; # Applica swallow solo a wezterm
      };

      # Esegui all'avvio
      exec-once = [
        # Imposta lo sfondo
        "${randomWallpaperScript}/bin/hyprland-random-wallpaper"
        # Avvia waybar
        "${pkgs.waybar}/bin/waybar"
        # Avvia applet bluetooth
        "blueman-applet"
      ];

      # Scorciatoie
      bind = [
        # Applicazioni di base
        "SUPER, Return, exec, wezterm"
        "SUPER, R, exec, wofi --show drun"
        "SUPER, B, exec, firefox"
        "SUPER, E, exec, wezterm start -- yazi"

        # Controlli finestre
        "SUPER, Q, killactive,"
        "SUPER, Space, togglefloating,"

        # Navigazione focus
        "SUPER, Left, movefocus, l"
        "SUPER, Right, movefocus, r"
        "SUPER, Up, movefocus, u"
        "SUPER, Down, movefocus, d"

        # Navigazione finestre
        "ALT, Tab, cyclenext,"
        "ALT_SHIFT, Tab, cyclenext, prev"

        # Navigazione workspace (numeri 1-9)
        "SUPER, 1, workspace, 1"
        "SUPER, 2, workspace, 2"
        "SUPER, 3, workspace, 3"
        "SUPER, 4, workspace, 4"
        "SUPER, 5, workspace, 5"
        "SUPER, 6, workspace, 6"
        "SUPER, 7, workspace, 7"
        "SUPER, 8, workspace, 8"
        "SUPER, 9, workspace, 9"
        # Navigazione workspace aggiuntiva
        "SUPER CTRL, Right, workspace, e+1"
        "SUPER CTRL, Left, workspace, e-1"

        # Spostamento finestre tra workspace
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

        # Scorciatoia per configurazione monitor (cambiata da SUPER+P a SUPER+M)
        "SUPER, M, exec, ${monitorConfigScript}/bin/hyprland-monitor-config"

        # Scorciatoia per sfondo casuale
        "SUPER, W, exec, ${randomWallpaperScript}/bin/hyprland-random-wallpaper"

        # Mostra scorciatoie tastiera
        "SUPER, F1, exec, ${shortcutMenuScript}/bin/hyprland-shortcut-menu"

        # Wlogout
        "SUPER, Escape, exec, ${wlogoutScript}/bin/hyprland-logout"
      ];
    };
  };

  # Configurazione Wlogout
  xdg.configFile."wlogout/layout".text = ''
    {
        "label" : "lock",
        "action" : "swaylock",
        "text" : "Lock",
        "keybind" : "l"
    }
    {
        "label" : "hibernate",
        "action" : "systemctl hibernate",
        "text" : "Hibernate",
        "keybind" : "h"
    }
    {
        "label" : "logout",
        "action" : "hyprctl dispatch exit",
        "text" : "Logout",
        "keybind" : "e"
    }
    {
        "label" : "shutdown",
        "action" : "systemctl poweroff",
        "text" : "Shutdown",
        "keybind" : "s"
    }
    {
        "label" : "suspend",
        "action" : "systemctl suspend",
        "text" : "Suspend",
        "keybind" : "u"
    }
    {
        "label" : "reboot",
        "action" : "systemctl reboot",
        "text" : "Reboot",
        "keybind" : "r"
    }
  '';

  # Stile personalizzato per wlogout
  xdg.configFile."wlogout/style.css".text = ''
    * {
      background-image: none;
      font-family: "JetBrainsMono Nerd Font";
    }

    window {
      background-color: rgba(40, 44, 52, 0.8);
    }

    button {
      color: #abb2bf;
      background-color: rgba(61, 66, 77, 0.8);
      border-style: solid;
      border-width: 1px;
      border-color: #61afef;
      border-radius: 10px;
      background-repeat: no-repeat;
      background-position: center;
      background-size: 35%;
      margin: 5px;
    }

    button:focus, button:active, button:hover {
      background-color: rgba(97, 175, 239, 0.25);
      outline-style: none;
    }

    #lock {
      background-image: image(url("/usr/share/wlogout/icons/lock.png"), url("/usr/local/share/wlogout/icons/lock.png"));
    }
    #logout {
      background-image: image(url("/usr/share/wlogout/icons/logout.png"), url("/usr/local/share/wlogout/icons/logout.png"));
    }
    #suspend {
      background-image: image(url("/usr/share/wlogout/icons/suspend.png"), url("/usr/local/share/wlogout/icons/suspend.png"));
    }
    #hibernate {
      background-image: image(url("/usr/share/wlogout/icons/hibernate.png"), url("/usr/local/share/wlogout/icons/hibernate.png"));
    }
    #shutdown {
      background-image: image(url("/usr/share/wlogout/icons/shutdown.png"), url("/usr/local/share/wlogout/icons/shutdown.png"));
    }
    #reboot {
      background-image: image(url("/usr/share/wlogout/icons/reboot.png"), url("/usr/local/share/wlogout/icons/reboot.png"));
    }
  '';

  # Configurazione Waybar
  programs.waybar = {
    enable = true;
    systemd.enable = false; # Disattivata per evitare la doppia barra
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        # Rimuovere l'output specifico per consentire a waybar di apparire ovunque
        modules-left = ["hyprland/workspaces"];
        modules-center = ["custom/datetime"];
        modules-right = ["custom/keymap" "bluetooth" "pulseaudio" "network" "battery" "custom/wlogout" "tray"];

        "hyprland/workspaces" = {
          format = "{icon}";
          on-click = "activate";
          sort-by-number = true;
          # Rimosso persistent-workspaces per avere configurazione dinamica
          format-icons = {
            "1" = "1";
            "2" = "2";
            "3" = "3";
            "4" = "4";
            "5" = "5";
            "6" = "6";
            "7" = "7";
            "8" = "8";
            "9" = "9";
            "urgent" = "•";
            "active" = "•";
            "default" = "•";
          };
          all-outputs = true;
          active-only = false;
        };

        # Modulo data e ora unificato
        "custom/datetime" = {
          exec = "LC_ALL=it_IT.UTF-8 date +'%A %d %B %H:%M'";
          interval = 30;
          format = "{}";
          tooltip = false;
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

        # Configurazione del modulo bluetooth
        "bluetooth" = {
          format = " {status}";
          format-connected = " {device_alias}";
          format-connected-battery = " {device_alias} {device_battery_percentage}%";
          tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
          tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
          on-click = "blueman-manager";
        };

        # Modulo personalizzato per le scorciatoie da tastiera
        "custom/keymap" = {
          format = "⌨";
          tooltip = "Scorciatoie Hyprland";
          on-click = "${shortcutMenuScript}/bin/hyprland-shortcut-menu";
        };

        # Modulo personalizzato per wlogout
        "custom/wlogout" = {
          format = "⏻";
          tooltip = "Logout menu";
          on-click = "${wlogoutScript}/bin/hyprland-logout";
        };
      };
    };

    # Stile CSS per Waybar
    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 14px;
      }

      window#waybar {
        background-color: rgba(40, 44, 52, 0.9);
        color: #abb2bf;
      }

      #workspaces button {
        padding: 0 5px;
        color: #abb2bf;
        background-color: transparent;
        border-bottom: 3px solid transparent;
      }

      #workspaces button.active {
        background-color: rgba(97, 175, 239, 0.2);
        border-bottom: 3px solid #61afef;
        font-weight: bold;
      }
      
      /* Stile per i numeri dei workspace */
      #workspaces button {
        font-size: 14px;
        padding: 0 8px;
        margin: 0 2px;
        transition: all 0.3s ease;
      }

      #clock, #battery, #pulseaudio, #network, #tray, #custom-keymap, #bluetooth, #custom-date, #custom-wlogout {
        padding: 0 10px;
        margin: 0 4px;
      }

      /* Stile per la data e ora unificata */
      #custom-datetime {
        font-weight: bold;
        color: #e5c07b;
        min-width: 250px; /* Larghezza minima per evitare spostamenti */
      }

      /* Stile per il pulsante della tastiera */
      #custom-keymap {
        color: #61afef;
        font-size: 16px;
      }

      /* Stile per il pulsante di logout */
      #custom-wlogout {
        color: #e06c75;
        font-size: 16px;
      }

      /* Stile per la rete */
      #network {
        color: #98c379;
      }

      /* Stile per l'audio */
      #pulseaudio {
        color: #c678dd;
      }

      /* Stile per la batteria */
      #battery {
        color: #e5c07b;
      }

      #battery.warning {
        color: #e5c07b;
        animation: blink 1s infinite;
      }

      #battery.critical {
        color: #e06c75;
        animation: blink 0.5s infinite;
      }

      /* Stile per il modulo bluetooth */
      #bluetooth {
        color: #61afef;
      }
      #bluetooth.connected {
        color: #98c379;
      }
      #bluetooth.disconnected {
        color: #e06c75;
      }

      @keyframes blink {
        to {
          opacity: 0.5;
        }
      }

      /* Effetto hover per un feedback migliore */
      #custom-keymap:hover,
      #pulseaudio:hover,
      #network:hover,
      #bluetooth:hover,
      #custom-wlogout:hover {
        background-color: rgba(97, 175, 239, 0.2);
        border-radius: 5px;
      }
    '';
  };
}
