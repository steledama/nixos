# modules/home/rclone.nix
# Google Drive access via rclone mounts, one remote per Google account.
#
# SETUP REQUIRED after home-manager switch:
# 1. Run: rclone config
# 2. Create a new remote (n), choose "Google Drive" (type: drive)
# 3. Follow OAuth flow in browser
# 4. Repeat for each Google account (use different remote names)
#
# DECLARATIVE USAGE (recommended, streaming, no complete local copy):
#   services.rcloneMount = {
#     enable = true;
#     mounts = {
#       gdrive-personale = {
#         remote = "gdrive-personale";
#         mountPoint = "Drive/gdrive-personale";
#       };
#     };
#   };
# Mounts start automatically at login via systemd user services.
#
# MANUAL USAGE (template, for one-off accounts):
# - Mount: systemctl --user start rclone-mount@gdrive-personale
# - List remotes: rclone listremotes
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfgMount = config.services.rcloneMount;

  # The user manager has no network-online.target (it lives in the system
  # manager), so ordering on it is a no-op: at boot the mounts started before
  # DNS was up and failed once. Wait for the Drive API to resolve instead,
  # up to 60s; past that, Restart=on-failure takes over.
  waitForDrive = pkgs.writeShellScript "rclone-wait-for-drive" ''
    for _ in {1..60}; do
      ${pkgs.getent}/bin/getent hosts www.googleapis.com >/dev/null && exit 0
      ${pkgs.coreutils}/bin/sleep 1
    done
    exit 1
  '';

  mountOpts = lib.types.submodule {
    options = {
      remote = lib.mkOption {
        type = lib.types.str;
        example = "gdrive-personale";
        description = "Rclone remote name";
      };
      remotePath = lib.mkOption {
        type = lib.types.str;
        default = "";
        example = "Documenti";
        description = "Path within the remote (empty for root)";
      };
      mountPoint = lib.mkOption {
        type = lib.types.str;
        example = "Drive/gdrive-personale";
        description = "Local mount point relative to home directory";
      };
      private = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          The remote lives in its own config file,
          ~/.config/rclone-<name>/rclone.conf, instead of the shared
          rclone.conf: the autonomous cycles (cicli.nix) cannot see that file
          nor the mount point, so the account stays out of their reach.
        '';
      };
    };
  };
in {
  options.services.rcloneMount = {
    enable = lib.mkEnableOption "Automatic rclone FUSE mounts";

    mounts = lib.mkOption {
      type = lib.types.attrsOf mountOpts;
      default = {};
      description = "Set of rclone remotes to mount automatically at login";
    };
  };

  config = {
    home.packages = with pkgs; [
      rclone # Cloud storage sync tool
      fuse3 # Required for rclone mount
    ];

    # Create Drive directories for multiple accounts
    home.file."Drive/.keep".text = "";

    # Systemd services: templates + auto-started services
    systemd.user.services = lib.mkMerge [
      # Template for mounting (manual use)
      {
        "rclone-mount@" = {
          Unit = {
            Description = "Rclone mount for %i";
          };
          Service = {
            Type = "notify";
            Environment = ["PATH=/run/wrappers/bin"];
            ExecStartPre = [
              "-/run/wrappers/bin/fusermount3 -uz %h/Drive/%i"
              "${pkgs.coreutils}/bin/mkdir -p %h/Drive/%i"
              "${waitForDrive}"
            ];
            ExecStart = ''
              ${pkgs.rclone}/bin/rclone mount %i: %h/Drive/%i \
                --vfs-cache-mode full \
                --vfs-cache-max-age 24h \
                --vfs-cache-max-size 10G \
                --dir-cache-time 1h \
                --poll-interval 15s \
                --log-level INFO
            '';
            ExecStop = "/run/wrappers/bin/fusermount3 -u %h/Drive/%i";
            Restart = "on-failure";
            RestartSec = "10s";
          };
          Install = {};
        };
      }
      # Auto-started mount services for configured mounts
      (lib.mkIf cfgMount.enable (
        lib.mapAttrs' (
          name: mount:
            lib.nameValuePair "rclone-mount-${name}" {
              Unit = {
                Description = "Rclone mount for ${name} (${mount.remote}:${mount.remotePath})";
              };
              Service = {
                Type = "notify";
                Environment = ["PATH=/run/wrappers/bin"];
                ExecStartPre = [
                  # A previous rclone killed without unmounting leaves a
                  # detached endpoint ("socket non connesso") where mkdir
                  # fails: drop it first, no-op when nothing is mounted.
                  "-/run/wrappers/bin/fusermount3 -uz %h/${mount.mountPoint}"
                  "${pkgs.coreutils}/bin/mkdir -p %h/${mount.mountPoint}"
                  "${waitForDrive}"
                ];
                ExecStart = let
                  configFlag = lib.optionalString mount.private " --config %h/.config/rclone-${name}/rclone.conf";
                  remoteSrc =
                    if mount.remotePath == ""
                    then "${mount.remote}:"
                    else "${mount.remote}:${mount.remotePath}";
                in ''
                  ${pkgs.rclone}/bin/rclone mount ${remoteSrc} %h/${mount.mountPoint}${configFlag} \
                    --vfs-cache-mode full \
                    --vfs-cache-max-age 24h \
                    --vfs-cache-max-size 10G \
                    --dir-cache-time 1h \
                    --poll-interval 15s \
                    --allow-non-empty \
                    --log-level INFO
                '';
                ExecStop = "/run/wrappers/bin/fusermount3 -u %h/${mount.mountPoint}";
                Restart = "on-failure";
                RestartSec = "10s";
              };
              Install = {
                WantedBy = ["default.target"];
              };
            }
        )
        cfgMount.mounts
      ))
    ];
  };
}
