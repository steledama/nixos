# modules/system/home-vpn-route.nix
#
# Route the home VPN subnet through deck for home clients other than deck
# (game, neve). Without it they reach the VPN peers (the phone, the standby
# server) only via the default gateway, which knows nothing of 10.20.0.0/24.
# A NetworkManager dispatcher adds the route whenever an interface comes up on
# the home LAN, so DHCP profiles and reconnects keep it; on other networks
# (a laptop away from home) nothing is added. The standby server answers
# through its tunnel, whose AllowedIPs include the home LAN; the tunnel stays
# manual. The office LAN is reached from deck only (2026-11-05): no route
# towards it here.
{
  pkgs,
  identity,
  ...
}: let
  ip = "${pkgs.iproute2}/bin/ip";
in {
  networking.networkmanager.dispatcherScripts = [
    {
      type = "basic";
      source = pkgs.writeShellScript "home-vpn-route" ''
        interface="$1"
        action="$2"
        case "$action" in
          up | dhcp4-change) ;;
          *) exit 0 ;;
        esac
        # Only on the home LAN: the interface carries its connected route.
        [ -n "$(${ip} -4 route show exact ${identity.home.lan.subnet} dev "$interface")" ] || exit 0
        ${ip} -4 route replace ${identity.home.vpn.subnet} via ${identity.home.lan.hosts.deck} dev "$interface"
      '';
    }
  ];
}
