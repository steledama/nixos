# modules/system/services/docker.nix
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.virtualisation.dockerSetup;
in {
  options.virtualisation.dockerSetup = {
    enable = lib.mkEnableOption "Docker setup";
    user = lib.mkOption {
      type = lib.types.str;
      description = "Username to add to the docker group";
    };
    enableNvidia = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable NVIDIA support for Docker";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
    };

    hardware.nvidia-container-toolkit = lib.mkIf cfg.enableNvidia {
      enable = true;
    };

    # Add the specified user to the docker group
    users.users.${cfg.user}.extraGroups = ["docker"];

    # Optionally, you can add Docker Compose
    environment.systemPackages = [pkgs.docker-compose];
  };
}
