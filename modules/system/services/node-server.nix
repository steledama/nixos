# modules/system/services/node-server.nix
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.nodeServer;
in {
  options.services.nodeServer = {
    enable = mkEnableOption "Node.js server service";

    scriptPath = mkOption {
      type = types.str;
      description = "Path to the Node.js script";
      example = "/home/acquisti/easyfatt/scripts/server.js";
    };

    workingDirectory = mkOption {
      type = types.str;
      description = "Working directory for the script";
      example = "/home/acquisti/easyfatt/scripts";
    };

    user = mkOption {
      type = types.str;
      description = "User to run the script as";
      example = "acquisti";
    };

    autoRestart = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to automatically restart the service on failure";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.node-server = {
      description = "Node.js Server Service";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        WorkingDirectory = cfg.workingDirectory;
        ExecStart = "${pkgs.nodejs}/bin/node ${cfg.scriptPath}";
        Restart =
          if cfg.autoRestart
          then "always"
          else "no";
        RestartSec = "10";

        # Security settings
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = "read-only";
        ReadWritePaths = [cfg.workingDirectory];
      };

      path = with pkgs; [nodejs];
    };
  };
}
