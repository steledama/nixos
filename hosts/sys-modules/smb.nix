# This module provides flexible configuration for mounting Windows network shares (SMB)

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.windowsShare;

  # Helper function to safely get user UID
  getUserUid = username:
    if config.users.users ? ${username}
    then toString config.users.users.${username}.uid
    else "1000"; # Default UID if user not found

  # Helper function to safely get user GID
  getUserGid = username:
    if config.users.users ? ${username} && config.users.users.${username} ? group
    then toString config.users.groups.${config.users.users.${username}.group}.gid
    else "100"; # Default GID if group not found
in
{
  options.services.windowsShare = {
    enable = mkEnableOption "Windows network share mounting";

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
      default = "/mnt/windowsshare";
      description = "Where to mount the Windows share";
    };

    credentialsFile = mkOption {
      type = types.str;
      default = "/etc/nixos/smb-secrets";
      description = "Path to the credentials file";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.cifs-utils ];

    fileSystems.${cfg.mountPoint} = {
      device = cfg.deviceAddress;
      fsType = "cifs";
      options = [
        "x-systemd.automount"
        "noauto"
        "x-systemd.idle-timeout=60"
        "credentials=${cfg.credentialsFile}"
        "uid=${getUserUid cfg.username}"
        "gid=${getUserGid cfg.username}"
        "file_mode=0664"
        "dir_mode=0775"
      ];
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.mountPoint} 0755 root root -"
    ];

    # Ensure the credentials file exists and has correct permissions
    system.activationScripts.smbCredentials = ''
      if [ ! -f ${cfg.credentialsFile} ]; then
        touch ${cfg.credentialsFile}
        chmod 600 ${cfg.credentialsFile}
        echo "username=${cfg.username}" > ${cfg.credentialsFile}
        echo "password=YourPasswordHere" >> ${cfg.credentialsFile}
        echo "Remember to set the correct password in ${cfg.credentialsFile}"
      fi
    '';
  };
}
