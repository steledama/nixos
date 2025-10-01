# modules/system/services/node-server.nix
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.nodeServer;

  # Create a wrapper script that sets up the environment
  nodeWrapper = pkgs.writeShellScript "controlp-wrapper" ''
    set -e

    echo "Starting Node.js server wrapper..."

    # Get Node.js from the flake
    NODE_PATH=$(cd ${cfg.projectDirectory} && ${pkgs.nix}/bin/nix eval --raw .#devShells.${pkgs.system}.default.buildInputs.0 2>/dev/null || echo "${pkgs.nodejs_22}")

    # Fallback to system Node.js if flake evaluation fails
    if [ ! -x "$NODE_PATH/bin/node" ]; then
      echo "Flake evaluation failed, using system Node.js"
      NODE_PATH="${pkgs.nodejs_22}"
    else
      echo "Using Node.js from flake: $NODE_PATH"
    fi

    export PATH="$NODE_PATH/bin:$PATH"
    export NODE_PATH="$NODE_PATH"

    # Install dependencies if needed
    if [ ! -d "${cfg.projectDirectory}/node_modules" ] || [ "${cfg.projectDirectory}/package.json" -nt "${cfg.projectDirectory}/node_modules" ]; then
      echo "Installing/updating dependencies..."
      cd ${cfg.projectDirectory}
      npm install
    else
      echo "Dependencies up to date"
    fi

    # Show Node.js version for debugging
    echo "Using Node.js version: $(node --version)"
    echo "Starting server: ${cfg.scriptPath}"

    # Run the server
    cd ${cfg.projectDirectory}
    exec node ${cfg.scriptPath}
  '';
in {
  options.services.nodeServer = {
    enable = mkEnableOption "Node.js server service";

    scriptPath = mkOption {
      type = types.str;
      description = "Path to the Node.js script";
      example = "/home/norvegia/bi/scripts/server.js";
    };

    workingDirectory = mkOption {
      type = types.str;
      description = "Working directory for the script";
      example = "/home/norvegia/bi/scripts";
    };

    projectDirectory = mkOption {
      type = types.str;
      description = "Root directory of the npm project (containing flake.nix)";
      example = "/home/norvegia/bi";
    };

    user = mkOption {
      type = types.str;
      description = "User to run the script as";
      example = "norvegia";
    };

    autoRestart = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to automatically restart the service on failure";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.controlp = {
      description = "Node.js Server Service";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        WorkingDirectory = cfg.projectDirectory;
        ExecStart = "${nodeWrapper}";

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
        HOME = "/home/${cfg.user}";
      };

      path = with pkgs; [nix bash coreutils nodejs_22];
    };
  };
}
