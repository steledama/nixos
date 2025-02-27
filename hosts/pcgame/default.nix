# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ pkgs, inputs, ... }:

{
  imports = [
    # Hardware specific for this host
    ./hardware.nix
    # Common configurations
    ../default.nix
    # Kernel
    ../../modules/system/zen.nix
    # Hardware
    ../../modules/system/hardware/nvidia.nix
    # Services
    ../../modules/system/services/docker.nix
    ../../modules/system/services/ssh.nix
  ];

  # System-specific packages (additional to common ones)
  environment.systemPackages = with pkgs; [
    amule # Peer-to-peer client for the eD2K and Kademlia networks
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
    # default user shell
    shell = pkgs.zsh;
  };

  # HOME-MANAGER configuration specific to this host
  home-manager = {
    extraSpecialArgs = {
      inherit inputs;
    };
    users = {
      stefano = import ../../home/stefano;
    };
    # Existing configs backup
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
    wants = [ "display-manager.service" ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken.
  system.stateVersion = "24.05"; # Did you read the comment?
}
