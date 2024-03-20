# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  imports =
    [
      # host hardware scan result
      ./hw-pcgame.nix
      # kernel zen (comment out for default kernel)
      ./sys-modules/zen.nix
      # GPU (choose one)
      # gpu nvidia
      ./sys-modules/nvidia.nix
      # gpu amd
      # ./sys-modules/amd.nix
      # gpu intel
      # ./sys-modules/intel.nix
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
      # syncthing
      ./sys-modules/syncthing.nix
      # virtualization
      ./sys-modules/vm.nix
      # ssh
      # ./sys-modules/ssh.nix
      # Display Manager
      # sddm (kde and hyprland)
      # ./sys-modules/sddm.nix
      # gdm (gnome)
      ./sys-modules/gdm.nix
      # Desktop Environmnet
      # kde
      #./sys-modules/kde6.nix
      # ./sys-modules/kde5.nix
      # gnome
      ./sys-modules/gnome.nix
      # home manager
      inputs.home-manager.nixosModules.default
    ];

  # NETWORKING
  # hostname
  networking.hostName = "pcgame"; # Define your hostname.
  # networkmanager
  networking.networkmanager.enable = false;
  # Enables wireless support via wpa_supplicant.
  # networking.wireless.enable = true;
  # bridge for virtual network
  networking.interfaces.enp7s0.useDHCP = false;
  networking.bridges = {
    "br0" = {
      interfaces = [ "enp7s0" ];
    };
  };
  networking.interfaces.br0.ipv4.addresses = [{
    address = "192.168.1.27";
    prefixLength = 24;
  }];
  networking.defaultGateway = "192.168.1.1";
  networking.nameservers = [ "192.168.1.1" "8.8.8.8" ];
  # proxy
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # allow unfree software
  nixpkgs.config.allowUnfree = true;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim # terminal editor
    wget # Tool for retrieving files using HTTP, HTTPS, and FTP
    git # version control
    google-chrome # browser
    gimp # pixel design
    inkscape # vector design
    zathura # pdf viewer
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
    extraGroups = [ "networkmanager" "wheel" "libvirtd"];
  };

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
  system.stateVersion = "23.11"; # Did you read the comment?

}
