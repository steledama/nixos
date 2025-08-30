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
    vivaldi # browser
    libreoffice # productivity suite
    obsidian # knowledge base
    inkscape # vector graphics editor
    ghostty # terminal emulator
    evince # document viewer
    gparted # disk partitioning tool
    usbimager # os image usb flasher
    filezilla # ftp client
  ];
}
