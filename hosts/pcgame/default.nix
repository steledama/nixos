# nixos/hosts/pcgame/default.nix
{ inputs, ... }: {
  imports = [
    ./hardware.nix
    ../default.nix
    ../../modules/system/hardware/nvidia.nix
    ../../modules/system/services/docker.nix
    ../../modules/system/services/ssh.nix
    # ../../modules/system/services/ollama.nix
  ];

  # extraServices.ollama.enable = true;

  # System-specific packages (additional to common ones)
  # environment.systemPackages = with pkgs; [
  # Add system packages
  # ];

  # User
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

  # HOME-MANAGER
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

  # Docker
  virtualisation.dockerSetup = {
    enable = true;
    user = "stefano";
    enableNvidia = true;
  };

  # Network
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
        11435 # msty ollama service for llm
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
