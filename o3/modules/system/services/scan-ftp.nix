# modules/system/services/scan-ftp.nix
#
# Scan-to-FTP: una multifunzione di rete deposita le scansioni via FTP in una
# cartella dell'utente. Il login FTP è un utente dedicato senza shell, che
# vsftpd rimappa (guest) sul proprietario della cartella: i file nascono suoi
# e la password salvata nella stampante non apre nient'altro. FTP viaggia in
# chiaro, quindi porta di controllo e porte passive si aprono solo
# all'indirizzo della stampante e sull'interfaccia LAN indicata.
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.scanFtp;
  pasvRange = "${toString cfg.passivePorts.min}:${toString cfg.passivePorts.max}";
in {
  options.services.scanFtp = {
    enable = mkEnableOption "Scan-to-FTP receiver for a network MFP";
    loginUser = mkOption {
      type = types.str;
      default = "scansioni";
      description = "FTP login stored in the MFP; password set once with `sudo passwd`.";
    };
    owner = mkOption {
      type = types.str;
      description = "User that owns the received files.";
    };
    directory = mkOption {
      type = types.str;
      description = "Absolute path where scans land (FTP root, chrooted).";
    };
    sourceAddress = mkOption {
      type = types.str;
      description = "IPv4 address of the MFP allowed to connect.";
    };
    interface = mkOption {
      type = types.str;
      description = "LAN interface the MFP is reached through.";
    };
    passivePorts = {
      min = mkOption {
        type = types.port;
        default = 50000;
      };
      max = mkOption {
        type = types.port;
        default = 50009;
      };
    };
  };

  config = mkIf cfg.enable {
    users.users.${cfg.loginUser} = {
      isSystemUser = true;
      group = cfg.loginUser;
      description = "Login FTP della multifunzione (scan-to-FTP)";
      home = "/var/empty";
      shell = "${pkgs.shadow}/bin/nologin";
    };
    users.groups.${cfg.loginUser} = {};

    # Senza un servizio PAM dedicato vsftpd cade su /etc/pam.d/other, che nega.
    security.pam.services.vsftpd = {};

    services.vsftpd = {
      enable = true;
      localUsers = true;
      writeEnable = true;
      chrootlocalUser = true;
      allowWriteableChroot = true;
      # Solo il login della stampante entra; con guest_enable tutti i login
      # locali diventerebbero l'owner, quindi la lista è una whitelist.
      userlistEnable = true;
      userlistDeny = false;
      userlist = [cfg.loginUser];
      localRoot = cfg.directory;
      virtualUseLocalPrivs = true;
      extraConfig = ''
        guest_enable=YES
        guest_username=${cfg.owner}
        local_umask=022
        pasv_enable=YES
        pasv_min_port=${toString cfg.passivePorts.min}
        pasv_max_port=${toString cfg.passivePorts.max}
      '';
    };

    systemd.tmpfiles.rules = ["d ${cfg.directory} 0755 ${cfg.owner} users -"];

    networking.firewall.extraCommands = ''
      iptables -A nixos-fw -i ${cfg.interface} -s ${cfg.sourceAddress} -p tcp --dport 21 -j nixos-fw-accept
      iptables -A nixos-fw -i ${cfg.interface} -s ${cfg.sourceAddress} -p tcp --dport ${pasvRange} -j nixos-fw-accept
    '';
  };
}
