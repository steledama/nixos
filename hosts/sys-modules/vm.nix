# This module provides basic configuration for virtualization on NixOS

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.virtualisation.customVM;
in
{
  options.virtualisation.customVM = {
    enable = mkEnableOption "Custom virtualization setup";
  };

  config = mkIf cfg.enable {
    # Basic VM support
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;

    # SPICE support (enabled by default)
    services.spice-vdagentd.enable = true;
    services.spice-webdavd.enable = true;

    # Shared folder support (enabled by default)
    environment.systemPackages = [ pkgs.virtiofsd ];

    # Additional notes in the configuration
    environment.etc."virtualization-notes".text = ''
      Virtualization Notes:
      - If running NixOS as a guest, enable the QEMU Guest Agent with:
        services.qemuGuest.enable = true;
      
      - For Windows guests, install VirtIO drivers and WinFSP:
        choco install virtio-drivers winfsp
        sc.exe create VirtioFsSvc binpath="C:\ProgramData\Chocolatey\bin\virtiofs.exe" start=auto depend="WinFsp.Launcher/VirtioFsDrv" DisplayName="Virtio FS Service"
        sc.exe start VirtioFsSvc
    '';
  };
}
