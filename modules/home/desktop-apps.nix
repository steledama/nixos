# modules/home/desktop-apps.nix
# Common desktop applications for GUI users
# IMPORTANT: This module should only be imported by desktop users!
# Server environments (like srv-norvegia) should NOT import this module.
{pkgs, ...}: {
  imports = [
    ./zed.nix # GUI editor with language server support
  ];
  home.packages = with pkgs; [
    vivaldi # browser
    microsoft-edge # browser
    libreoffice # productivity suite
    thunderbird # email client
    obsidian # knowledge base
    inkscape # vector graphics editor
    ghostty # terminal emulator
    evince # document viewer
    gparted # disk partitioning tool
    usbimager # os image usb flasher
    filezilla # ftp client
  ];
}
