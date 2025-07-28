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

    projectDirectory = mkOption {
      type = types.str;
      description = "Root directory of the npm project (containing flake.nix)";
      example = "/home/acquisti/easyfatt";
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
        WorkingDirectory = cfg.projectDirectory;

        # Use nix develop to ensure consistent environment
        ExecStartPre = "${pkgs.bash}/bin/bash -c 'cd ${cfg.projectDirectory} && PRODUCTION=1 ${pkgs.nix}/bin/nix develop --command npm install'";
        ExecStart = "${pkgs.bash}/bin/bash -c 'cd ${cfg.projectDirectory} && PRODUCTION=1 ${pkgs.nix}/bin/nix develop --command node ${cfg.scriptPath}'";

        Restart =
          if cfg.autoRestart
          then "always"
          else "no";
        RestartSec = "10";

        # Security settings
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = "read-only";
        ReadWritePaths = [cfg.projectDirectory];
      };

      environment = {
        NIX_CONFIG = "experimental-features = nix-command flakes";
        PRODUCTION = "1";
      };

      path = with pkgs; [nix bash];
    };
  };
}
