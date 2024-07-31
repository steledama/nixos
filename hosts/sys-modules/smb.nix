# This module provides flexible configuration for mounting Windows network shares (SMB)
# Note: Remember to create a credentials file at /etc/nixos/smb-secrets with content:
# username=YourUsername
# password=YourPassword
# Ensure to set appropriate permissions: chmod 600 /etc/nixos/smb-secrets

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.windowsShare;
in
{
  options.services.windowsShare = {
    enable = mkEnableOption "Windows network share mounting";

    mountPoint = mkOption {
      type = types.str;
      default = "/mnt/windowsshare";
      description = "Where to mount the Windows share";
    };

    deviceAddress = mkOption {
      type = types.str;
      example = "//192.168.1.100/SharedFolder";
      description = "Address of the Windows share";
    };

    credentials = mkOption {
      type = types.path;
      example = "./smb-secrets";
      description = "Path to the credentials file, relative to the host configuration file";
    };

    uid = mkOption {
      type = types.int;
      default = 1000;
      description = "UID for the mounted share";
    };

    gid = mkOption {
      type = types.int;
      default = 100;
      description = "GID for the mounted share";
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
        "credentials=${toString cfg.credentials}"
        "uid=${toString cfg.uid}"
        "gid=${toString cfg.gid}"
      ];
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.mountPoint} 0755 root root -"
    ];
  };
}


