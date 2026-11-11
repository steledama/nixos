# o3/identity/work.example.nix (template pubblicabile di work.nix)
#
# Identità del mondo LAVORO ridotta a ciò che usa deck: è l'identità
# incrociata dichiarata (goal.md, «Due repo, confine netto»). La coppia server
# e il resto dell'identità di lavoro vivono nel repo example-org/nixos-ufficio.
#
# - lan: indirizzi dei server per ssh-work-lan.nix e, con i dispositivi LAN
#   ufficio, per /etc/hosts di deck (wireguard-work-client.nix, opzione
#   hosts): l'ufficio si raggiunge solo da deck;
# - vpn: client della VPN lavoro di deck (wireguard-work-client.nix).
{
  methodFetch = [];
  lan = {
    hosts = {
      norvegia = "10.0.0.2";
      svezia = "10.0.0.3";
    };
    # Dispositivi LAN non gestiti da nessun repo ma risolti per nome (/etc/hosts).
    devices = {
      danea2 = "10.0.0.4"; # PC Danea, serve danea-auto sulla 8001
    };
  };

  vpn = {
    allowedIPs = ["10.0.1.0/24" "10.0.0.0/24"];
    endpoint = "work.example.com:51820";
    serverPublicKey = "REPLACE_WITH_WORK_VPN_SERVER_PUBKEY=";
    hosts.deck.address = "10.0.1.20/32";
  };
}
