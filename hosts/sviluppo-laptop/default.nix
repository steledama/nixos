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

    # GPU (specific to this host - intel)
    ../../modules/system/hardware/intel.nix

    # Docker (specific to this host)
    ../../modules/system/services/docker.nix

    # SMB (specific to this host)
    ../../modules/system/services/smb.nix

    # Touchpad (laptop specific)
    ../../modules/system/hardware/touchpad.nix
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
        8080 # ERPNext
      ];
    };
  };

  # Windows network share configs
  services.windowsShares = {
    enable = true;
    shares = {
      scan = {
        enable = true;
        deviceAddress = "//10.40.40.98/scan";
        username = "acquisti";
        mountPoint = "/mnt/scan";
        credentialsFile = "/home/acquisti/nixos/smb-secrets";
      };
      manuali = {
        enable = true;
        deviceAddress = "//10.40.40.98/manuali";
        username = "acquisti";
        mountPoint = "/mnt/manuali";
        credentialsFile = "/home/acquisti/nixos/smb-secrets";
      };
    };
  };

  # Docker containers configuration specific to this host
  virtualisation.dockerSetup = {
    enable = true;
    user = "sviluppo";
  };

  system.stateVersion = "24.11";
}
