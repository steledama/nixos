{ config, lib, pkgs, ... }:

let
  cfg = config.virtualisation.dockerSetup;
in
{
  options.virtualisation.dockerSetup = {
    enable = lib.mkEnableOption "Docker setup";
    user = lib.mkOption {
      type = lib.types.str;
      description = "Username to add to the docker group";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      # You can add more Docker-specific configurations here if needed
    };

    # Add the specified user to the docker group
    users.users.${cfg.user}.extraGroups = [ "docker" ];

    # Optionally, you can add Docker Compose
    environment.systemPackages = [ pkgs.docker-compose ];
  };
}
