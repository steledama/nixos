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

    projectDirectory = mkOption {
      type = types.str;
      description = "Root directory of the npm project (containing flake.nix)";
      example = "/home/acquisti/easyfatt";
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
        WorkingDirectory = cfg.projectDirectory;

        # Use nix develop to ensure consistent environment
        ExecStart = "${pkgs.bash}/bin/bash -c 'cd ${cfg.projectDirectory} && PRODUCTION=1 ${pkgs.nix}/bin/nix develop --command bash ${cfg.scriptPath}/automated-scripts.sh'";
      };

      environment = {
        NIX_CONFIG = "experimental-features = nix-command flakes";
        PRODUCTION = "1";
      };

      path = with pkgs; [nix bash];
    };

    systemd.timers.automated-scripts = {
      description = "Run automated scripts daily at 4 AM";
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = "04:00:00";
        Persistent = true;
      };
    };
  };
}
