# nixos/hosts/srv-norvegia/default.nix
{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./hardware.nix
    ../default.nix
    ../../modules/system/hardware/intel.nix
    ../../modules/system/hardware/touchpad.nix
    ../../modules/system/services/docker.nix
    ../../modules/system/services/ssh.nix
    ../../modules/system/services/smb.nix
    ../../modules/system/services/automated-scripts.nix
    ../../modules/system/services/node-server.nix
  ];

  environment.systemPackages = with pkgs; [
    cmatrix # Matrix screensaver
  ];

  # Imposta il timeout per blank della console (10 minuti = 600 secondi)
  boot.kernelParams = [
    "consoleblank=600" # Schermo nero dopo 10 minuti di inattività
  ];

  # Network
  networking = {
    hostName = "srv-norvegia";

    # Disable NetworkManager for server with static IP
    networkmanager.enable = false;

    # Enable systemd-networkd for static IP configuration
    useNetworkd = true;
    useDHCP = false;

    # Static IP configuration
    interfaces.enp0s31f6 = {
      # Replace with your actual interface name
      ipv4.addresses = [
        {
          address = "10.40.40.99"; # Your static IP
          prefixLength = 24; # Subnet mask /24 = 255.255.255.0
        }
      ];
    };

    # Default gateway
    defaultGateway = {
      address = "10.40.40.254";
      interface = "enp0s31f6";
    };

    # DNS servers
    nameservers = [
      "8.8.8.8" # Google DNS
      "8.8.4.4" # Google DNS secondary
      "10.40.40.254" # Router as fallback
    ];

    firewall = {
      enable = true; # Changed from false to true for better security
      allowedTCPPorts = [
        22 # ssh
        80 # nginx
        443 # nginx https
        3001 # control panel
        8384 # syncthing
        8385 # baserow
        8443 # ToscanaTrading
        8444 # Flexora
      ];
      allowPing = true;

      # Allow local network access to Node.js server only
      extraCommands = ''
        iptables -A INPUT -s 10.40.40.0/24 -p tcp --dport 3001 -j ACCEPT
      '';
    };
  };

  # User
  users.users.acquisti = {
    isNormalUser = true;
    description = "acquisti";
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
      "video"
    ];
  };

  home-manager = {
    extraSpecialArgs = {
      inherit inputs;
    };
    users = {
      acquisti = import ../../home/acquisti;
    };
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "";
  };

  # Docker containers
  virtualisation.dockerSetup = {
    enable = true;
    user = "acquisti";
  };

  # Windows network share
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

  # Keyboard layout
  hardware.keyboard = {
    layout = "no"; # Norwegian layout
    variant = "";
    options = "compose:ralt";
  };

  # Automated scripts service
  services.automatedScripts = {
    enable = true;
    scriptPath = "/home/acquisti/easyfatt/scripts";
    user = "acquisti";
  };

  # Node.js server service
  services.nodeServer = {
    enable = true;
    scriptPath = "/home/acquisti/easyfatt/scripts/server.js";
    workingDirectory = "/home/acquisti/easyfatt/scripts";
    projectDirectory = "/home/acquisti/easyfatt";
    user = "acquisti";
  };

  system.stateVersion = "24.11";
}
