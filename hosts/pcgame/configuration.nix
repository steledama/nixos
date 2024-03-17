# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

let
  # user name definition
  username = "stefano";
in

{
  imports =
    [
      # hardware scan result
      ./hardware-configuration.nix
      # kernel zen (comment for default kernel)
      ../../system/zen.nix
      # gpu brand (choose one)
      # gpu nvidia
      ../../system/nvidia.nix
      # gpu amd
      # ../../system/amd.nix
      # gpu intel
      # ../../system/intel.nix
      # boot
      ../../system/boot.nix
      # locale
      ../../system/locale.nix
      # networking
      ../../system/networking.nix
      # nix
      ../../system/nix.nix
      # sound
      ../../system/sound.nix
      # print
      ../../system/print.nix
      # ssh
      # ../../system/ssh.nix
      # display manager (choose one)
      # sddm (kde and hyprland)
      ../../system/sddm.nix
      # gdm (gnome)
      # ../../system/gdm.nix
      # desktop environment (choose one)
      # kde
      ../../system/kde6.nix
      # ../../system/kde5.nix
      # gnome
      # ../../system/gnome.nix
      # home manager
      inputs.home-manager.nixosModules.default
    ];
  # HOSTNAME
  networking.hostName = "nixos"; # Define your hostname.

  # syncthing
  services = {
    syncthing = {
      enable = true;
      user = "${username}";
      dataDir = "/home/${username}"; # Default folder for new synced folders
      configDir = "/home/${username}/.config/syncthing"; # Folder for Syncthing's settings and keys
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    isNormalUser = true;
    description = "${username}";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    ];
  };

  home-manager =
    {
      # also pass inputs to home-manager modules
      extraSpecialArgs = { inherit inputs; };
      users = {
        ${username} = import ./${username}.nix;
      };
    };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim # terminal editor
    wget # Tool for retrieving files using HTTP, HTTPS, and FTP
    git # version control
    firefox # browser
    nixpkgs-fmt # code formater for nix
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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
