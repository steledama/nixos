# modules/system/services/automated-scripts.nix
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.automatedScripts;

  # Create a wrapper script
  scriptsWrapper = pkgs.writeShellScript "automated-scripts-wrapper" ''
    set -e

    echo "Starting automated scripts wrapper..."

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
    echo "Starting automated scripts from: ${cfg.scriptPath}"

    # Run the scripts
    cd ${cfg.scriptPath}
    exec bash ${cfg.scriptPath}/automated-scripts.sh
  '';
in {
  options.services.automatedScripts = {
    enable = mkEnableOption "automated scripts service";

    scriptPath = mkOption {
      type = types.str;
      description = "Path to the script directory";
      example = "/home/acquisti/bi/scripts";
    };

    projectDirectory = mkOption {
      type = types.str;
      description = "Root directory of the npm project (containing flake.nix)";
      example = "/home/acquisti/bi";
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
        ExecStart = "${scriptsWrapper}";
      };

      environment = {
        NIX_CONFIG = "experimental-features = nix-command flakes";
        HOME = "/home/${cfg.user}";
      };

      path = with pkgs; [nix bash coreutils nodejs_22];
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
