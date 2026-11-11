# hosts/deck/default.nix
{
  pkgs,
  lib,
  identity,
  ...
}: let
  presentations = import ../../presentations.nix;
  pressione = import ../../pressione.nix;
  deckPresentationPorts = lib.attrValues presentations.privileged.deck;
  mkAccept = subnet: port: "iptables -A nixos-fw -s ${subnet} -p tcp --dport ${toString port} -j nixos-fw-accept";
in {
  imports = [
    ./hardware.nix
    ../default.nix
    ../../modules/system/hardware/intel.nix
    ../../modules/system/hardware/touchpad.nix
    ../../modules/system/hardware/laptop-lid.nix
    ../../modules/system/hardware/deck.nix
    ../../modules/system/services/wireguard.nix
    ../../modules/system/services/wireguard-work-client.nix
    ../../modules/system/services/scan-ftp.nix
  ];

  services.wireguardServer = {
    enable = true;
    interfaceName = "casa";
    vpnSubnet = identity.home.vpn.serverAddress;
    externalInterface = "home0";
    privateKeyFile = "/etc/wireguard/casa-vpn.key";
    lanSubnets = [identity.home.lan.subnet];
    protectedTcpPorts = [22];
    # Peer VPN casa in ordine fisso: telefono, norvegia.
    peers = map (n: {
      inherit (identity.home.vpn.hosts.${n}) publicKey;
      allowedIPs = [identity.home.vpn.hosts.${n}.address];
    }) ["telefono" "norvegia"];
  };

  services.wireguardWorkClient = {
    enable = true;
    address = identity.work.vpn.hosts.deck.address;
    privateKeyFile = "/home/stele/.config/wireguard/work-office.key";
    serverPublicKey = identity.work.vpn.serverPublicKey;
    endpoint = identity.work.vpn.endpoint;
    allowedIPs = identity.work.vpn.allowedIPs;
    # L'ufficio si raggiunge solo da deck (2026-11-05): i nomi dei server e
    # dei dispositivi LAN ufficio risolvono solo qui.
    hosts = identity.work.lan.hosts // identity.work.lan.devices;
  };

  # Network (networkmanager + firewall enable in o3/hosts/default.nix)
  # Keep the USB Ethernet adapter name stable across physical USB ports: the
  # kernel path-based name changes whenever the dongle is moved.
  systemd.network.links."10-home-ethernet" = {
    matchConfig.PermanentMACAddress = identity.home.deckEthernetMac;
    linkConfig.Name = "home0";
  };

  networking = {
    hostName = "deck";
    networkmanager = {
      # Senza questo, NetworkManager crea un profilo generico "Wired
      # connection N" a ogni comparsa del dongle USB-C e a volte lo attiva
      # al posto di home0-static (priorita' piu' bassa ma vince comunque la
      # race all'avvio) -> deck finisce in DHCP invece che sull'IP statico.
      settings.main.no-auto-default = "*";
      ensureProfiles = {
        profiles = {
          "home0-static" = {
            connection = {
              id = "home0-static";
              type = "ethernet";
              interface-name = "home0"; # USB-C ethernet dongle
              autoconnect = true;
              autoconnect-priority = 100;
            };
            ipv4 = {
              method = "manual";
              address1 = "${identity.home.lan.hosts.deck}/24,${identity.home.lan.gateway}";
              dns = identity.home.lan.dns;
              route-metric = 100;
            };
            ipv6 = {
              method = "auto";
              route-metric = 100;
            };
          };
        };
      };
    };
    firewall = {
      # Restrict local admin UIs to home LAN only.
      extraCommands = ''
        # aMule Web UI (4711)
        iptables -A nixos-fw -s ${identity.home.lan.subnet} -p tcp --dport 4711 -j nixos-fw-accept
        iptables -A nixos-fw -s ${identity.home.vpn.subnet} -p tcp --dport 4711 -j nixos-fw-accept
        # Presentazioni (o3/presentations.nix): servizi permanenti di deck da LAN
        # e VPN casa, lancio manuale anche dalla VPN (la LAN è in o3/hosts/default.nix)
        ${lib.concatMapStringsSep "\n" (mkAccept identity.home.lan.subnet) deckPresentationPorts}
        ${lib.concatMapStringsSep "\n" (mkAccept identity.home.vpn.subnet) ([presentations.manualPort] ++ deckPresentationPorts)}
        # PWA pressione salute: solo LAN e VPN casa.
        ${mkAccept identity.home.lan.subnet pressione.port}
        ${mkAccept identity.home.vpn.subnet pressione.port}
      '';
    };
  };

  # Keyboard configuration (US International layout with dead keys)
  console.keyMap = "us-acentos"; # US International with dead keys for console
  # Wayland keyboard layout configured in the Niri user config

  # aMule daemon (web UI: http://deck:4711)
  # amuleapi replaces amuleweb (deprecated upstream since aMule 3.1.0); it
  # keeps the old port so the LAN/VPN firewall rules above stay valid.
  services.amule = {
    enable = true;
    user = "stele";
    group = "users";
    openPeerPorts = true; # TCP 4662 + UDP 4672
    openAmuleApiPort = false;
    AmuleApiAdminPasswordFile = "/var/lib/amuled/password";
    ExternalConnectPasswordFile = "/var/lib/amuled/password";
    settings = {
      eMule = {
        Serverlist = 1;
        Ed2kServersUrl = "http://upd.emule-security.org/server.met";
        IncomingDir = "/home/stele/sync/downloads";
        TempDir = "/home/stele/Downloads/.amule-temp";
      };
      HTTPDownload.URL_2 = "http://upd.emule-security.org/server.met";
      AmuleApi = {
        Enabled = 1;
        # Non-loopback bind requires the admin password set above.
        BindAddress = "0.0.0.0";
        HttpPort = 4711;
      };
    };
  };

  # Refresh server.met at startup; if the endpoint is unreachable keep the
  # existing file instead of blocking the service start.
  systemd.services.amuled.preStart = lib.mkAfter ''
    if ${lib.getExe pkgs.curl} -fsSL "https://upd.emule-security.org/server.met" \
      -o /var/lib/amuled/server.met.new; then
      ${pkgs.coreutils}/bin/mv /var/lib/amuled/server.met.new /var/lib/amuled/server.met
    fi
  '';

  # Allow aMule to access /home/stele (ProtectHome=strict blocks it)
  systemd.services.amuled.serviceConfig.ProtectHome = lib.mkForce "tmpfs";
  systemd.services.amuled.serviceConfig.BindPaths = [
    "/home/stele/sync/downloads"
    "/home/stele/Downloads/.amule-temp"
  ];

  # Scan-to-FTP dalla Ricoh IM 550: le scansioni finiscono nella cartella
  # Syncthing, quindi compaiono anche su neve e game.
  services.scanFtp = {
    enable = true;
    owner = "stele";
    directory = "/home/stele/sync/scansioni";
    sourceAddress = identity.home.printers.im550;
    interface = "home0";
  };

  system.stateVersion = "25.11";
}
