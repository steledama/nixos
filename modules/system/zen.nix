# nixos/modules/system/zen.nix
{pkgs, ...}: {
  boot.kernelPackages = pkgs.linuxPackages_zen;
}
