# This module provides flexible configuration for mounting multiple Windows network shares (SMB protocol)

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.windowsShares;

  # Helper function to safely get user UID
  getUserUid =
    username:
    if config.users.users ? ${username} then toString config.users.users.${username}.uid else "1000"; # Default UID if user not found

  # Helper function to safely get user GID
  getUserGid =
    username:
    if config.users.users ? ${username} && config.users.users.${username} ? group then
      toString config.users.groups.${config.users.users.${username}.group}.gid
    else
      "100"; # Default GID if group not found

  # Share configuration type
  shareOpts = types.submodule {
    options = {
      enable = mkEnableOption "this Windows network share";

      deviceAddress = mkOption {
        type = types.str;
        example = "//192.168.1.100/SharedFolder";
        description = "Address of the Windows share";
      };

      username = mkOption {
        type = types.str;
        description = "Username for the Windows share";
      };

      mountPoint = mkOption {
        type = types.str;
        description = "Where to mount the Windows share";
      };

      credentialsFile = mkOption {
        type = types.str;
        default = "/etc/nixos/smb-secrets";
        description = "Path to the credentials file";
      };
    };
  };
in
{
  options.services.windowsShares = {
    enable = mkEnableOption "Windows network shares mounting";

    shares = mkOption {
      type = types.attrsOf shareOpts;
      default = { };
      description = "Set of Windows shares to mount";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.cifs-utils ];

    # Create fileSystems entries for each enabled share
    fileSystems = mapAttrs' (
      name: share:
      nameValuePair share.mountPoint {
        device = share.deviceAddress;
        fsType = "cifs";
        options = [
          "x-systemd.automount"
          "noauto"
          "x-systemd.idle-timeout=60"
          "credentials=${share.credentialsFile}"
          "uid=${getUserUid share.username}"
          "gid=${getUserGid share.username}"
          "file_mode=0664"
          "dir_mode=0775"
        ];
      }
    ) (filterAttrs (name: share: share.enable) cfg.shares);

    # Create mount points for each enabled share
    system.activationScripts = mapAttrs' (
      name: share:
      nameValuePair "smbMountPoint-${name}" ''
        mkdir -p ${share.mountPoint}
        chmod 755 ${share.mountPoint}
      ''
    ) (filterAttrs (name: share: share.enable) cfg.shares);
  };
}
