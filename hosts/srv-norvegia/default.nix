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
    "consoleblank=600" # Questo imposta il timeout
  ];

  # TTY extra disponibili
  console = {
    extraTTYs = ["tty1"]; # Solo per avere tty1 disponibile
  };

  # Servizio per avviare cmatrix automaticamente
  systemd.services.console-screensaver = {
    description = "Console Matrix Screensaver";
    serviceConfig = {
      Type = "simple";
      TTYPath = "/dev/tty1";
      ExecStart = "${pkgs.cmatrix}/bin/cmatrix -ab -u 2 -C green";
      StandardInput = "tty";
      StandardOutput = "tty";
      Restart = "always";
      RestartSec = "10"; # Se si blocca, riavvia dopo 10 secondi
    };
  };

  # Network
  networking = {
    hostName = "srv-norvegia";
    networkmanager.enable = true;
    firewall = {
      enable = true;
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

      # Regola specifica SOLO per Node.js server
      extraCommands = ''
        # Allow local network access to Node.js server only
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
