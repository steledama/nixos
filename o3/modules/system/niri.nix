# modules/system/niri.nix
# Niri scrollable-tiling Wayland compositor with Noctalia shell
# Supports two modes:
# - Coexistence with another DM: autoLoginUser = ""
# - Standalone with greetd + tuigreet (neve, deck): autoLoginUser = "username"
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.niriDesktop;
  sessionExec = pkgs.writeShellScript "niri-session-codex" ''
    #!${pkgs.bash}/bin/bash

    # Match upstream niri-session, but avoid the deprecated
    # `systemctl --user import-environment` call without explicit variables.
    if [ -n "''${MANAGERPID:-}" ] && [ "''${SYSTEMD_EXEC_PID:-}" = "$$" ]; then
      case "$(${pkgs.procps}/bin/ps -p "$MANAGERPID" -o cmd=)" in
      *systemd*--user*)
        exec ${pkgs.niri}/bin/niri --session
        ;;
      esac
    fi

    if [ -n "''${SHELL:-}" ] &&
      ${pkgs.gnugrep}/bin/grep -q "$SHELL" /etc/shells &&
      ! (echo "$SHELL" | ${pkgs.gnugrep}/bin/grep -q "false") &&
      ! (echo "$SHELL" | ${pkgs.gnugrep}/bin/grep -q "nologin"); then
      if [ "''${1:-}" != "-l" ]; then
        exec ${pkgs.bash}/bin/bash -c "exec -l '$SHELL' -c '$0 -l $*'"
      else
        shift
      fi
    fi

    if command -v systemctl >/dev/null 2>&1; then
      if systemctl --user -q is-active niri.service; then
        echo "A niri session is already running."
        exit 1
      fi

      systemctl --user reset-failed

      systemctl --user import-environment \
        DBUS_SESSION_BUS_ADDRESS \
        DESKTOP_SESSION \
        DISPLAY \
        GTK_THEME \
        HOME \
        LANG \
        LOGNAME \
        NIXOS_OZONE_WL \
        PATH \
        SHELL \
        TERM \
        USER \
        WAYLAND_DISPLAY \
        XCURSOR_PATH \
        XCURSOR_SIZE \
        XCURSOR_THEME \
        XDG_CONFIG_DIRS \
        XDG_CONFIG_HOME \
        XDG_CURRENT_DESKTOP \
        XDG_DATA_DIRS \
        XDG_RUNTIME_DIR \
        XDG_SESSION_TYPE

      if command -v dbus-update-activation-environment >/dev/null 2>&1; then
        dbus-update-activation-environment --all
      fi

      systemctl --user --wait start niri.service
      systemctl --user start --job-mode=replace-irreversibly niri-shutdown.target
      systemctl --user unset-environment WAYLAND_DISPLAY DISPLAY XDG_SESSION_TYPE XDG_CURRENT_DESKTOP NIRI_SOCKET
    else
      exec ${pkgs.niri}/bin/niri --session
    fi
  '';
in {
  options.services.niriDesktop = {
    autoLoginUser = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Auto-login user via greetd. Leave empty when another display manager handles sessions (e.g. COSMIC-greeter).";
    };
  };

  config = {
    programs.niri = {
      enable = true;
      # Use GTK portal for file chooser - file manager remains available as file manager
      useNautilus = false;
    };

    programs.xwayland.enable = true;

    programs.noctalia = {
      enable = true;
      # The session unit is owned by Home Manager.
      systemd.enable = false;
    };

    environment.systemPackages = lib.optionals (cfg.autoLoginUser != "") [pkgs.tuigreet];

    # Standalone mode: greetd + tuigreet (TUI greeter, no compositor needed)
    services.greetd = lib.mkIf (cfg.autoLoginUser != "") {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd ${sessionExec}";
          user = "greeter";
        };
        initial_session = {
          command = "${sessionExec}";
          user = cfg.autoLoginUser;
        };
      };
    };

    # Required for battery widget in Noctalia
    services.upower.enable = true;

    # Required for Thunar USB automount
    services.udisks2.enable = true;
    services.gvfs.enable = true;

    # Services required for standalone niri (COSMIC provides these when coexisting)
    security.polkit.enable = lib.mkIf (cfg.autoLoginUser != "") true;
    services.gnome.gnome-keyring.enable = lib.mkIf (cfg.autoLoginUser != "") true;
    security.pam.services.greetd.enableGnomeKeyring = lib.mkIf (cfg.autoLoginUser != "") true;
  };
}
