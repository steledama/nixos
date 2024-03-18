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
}

