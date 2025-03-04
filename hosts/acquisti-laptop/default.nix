# nixos/hosts/acquisti-laptop/default.nix
{ pkgs
, inputs
, ...
}: {
  imports = [
    ./hardware.nix
    ../default.nix
    ../../modules/system/hardware/intel.nix
    ../../modules/system/hardware/touchpad.nix
    ../../modules/system/services/docker.nix
    ../../modules/system/services/ssh.nix
    ../../modules/system/services/smb.nix
  ];

  # System-specific packages (additional to common ones)
  environment.systemPackages = with pkgs; [
    # Add system packages
  ];

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.acquisti = {
    isNormalUser = true;
    description = "acquisti";
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
      acquisti = import ../../home/acquisti;
    };
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
  };

  # Basic network configuration
  networking = {
    hostName = "acquisti-laptop";

    # Hosts
    hosts = {
      "127.0.0.1" = [
        "5.89.62.125" # pubblico lavoro
        "10.40.40.130" # riservato lavoro eth
        "192.168.1.16" # riservato casa wifi
      ];
    };

    networkmanager = {
      enable = true;
      settings = {
        "connection" = {
          "ethernet.route-metric" = 100;
          "wifi.route-metric" = 200;
        };
      };
    };

    firewall = {
      enable = true;
      allowedTCPPorts = [
        22 # ssh
        80 # wordpress
        443 # https
      ];
      allowPing = true;
      logRefusedConnections = true;
      logRefusedPackets = true;
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
    user = "acquisti";
  };

  system.stateVersion = "24.05";
}
