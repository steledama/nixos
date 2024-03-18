{ pkgs, config, ... }:
{
  # enable virtualization
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  programs.dconf.enable = true;
  # guest additions
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
  services.spice-webdavd.enable = true;
  environment.systemPackages = with pkgs; [
    libvirt
    virt-viewer
  ];

  # networking bridge
  networking.interfaces.br0 = {
    ipv4.addresses = [{
      address = "192.168.1.2";
      prefixLength = 24;
    }];
    bridge.enable = true;
    bridge.stp = false; # Opzionale, disabilita Spanning Tree Protocol
    bridge.interfaces = [ "enp7s0" ]; # Sostituisci con il nome della tua interfaccia
  };

}

