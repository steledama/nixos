# modules/home/hyprland.nix
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

    SUPER + 1 => Switch to Workspace 1
    SUPER + 2 => Switch to Workspace 2
    SUPER + 3 => Switch to Workspace 3
    SUPER + 4 => Switch to Workspace 4
    SUPER + 5 => Switch to Workspace 5

    SUPER + CTRL + Left => Previous Workspace
    SUPER + CTRL + Right => Next Workspace

    SUPER + SHIFT + 1 => Move Window to Workspace 1
    SUPER + SHIFT + 2 => Move Window to Workspace 2
    SUPER + SHIFT + 3 => Move Window to Workspace 3
    SUPER + SHIFT + 4 => Move Window to Workspace 4
    SUPER + SHIFT + 5 => Move Window to Workspace 5
    SUPER + SHIFT + Left => Move Window to Previous Workspace
    SUPER + SHIFT + Right => Move Window to Next Workspace


    SUPER + W => Change Wallpaper
    SUPER + F1 => Show This Help Menu
    SUPER + SHIFT + E => Exit Hyprland
    EOF
    }

    # Show the shortcuts menu
    extract_shortcuts | ${pkgs.wofi}/bin/wofi --dmenu --prompt "Hyprland Shortcuts" --width 800 --height 600 --cache-file /dev/null --insensitive
  '';

  # Script per lo sfondo casuale
  randomWallpaperScript = pkgs.writeShellScriptBin "hyprland-random-wallpaper" ''
    #!/usr/bin/env bash

    # Random wallpaper script for Hyprland
    # This script finds a random wallpaper from the user's wallpaper directory
    # and sets it as the current wallpaper using hyprpaper

    # Simple, consistent wallpaper directory
    WALLPAPER_DIR="$HOME/wallpapers"
    TEMP_CONFIG="/tmp/hyprpaper.conf"

    # Create the wallpaper directory if it doesn't exist
    ${pkgs.coreutils}/bin/mkdir -p "$WALLPAPER_DIR"

    # Find a random wallpaper
    RANDOM_WALLPAPER=$(${pkgs.findutils}/bin/find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) 2>/dev/null | ${pkgs.coreutils}/bin/shuf -n 1)

    if [ -z "$RANDOM_WALLPAPER" ]; then
      echo "No wallpapers found in $WALLPAPER_DIR"
      # Create a default black wallpaper if none found
      TEMP_WALLPAPER="/tmp/default-wallpaper.png"
      ${pkgs.imagemagick}/bin/convert -size 2560x1080 xc:black "$TEMP_WALLPAPER"
      RANDOM_WALLPAPER="$TEMP_WALLPAPER"
      echo "Created a default black wallpaper"
    fi

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

    # Generate a hyprpaper configuration with the selected wallpaper
    echo "preload = $RANDOM_WALLPAPER" > "$TEMP_CONFIG"
    echo "wallpaper = ,$RANDOM_WALLPAPER" >> "$TEMP_CONFIG"

    # Start hyprpaper with the new configuration
    ${pkgs.hyprpaper}/bin/hyprpaper --config "$TEMP_CONFIG" &

    echo "Set random wallpaper: $RANDOM_WALLPAPER"
  '';

  # Script per l'avvio affidabile di waybar
  waybarStartScript = pkgs.writeShellScriptBin "start-waybar" ''
    #!/usr/bin/env bash

    # Log delle operazioni
    LOG_FILE="$HOME/.waybar-start.log"
    echo "Script avviato: $(date)" > $LOG_FILE

    # Termina le istanze esistenti di waybar
    echo "Termino eventuali istanze di waybar..." >> $LOG_FILE
    ${pkgs.procps}/bin/pkill waybar || true

    # Attendi che Hyprland sia completamente inizializzato
    echo "Attendo 3 secondi per l'inizializzazione..." >> $LOG_FILE
    sleep 3

    # Imposta le variabili di ambiente per il cursore
    export XCURSOR_THEME=Adwaita
    export XCURSOR_SIZE=24
    echo "Variabili cursore: XCURSOR_THEME=$XCURSOR_THEME, XCURSOR_SIZE=$XCURSOR_SIZE" >> $LOG_FILE

    # Imposta via gsettings (funziona meglio in alcuni casi)
    gsettings set org.gnome.desktop.interface cursor-theme 'Adwaita'
    gsettings set org.gnome.desktop.interface cursor-size 24

    # Avvia waybar con percorso completo
    echo "Avvio waybar..." >> $LOG_FILE
    ${pkgs.waybar}/bin/waybar -l info >> $LOG_FILE 2>&1 &

    # Verifica l'avvio
    sleep 1
    if pgrep -x waybar > /dev/null; then
      echo "Waybar avviato con successo: $(date)" >> $LOG_FILE
    else
      echo "ERRORE: Waybar non è stato avviato: $(date)" >> $LOG_FILE
      # Tentativo di riavvio con opzioni di debug
      echo "Tentativo di riavvio con opzioni di debug..." >> $LOG_FILE
      ${pkgs.waybar}/bin/waybar --log debug >> $LOG_FILE 2>&1 &
    fi
  '';

  # Script per diagnosticare problemi con il cursore
  cursorDebugScript = pkgs.writeShellScriptBin "debug-cursor" ''
    #!/usr/bin/env bash

    echo "=== Debug Cursore ==="
    echo "Variabili di ambiente correnti:"
    echo "XCURSOR_THEME=$XCURSOR_THEME"
    echo "XCURSOR_SIZE=$XCURSOR_SIZE"

    echo -e "\nTemi cursore disponibili:"
    find /run/current-system/sw/share/icons -type d -name "cursors" | sort

    echo -e "\nImpostazioni cursore GTK:"
    gsettings get org.gnome.desktop.interface cursor-theme
    gsettings get org.gnome.desktop.interface cursor-size

    echo -e "\nApplico tema cursore Adwaita con dimensione 24 via gsettings:"
    gsettings set org.gnome.desktop.interface cursor-theme 'Adwaita'
    gsettings set org.gnome.desktop.interface cursor-size 24

    echo -e "\nVerifica dopo l'applicazione:"
    gsettings get org.gnome.desktop.interface cursor-theme
    gsettings get org.gnome.desktop.interface cursor-size
  '';
in {
  # Configurazione Hyprland
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      # Impostazioni generali
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
        };
      };

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
      ];

      # Variabili d'ambiente
      env = [
        "XCURSOR_SIZE,24"
        "XCURSOR_THEME,Adwaita"
        "GDK_BACKEND,wayland,x11" # Miglior compatibilità per app GTK
        "QT_QPA_PLATFORM,wayland;xcb" # Miglior compatibilità per app Qt
      ];

      # Invece, aggiungi una nuova sezione per le impostazioni del cursore
      # È importante notare che queste impostazioni non sono nella sezione "general"
      xwayland = {
        force_zero_scaling = true;
      };

      # Aggiungi questa nuova sezione per le ombre delle finestre se le vuoi
      # (opzionale, puoi rimuoverla se causa problemi)
      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
      };

      # Applicazioni all'avvio
      exec-once = [
        "${waybarStartScript}/bin/start-waybar"
        "${randomWallpaperScript}/bin/hyprland-random-wallpaper"
        "gsettings set org.gnome.desktop.interface cursor-theme 'Adwaita'"
        "gsettings set org.gnome.desktop.interface cursor-size 24"
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

        # Navigazione workspace
        "SUPER, 1, workspace, 1"
        "SUPER, 2, workspace, 2"
        "SUPER, 3, workspace, 3"
        "SUPER, 4, workspace, 4"
        "SUPER, 5, workspace, 5"
        # Navigazione workspace aggiuntiva
        "SUPER CTRL, Right, workspace, e+1"
        "SUPER CTRL, Left, workspace, e-1"

        # Spostamento finestre tra workspace
        "SUPER SHIFT, 1, movetoworkspace, 1"
        "SUPER SHIFT, 2, movetoworkspace, 2"
        "SUPER SHIFT, 3, movetoworkspace, 3"
        "SUPER SHIFT, 4, movetoworkspace, 4"
        "SUPER SHIFT, 5, movetoworkspace, 5"
        "SUPER SHIFT, Right, movetoworkspace, e+1"
        "SUPER SHIFT, Left, movetoworkspace, e-1"

        # Scorciatoia per sfondo casuale
        "SUPER, W, exec, ${randomWallpaperScript}/bin/hyprland-random-wallpaper"

        # Mostra scorciatoie tastiera
        "SUPER, F1, exec, ${shortcutMenuScript}/bin/hyprland-shortcut-menu"

        # Debug cursore
        "SUPER SHIFT, C, exec, ${cursorDebugScript}/bin/debug-cursor"

        # Logout
        "SUPER SHIFT, E, exec, hyprctl dispatch exit"
      ];
    };
  };

  # Aggiungi script ai pacchetti
  home.packages = [
    shortcutMenuScript
    randomWallpaperScript
    waybarStartScript
    cursorDebugScript
  ];

  # Configurazione Waybar
  programs.waybar = {
    enable = true;
    systemd.enable = false; # Disabilita integrazione systemd, usiamo il nostro script
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        modules-left = ["hyprland/workspaces"];
        modules-center = ["clock"];
        modules-right = ["custom/keymap" "pulseaudio" "network" "battery" "tray"];

        "hyprland/workspaces" = {
          format = "{icon}";
          on-click = "activate";
          format-icons = {
            "1" = "1";
            "2" = "2";
            "3" = "3";
            "4" = "4";
            "5" = "5";
          };
        };

        "clock" = {
          format = "{:%H:%M}";
          tooltip-format = "{:%Y-%m-%d}";
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

        # Modulo personalizzato per le scorciatoie da tastiera
        "custom/keymap" = {
          format = "⌨";
          tooltip = "Scorciatoie Hyprland";
          on-click = "${shortcutMenuScript}/bin/hyprland-shortcut-menu";
        };
      };
    };

    # Configurazione stile per Waybar
    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 14px;
      }

      window#waybar {
        background-color: rgba(40, 44, 52, 0.9);
        color: #abb2bf;
        border-bottom: 2px solid #61afef;
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
      }

      #clock, #battery, #pulseaudio, #network, #tray, #custom-keymap {
        padding: 0 10px;
        margin: 0 4px;
      }

      /* Stile per il pulsante della tastiera */
      #custom-keymap {
        color: #61afef;
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

      @keyframes blink {
        to {
          opacity: 0.5;
        }
      }

      /* Effetto hover per un feedback migliore */
      #custom-keymap:hover,
      #pulseaudio:hover,
      #network:hover {
        background-color: rgba(97, 175, 239, 0.2);
        border-radius: 5px;
      }
    '';
  };

  # Crea directory wallpaper durante l'attivazione
  home.activation.createWallpaperDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p $HOME/wallpapers
  '';

  # Configurazione Wofi (per il menu delle scorciatoie)
  programs.wofi = {
    enable = true;
    settings = {
      width = 500;
      height = 300;
      show = "drun";
      prompt = "Cerca...";
      hide_scroll = true;
      matching = "fuzzy";
    };
    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 14px;
      }

      window {
        background-color: rgba(40, 44, 52, 0.9);
        color: #abb2bf;
        border: 2px solid #61afef;
        border-radius: 10px;
      }

      #input {
        border: 2px solid #61afef;
        background-color: rgba(40, 44, 52, 0.8);
        color: #abb2bf;
        border-radius: 5px;
        margin: 5px;
        padding: 5px;
      }

      #entry {
        padding: 5px;
      }

      #entry:selected {
        background-color: rgba(97, 175, 239, 0.2);
        border-left: 3px solid #61afef;
      }
    '';
  };

  # Configurazione per la gestione dei file
  xdg.configFile = {
    # Script per inizializzare le impostazioni del cursore all'avvio della sessione
    "hypr/cursor-init.sh" = {
      text = ''
        #!/bin/sh
        export XCURSOR_THEME=Adwaita
        export XCURSOR_SIZE=24
        gsettings set org.gnome.desktop.interface cursor-theme 'Adwaita'
        gsettings set org.gnome.desktop.interface cursor-size 24
      '';
      executable = true;
    };
  };

  # Impostazioni specifiche per il tema del cursore
  home.sessionVariables = {
    XCURSOR_THEME = "Adwaita";
    XCURSOR_SIZE = "24";
  };

  # Configura GTK per supportare correttamente il tema del cursore
  gtk = {
    enable = true;
    cursorTheme = {
      name = "Adwaita";
      size = 24;
    };
  };
}
