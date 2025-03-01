# nixos/hosts/pcgame/default.nix
{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./hardware.nix
    ../default.nix
    ../../modules/system/hardware/nvidia.nix
    ../../modules/system/services/docker.nix
    ../../modules/system/services/ssh.nix
  ];

  # System-specific packages (additional to common ones)
  environment.systemPackages = with pkgs; [
    # Add system packages
  ];

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.stefano = {
    isNormalUser = true;
    description = "stefano";
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
    ];
    # Default is zsh uncommet for bash shell
    # shell = pkgs.bash;
  };

  # HOME-MANAGER configuration specific to this host
  home-manager = {
    extraSpecialArgs = {
      inherit inputs;
    };
    users = {
      stefano = import ../../home/stefano;
    };
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
  };

  # Docker containers configuration specific to this host
  virtualisation.dockerSetup = {
    enable = true;
    user = "stefano";
  };

  # Basic network configuration
  networking = {
    hostName = "pcgame";
    networkmanager.enable = true;

    # Firewall configuration
    firewall = {
      enable = true;
      # TCP Ports
      allowedTCPPorts = [
        4662 # aMule eD2K data
        4672 # aMule incoming connections
      ];
      # UDP Ports
      allowedUDPPorts = [
        4665 # aMule eD2K
        4672 # aMule Kad
      ];
    };
  };

  # ollama
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
  };
  systemd.services.ollama = {
    serviceConfig = {
      SupplementaryGroups = [
        "video"
        "render"
      ];
      Environment = [
        "NVIDIA_VISIBLE_DEVICES=all"
        "CUDA_VISIBLE_DEVICES=0"
        "LD_LIBRARY_PATH=/run/opengl-driver/lib"
        "OLLAMA_DEBUG=1"
      ];
    };
    after = [
      "syslog.target"
      "network.target"
      "display-manager.service"
    ];
    wants = ["display-manager.service"];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken.
  system.stateVersion = "24.05"; # Did you read the comment?
}
