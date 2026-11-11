{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.programs.niriConfig;
  workspaceFocusBinds =
    lib.concatMapStringsSep "\n"
    (num: ''Mod+${toString num} hotkey-overlay-title="Workspace n" { focus-workspace ${toString num}; }'')
    (lib.range 1 9);
  workspaceMoveBinds =
    lib.concatMapStringsSep "\n"
    (num: ''Mod+Shift+${toString num} hotkey-overlay-title="Move Column to Workspace n" { move-column-to-workspace ${toString num}; }'')
    (lib.range 1 9);
  # Binario di sistema (dichiarato in modules/system/niri.nix): il symlink
  # /run/current-system evita di trascinare una seconda copia nella closure
  # home. Policy pacchetti GUI = system-level: kb/configuration-patterns.md.
  noctalia = "/run/current-system/sw/bin/noctalia";
in {
  imports = [
    ./gtk.nix
  ];

  options.programs.niriConfig = {
    enable = lib.mkEnableOption "Niri home configuration";
    keyboardLayout = lib.mkOption {
      type = lib.types.str;
      default = "it";
      description = "XKB keyboard layout";
    };
    keyboardVariant = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "XKB keyboard variant";
    };
    extraConfig = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Extra niri config (for outputs or host-specific tweaks)";
    };
    internalDisplay = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Internal display name for lid close/open handling.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };

    home.packages = [
      pkgs.thunar
      pkgs.tumbler
      # wl-clipboard vive nella baseline system (o3/hosts/default.nix)
      pkgs.cliphist
      pkgs.wl-clip-persist
      # niri avvia da sé xwayland-satellite (dal PATH) e imposta DISPLAY:
      # niente spawn-at-startup, che ne lancerebbe un secondo
      pkgs.xwayland-satellite
    ];

    # exo (usato da Thunar per "Apri terminale qui") legge le preferenze solo
    # da ~/.config/xfce4/helpers.rc, non da /etc/xdg.
    xdg.configFile."xfce4/helpers.rc".text = ''
      TerminalEmulator=foot
    '';

    # Preferenze foot: config utente a home (il pacchetto e la registrazione
    # xdg-terminal-exec vivono in modules/system/gui-apps.nix).
    xdg.configFile."foot/foot.ini".text = ''
      [main]
      font=JetBrainsMono Nerd Font:size=13
      dpi-aware=no
      login-shell=yes

      [colors-dark]
      # Filo di trasparenza (1.0 = opaco); richiede compositor Wayland con alpha
      alpha=0.85

      [scrollback]
      lines=10000

      [mouse]
      hide-when-typing=yes
    '';

    xdg.configFile."noctalia/config.toml" = {
      text = ''
        [shell]
        launch_apps_as_systemd_services = true
      '';
    };

    systemd.user.services.noctalia = {
      Unit = {
        Description = "Noctalia desktop shell";
        PartOf = "graphical-session.target";
        After = "graphical-session.target";
      };
      Install.WantedBy = ["graphical-session.target"];
      Service = {
        ExecStart = noctalia;
        Restart = "on-failure";
        RestartSec = "3s";
        StandardOutput = "journal";
        StandardError = "journal";
      };
    };

    # Legacy launcher workaround; retain until the v5 runtime check passes.
    # Override terminal-based apps to launch explicitly inside foot.
    # btop and lftp use xdg.desktopEntries (no conflicting system entry).
    # Helix ships Helix.desktop (capital H) in its package; we shadow it via
    # xdg.dataFile so XDG_DATA_HOME takes precedence over the nix profile.
    xdg.desktopEntries = {
      btop = {
        name = "btop++";
        genericName = "System Monitor";
        exec = "foot btop";
        icon = "btop";
        terminal = false;
        categories = ["System" "Monitor"];
      };
      lftp = {
        name = "lftp";
        exec = "foot lftp";
        terminal = false;
        categories = ["Network" "FileTransfer"];
      };
    };

    xdg.dataFile."applications/Helix.desktop".text = ''
      [Desktop Entry]
      Name=Helix
      GenericName=Text Editor
      Exec=foot hx %F
      Icon=helix
      Terminal=false
      Type=Application
      Categories=Development;TextEditor;
      MimeType=text/plain;
    '';

    xdg.configFile."niri/config.kdl".text = let
      variantLine =
        lib.optionalString (cfg.keyboardVariant != "")
        ''variant "${cfg.keyboardVariant}"'';
      lidSwitchConfig = lib.optionalString (cfg.internalDisplay != null) ''
        switch-events {
            lid-close { spawn "niri" "msg" "output" "${cfg.internalDisplay}" "off"; }
            lid-open { spawn "niri" "msg" "output" "${cfg.internalDisplay}" "on"; }
        }
      '';
    in ''
            input {
                keyboard {
                    xkb {
                        layout "${cfg.keyboardLayout}"
                        ${variantLine}
                    }
                }
                touchpad {
                    tap
                    natural-scroll
                    dwt
                }
            }

            ${lidSwitchConfig}

            ${cfg.extraConfig}

            spawn-at-startup "systemctl" "--user" "start" "noctalia.service"
            spawn-at-startup "wl-clip-persist" "--clipboard" "both"
            spawn-at-startup "wl-paste" "--type" "text" "--watch" "cliphist" "store"
            spawn-at-startup "wl-paste" "--type" "image" "--watch" "cliphist" "store"

            binds {
                Mod+F1 hotkey-overlay-title="Show Shortcuts" { show-hotkey-overlay; }
                Mod+Escape hotkey-overlay-title="Session Menu" { spawn "${noctalia}" "msg" "panel-toggle" "session"; }
                Ctrl+Alt+Delete hotkey-overlay-title="Quit Niri" { quit skip-confirmation=true; }
                Ctrl+Alt+Escape hotkey-overlay-title="Restart Shell" { spawn "systemctl" "--user" "restart" "noctalia"; }
                Mod+Q hotkey-overlay-title="Close Window" { close-window; }

                Mod+Return hotkey-overlay-title="Open Terminal" { spawn "foot"; }
                Mod+Space hotkey-overlay-title="App Launcher" { spawn "${noctalia}" "msg" "panel-toggle" "launcher"; }
                Mod+E hotkey-overlay-title="Open File Manager" { spawn "thunar"; }
                Mod+B hotkey-overlay-title="Open Browser" { spawn "chromium"; }

                Mod+M hotkey-overlay-title="Maximize Column" { maximize-column; }
                Mod+F hotkey-overlay-title="Fullscreen Window" { fullscreen-window; }
                Mod+R hotkey-overlay-title="Switch Preset Column Widths" { switch-preset-column-width; }
                Mod+O hotkey-overlay-title="Open Overview" { toggle-overview; }
                Mod+Shift+Space hotkey-overlay-title="Toggle Float/Tiling" { toggle-window-floating; }
                Mod+Shift+V hotkey-overlay-title="Switch Focus Float/Tiling" { switch-focus-between-floating-and-tiling; }
                Mod+Comma hotkey-overlay-title="Consume Window Left" { consume-or-expel-window-left; }
                Mod+Period hotkey-overlay-title="Consume Window Right" { consume-or-expel-window-right; }

                Mod+Left hotkey-overlay-title="Focus Column Left" { focus-column-left; }
                Mod+Right hotkey-overlay-title="Focus Column Right" { focus-column-right; }
                Mod+Up hotkey-overlay-title="Focus Window Up" { focus-window-up; }
                Mod+Down hotkey-overlay-title="Focus Window Down" { focus-window-down; }

                Mod+Alt+Left hotkey-overlay-title="Move Column Left" { move-column-left; }
                Mod+Alt+Right hotkey-overlay-title="Move Column Right" { move-column-right; }
                Mod+Alt+Up hotkey-overlay-title="Move Window Up" { move-window-up; }
                Mod+Alt+Down hotkey-overlay-title="Move Window Down" { move-window-down; }

                Mod+Page_Down hotkey-overlay-title="Switch Workspace Down" { focus-workspace-down; }
                Mod+Page_Up hotkey-overlay-title="Switch Workspace Up" { focus-workspace-up; }
                Mod+Shift+Page_Down hotkey-overlay-title="Move Column to Workspace Down" { move-column-to-workspace-down; }
                Mod+Shift+Page_Up hotkey-overlay-title="Move Column to Workspace Up" { move-column-to-workspace-up; }

                Mod+Ctrl+Left hotkey-overlay-title="Focus Monitor Left" { focus-monitor-left; }
                Mod+Ctrl+Right hotkey-overlay-title="Focus Monitor Right" { focus-monitor-right; }
                Mod+Ctrl+Up hotkey-overlay-title="Focus Monitor Up" { focus-monitor-up; }
                Mod+Ctrl+Down hotkey-overlay-title="Focus Monitor Down" { focus-monitor-down; }

                Mod+Shift+Ctrl+Left hotkey-overlay-title="Move Column to Monitor Left" { move-column-to-monitor-left; }
                Mod+Shift+Ctrl+Right hotkey-overlay-title="Move Column to Monitor Right" { move-column-to-monitor-right; }
                Mod+Shift+Ctrl+Up hotkey-overlay-title="Move Column to Monitor Up" { move-column-to-monitor-up; }
                Mod+Shift+Ctrl+Down hotkey-overlay-title="Move Column to Monitor Down" { move-column-to-monitor-down; }

      ${workspaceFocusBinds}
      ${workspaceMoveBinds}

                Print hotkey-overlay-title="Screenshot" { screenshot; }
                Alt+Print hotkey-overlay-title="Screenshot Window" { screenshot-window; }
                Ctrl+Print hotkey-overlay-title="Screenshot Screen" { screenshot-screen; }
            }
    '';
  };
}
