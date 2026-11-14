# modules/system/host-names.nix
#
# Static name resolution for the home hosts (no local DNS or mDNS on the home
# LAN): deck, neve and game resolve to their home LAN address on every host,
# the host's own name excluded (NixOS already maps it to 127.0.0.2). The
# office development workstation norvegia reaches them through its home tunnel, whose AllowedIPs
# include the home LAN (manual start). Office names
# (svezia, norvegia, danea2) resolve only where the office VPN is, on deck:
# wireguard-work-client.nix declares them.
{
  config,
  lib,
  identity,
  ...
}: let
  self = config.networking.hostName;
  addresses = lib.filterAttrs (name: _: name != self) identity.home.lan.hosts;
in {
  networking.hosts = lib.mapAttrs' (name: address: lib.nameValuePair address [name]) addresses;
}
