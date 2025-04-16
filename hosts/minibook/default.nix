# nixos/hosts/acquisti-laptop/default.nix
{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./hardware.nix
    ../default.nix
    ../../modules/system/hardware/intel.nix
    ../../modules/system/hardware/touchpad.nix
    ../../modules/system/services/docker.nix
    ../../modules/system/services/ssh.nix
  ];

  # System-specific packages (additional to common ones)
  environment.systemPackages = with pkgs; [
    # Add system packages
  ];

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.stele = {
    isNormalUser = true;
    description = "stele";
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
      stele = import ../../home/stele;
    };
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
  };

  # Basic network configuration
  networking = {
    hostName = "minibook";
    networkmanager = {
      enable = true;
    };
  };

  # Docker containers configuration specific to this host
  virtualisation.dockerSetup = {
    enable = true;
    user = "stele";
  };

  system.stateVersion = "24.11";
}
