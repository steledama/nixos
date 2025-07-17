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
    # ... altri pacchetti ...
    ncurses # Include database terminfo completo
  ];

  # Network
  networking = {
    hostName = "srv-norvegia";
    networkmanager.enable = true;
    firewall = {
      enable = false;
      allowedTCPPorts = [
        22 # ssh
        80 # nginx
        443 # nginx https
        3001 # control p
        8384 # syncthing
        8385 # baserow
        8443 # ToscanaTrading
        8444 # Flexora
      ];
      allowPing = true;
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
