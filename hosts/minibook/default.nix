# nixos/hosts/minibook/default.nix
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
    ../../modules/system/hardware/minibook.nix
    ../../modules/system/services/docker.nix
    ../../modules/system/services/ssh.nix
    ../../modules/system/services/gdm.nix
    ../../modules/system/desktop/gnome.nix
  ];

  # Network configuration
  networking = {
    hostName = "minibook";
    networkmanager = {
      enable = true;
    };
  };

  # Keyboard layout (default is us international)
  # hardware.keyboard = {
  #   layout = "it";
  #   variant = "";
  #   options = "";
  # };

  # User
  users.users.stele = {
    isNormalUser = true;
    description = "stele";
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
    ];
    # shell = pkgs.bash; # Default is zsh uncommet for bash shell
  };

  # Home-manager
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

  # Docker containers
  virtualisation.dockerSetup = {
    enable = true;
    user = "stele";
  };

  # System-host-specific packages (additional to common ones)
  # environment.systemPackages = with pkgs; [
  # Add system packages
  # ];

  system.stateVersion = "24.11";
}
