# modules/home/desktop-apps.nix
# Common desktop applications for GUI users
# IMPORTANT: This module should only be imported by desktop users!
# Server environments (like srv-norvegia) should NOT import this module.
{pkgs, ...}: {
  # VS Code editor with extensions support
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
  };
  home.packages = with pkgs; [
    vivaldi # Browser
    libreoffice # Productivity suite
    obsidian # Knowledge base
    inkscape # Vector graphics editor
    ghostty # Terminal emulator
    evince # Document viewer
    gparted # Disk partitioning tool
    usbimager # Os image usb flasher
    filezilla # Ftp client
    amule # Peer-to-peer client
    anydesk # Desktop sharing application
  ];
}
