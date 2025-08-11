# modules/home/desktop-apps.nix
# Common desktop applications for GUI users
# IMPORTANT: This module should only be imported by desktop users!
# Server environments (like srv-norvegia) should NOT import this module.
{pkgs, ...}: {
  imports = [
    ./zed.nix # GUI editor with language server support
  ];
  home.packages = with pkgs; [
    zen-browser # browser
    microsoft-edge # Web browser from Microsoft
    libreoffice # productivity suite
    thunderbird # email client
    obsidian # knowledge base
    inkscape # vector graphics editor
    ghostty # terminal emulator
    evince # GNOME's document viewer
    gparted # Graphical disk partitioning tool
    usbimager # OS image USB flasher
    filezilla # ftp client
  ];
}
