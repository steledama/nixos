# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ pkgs, inputs, ... }:

{
  imports = [
    # Import common configurations
    ../default.nix

    # Import hardware configuration
    ./hardware.nix

    # KERNEL (zen kernel specific to this host)
    ../../modules/system/zen.nix

    # GPU (specific to this host - nvidia)
    ../../modules/system/hardware/nvidia.nix

    # Docker (specific to this host)
    ../../modules/system/services/docker.nix
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
        8080 # ERPNext
      ];

      # UDP Ports
      allowedUDPPorts = [
        4665 # aMule eD2K
        4672 # aMule Kad
      ];
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken.
  system.stateVersion = "24.05"; # Did you read the comment?
}
