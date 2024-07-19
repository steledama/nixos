{ pkgs, config, ... }:
{
  # enable virtualization
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  # dconf
  programs.dconf.enable = true;

  # additions to enable only if nixos is guest
  # services.qemuGuest.enable = true;

  # windows guest: choco install virtio-drivers winfsp
  # sc.exe create VirtioFsSvc binpath="C:\ProgramData\Chocolatey\bin\virtiofs.exe" start=auto depend="WinFsp.Launcher/VirtioFsDrv" DisplayName="Virtio FS Service"
  # sc.exe start VirtioFsSvc

  # spice for better host-guest integration
  services.spice-vdagentd.enable = true;
  services.spice-webdavd.enable = true;

  # others
  environment.systemPackages = with pkgs; [
    # libvirt
    virtiofsd # shared folder between host and guest
  ];
}

