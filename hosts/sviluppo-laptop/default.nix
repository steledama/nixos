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
    ../../modules/system/hardware/intel.nix
    ../../modules/system/hardware/touchpad.nix
    # Services
    ../../modules/system/services/docker.nix
  ];

  # System-specific packages (additional to common ones)
  environment.systemPackages = with pkgs; [
    # Add system packages
  ];

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.sviluppo = {
    isNormalUser = true;
    description = "sviluppo";
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
      sviluppo = import ../../home/sviluppo;
    };
  };

  # Basic network configuration
  networking = {
    hostName = "sviluppo-laptop";
    networkmanager.enable = true;

    # Firewall configuration
    firewall = {
      enable = true;
      allowedTCPPorts = [
        2222 # ssh
      ];
    };
  };

  # Enable the OpenSSH daemon on port 2222
  services.openssh = {
    enable = true;
    ports = [ 2222 ];
  };

  # Docker containers configuration specific to this host
  virtualisation.dockerSetup = {
    enable = true;
    user = "sviluppo";
  };

  system.stateVersion = "24.11";
}
