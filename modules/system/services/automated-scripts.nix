# modules/system/services/automated-scripts.nix
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.automatedScripts;
in {
  options.services.automatedScripts = {
    enable = mkEnableOption "automated scripts service";

    scriptPath = mkOption {
      type = types.str;
      description = "Path to the script directory";
      example = "/home/acquisti/easyfatt/scripts";
    };

    user = mkOption {
      type = types.str;
      description = "User to run the scripts as";
      example = "acquisti";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.automated-scripts = {
      description = "Automated Node.js scripts execution";
      serviceConfig = {
        Type = "oneshot";
        User = cfg.user;
        WorkingDirectory = cfg.scriptPath;
        ExecStart = "${pkgs.bash}/bin/bash ${cfg.scriptPath}/automated-scripts.sh";
      };
      path = with pkgs; [ nodejs bash ];
    };

    systemd.timers.automated-scripts = {
      description = "Run automated scripts daily at 4 AM";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "04:00:00";
        Persistent = true;
      };
    };
  };
}
