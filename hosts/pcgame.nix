# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  imports =
    [
      # HOME MANAGER
      inputs.home-manager.nixosModules.default

      # HARDWARE
      ./hw/hardware-pcgame.nix

      # KERNEL (comment out for default kernel)
      ./sys-modules/zen.nix

      # GPU (choose one)
      # ./sys-modules/intel.nix
      ./sys-modules/nvidia.nix
      # ./sys-modules/amd.nix

      # DE: Desktop Environment (choose one)
      # ./sys-modules/cinnamon.nix
      ./sys-modules/gnome.nix
      # ./sys-modules/kde.nix

      # fonts
      ./sys-modules/fonts.nix
      # boot
      ./sys-modules/boot.nix
      # locale
      ./sys-modules/it.nix
      # nix
      ./sys-modules/nix.nix
      # sound
      ./sys-modules/sound.nix
      # print
      ./sys-modules/print.nix
      # SMB (Windows network share)
      # ./sys-modules/smb.nix
      # network: uncomment only in case of static or bridge configuration
      # ./sys-modules/network.nix
      # virtualization
      # ./sys-modules/vm.nix
      # ssh
      # ./sys-modules/ssh.nix
      # touchpad
      # ./sys-modules/touchpad.nix
      # gaming
      ./sys-modules/gaming.nix
    ];

  # Basic network configuration
  networking = {
    hostName = "pcgame";
    # comment out in case of static or bridge network config
    networkmanager.enable = true;
  };

  # For advanced network configurations, uncomment the module above and the following configuration.
  # networking.customSetup = {
  #   # Define a static IP address:
  #   staticIP.address = "192.168.1.27";
  #   # Note: Default prefix length is 24, change in network.nix if needed
  #   
  #   # Define the default gateway:
  #   gateway = "192.168.1.1";
  #   
  #   # Define DNS servers:
  #   nameservers = [ "192.168.1.1" "8.8.8.8" ];
  #   
  #   # Uncomment one of the following types:
  #   type = "static";
  #   # type = "bridge"; # only needed in case of virtual module uncommented (vm.nix)
  #   
  #   # For bridge configuration:
  #   # bridgeConfig.name = "br0";
  #   
  #   # Specify interface only if automatic detection fails:
  #   # interface = "enp7s0";
  #   # To discover network interfaces, you can use these commands:
  #   # - 'ip link show' (shows all network interfaces)
  #   # - 'ls /sys/class/net' (lists network interfaces)
  #   # - 'networkctl list' (shows network interfaces and their status)
  # };

  # allow unfree software
  nixpkgs.config.allowUnfree = true;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget # Tool for retrieving files using HTTP, HTTPS, and FTP
    git # version control
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.stefano = {
    isNormalUser = true;
    description = "stefano";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
  };

  # HOME-MANAGER as module
  home-manager =
    {
      # also pass inputs to home-manager modules
      extraSpecialArgs = { inherit inputs; };
      users = {
        stefano = import ../users/stefano.nix;
      };
    };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
