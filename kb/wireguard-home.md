---
stato: maturo
---

# WireGuard home

deck funge da server WireGuard per la rete casa, con endpoint pubblico UDP 51820. Questo è l'ingresso VPN; le altre porte pubbliche sono descritte in
`network-architecture`.

## Architettura

```
Internet
  │
  └─ deck:51820/UDP  ← ingresso VPN pubblico
       │
       └─ VPN 10.20.0.0/24
            ├─ 10.20.0.1  deck (server)
            ├─ 10.20.0.3  telefono
            └─ 10.20.0.5  norvegia   (sviluppo, tunnel manuale)
```

`norvegia` è la postazione di sviluppo in ufficio e il client della VPN
casa, ad avvio manuale. `svezia` è il server e non è peer della VPN casa.
Configurazione e gestione dei due host vivono nel repo
`example-org/nixos-ufficio`; qui deck dichiara il peer di `norvegia`.
Da casa si raggiunge il server `svezia` tramite la VPN ufficio di deck
(`network-architecture`, «Accesso all'ufficio da casa»).

Split tunnel: i client VPN raggiungono `10.20.0.0/24` e `192.168.0.0/24` (LAN
casa) tramite il tunnel; il resto del traffico va direttamente su internet.

Il verso opposto, dalla LAN casa ai peer VPN, passa da deck: `game` e `neve`
importano `o3/modules/system/home-vpn-route.nix`, un dispatcher
NetworkManager che, quando un'interfaccia sale sulla LAN casa, aggiunge la
rotta `10.20.0.0/24` via l'IP LAN di deck. Su altre reti non aggiunge nulla;
`deck` non la importa, perché è lui il gateway. Il NAT di deck maschera solo il
traffico che entra dal tunnel: le risposte dalla LAN tornano nel tunnel perché
`AllowedIPs` di `norvegia` include la LAN casa, e funziona solo mentre il suo
tunnel casa è attivo, ad avvio manuale. La LAN ufficio non passa da qui: la
raggiunge solo deck (`network-architecture`).

## Configurazione NixOS

Il server VPN casa usa `o3/modules/system/services/wireguard.nix` su `deck`,
con interfaccia `casa` (assegnata in `o3/hosts/deck/default.nix`).
Il client di `norvegia`, ad avvio manuale, è dichiarato nel repo
`example-org/nixos-ufficio`: qui c'è solo il suo peer.

In `o3/hosts/deck/default.nix`:

```nix
services.wireguardServer = {
  enable = true;
  interfaceName = "casa";
  vpnSubnet = "10.20.0.1/24";
  externalInterface = "home0";
  privateKeyFile = "/etc/wireguard/casa-vpn.key";
  lanSubnets = ["192.168.0.0/24"];
  protectedTcpPorts = [22];
  peers = [
    { publicKey = "..."; allowedIPs = ["10.20.0.3/32"]; }  # telefono
    { publicKey = "..."; allowedIPs = ["10.20.0.5/32"]; }  # norvegia
  ];
};
```

Il modulo gestisce automaticamente: interfaccia WireGuard, NAT masquerade, IP
forwarding, apertura porta UDP, restrizione porte protette a VPN+LAN.

## Template Config Client

```ini
[Interface]
PrivateKey = <chiave_privata_client>
Address = 10.20.0.X/32

[Peer]
PublicKey = <pubkey_deck>
Endpoint = home.example.com:51820
AllowedIPs = 10.20.0.0/24, 192.168.0.0/24
PersistentKeepalive = 25
```

## DNS dinamico dell'endpoint

L'endpoint deve essere un hostname aggiornato dal servizio DynDNS, per esempio
`home.example.com:51820` se quel nome segue l'IP pubblico di casa.
WireGuard però risolve l'hostname quando imposta il peer e poi conserva l'IP
numerico: se l'IP di casa cambia, il tunnel può restare puntato all'indirizzo
vecchio fino al restart.

Su un client NixOS la prevenzione è `dynamicEndpointRefreshSeconds` sul
peer, che riesegue periodicamente la risoluzione DNS senza riavviare il
tunnel; lo usa il client di `norvegia`, nel repo `example-org/nixos-ufficio`.
Su un telefono basta spegnere e riaccendere il tunnel.

## Gestione

```bash
# Stato servizio (deck)
systemctl status wireguard-casa
sudo wg show casa

# Start/stop: deck parte al boot
sudo systemctl start wireguard-casa
sudo systemctl stop wireguard-casa
```

## Generazione chiavi

Per reinstallare, ripristinare prima l'identità esistente secondo
`secrets-management`. Generare una chiave nuova solo per un nuovo peer o una
rotazione deliberata; aggiornare poi le public key nei consumer del file
identity pertinente. Gli esempi rifiutano di sovrascrivere file esistenti e
impostano i permessi restrittivi prima della scrittura.

```bash
# Nuova identità server su deck
sudo install -d -o root -g root -m 700 /etc/wireguard
sudo sh -c 'set -euC; umask 077
wg genkey > /etc/wireguard/casa-vpn.key
wg pubkey < /etc/wireguard/casa-vpn.key > /etc/wireguard/casa-vpn.pub'

# Nuova identità client, in una subshell Bash
( set -euC; umask 077
  wg genkey > ~/wg-client.key
  wg pubkey < ~/wg-client.key > ~/wg-client.pub
)
```

Conservare il seed privato fuori da Git e verificare soltanto la public key.
Gestione e path runtime del client di `norvegia` sono nel repo
`example-org/nixos-ufficio`.

## Troubleshooting

### Nessun client esterno raggiunge deck (0 B received, nessun handshake)

Sintomo: sul client (il telefono o `norvegia`) il peer di
deck con `endpoint` corretto (IP pubblico attuale, DNS non stale) ma
`0 B received` e nessuna riga `latest handshake` anche dopo diversi
`persistent keepalive`. Su deck, `sudo wg show casa` conferma il sospetto:
chiave server corretta, firewall (`iptables -L nixos-fw`) apre la porta UDP,
socket in ascolto (`ss -uln`) — eppure nessun peer mostra mai una riga
`transfer`, quindi nessun peer ha uno scambio autenticato visibile. Questo non prova
che nessun pacchetto UDP arrivi: verificare indirizzo, profilo attivo, regole
e, se necessario, una cattura di rete prima di localizzare il guasto.

Nel caso già osservato la causa era il profilo di rete: deck deve stare sull'IP LAN statico `192.168.0.10` (profilo
NetworkManager `home0-static`, `o3/hosts/deck/default.nix`), a cui punta
il port-forward UDP 51820 del router di casa. Se NetworkManager, in una race
all'avvio, attiva invece un profilo generico auto-creato ("Wired connection
N" / "Connessione via cavo N") per lo stesso dongle USB-C, deck finisce con
un IP DHCP diverso (es. `192.168.0.22`) e il port-forward del router smette
di raggiungerlo — la VPN casa risulta down per tutti i client esterni
contemporaneamente.

Verifica:

```bash
ip -4 addr show | grep home0        # IP attuale != 192.168.0.10 → sintomo confermato
nmcli device show home0 | grep GENERAL.CONNECTION   # profilo attivo != home0-static
```

Rimedio immediato:

```bash
sudo nmcli connection up home0-static
```

Prevenzione (già in config): `networking.networkmanager.settings.main.no-auto-default = "*"`
in `o3/hosts/deck/default.nix` impedisce a NetworkManager di creare profili
generici automatici per i dispositivi wired, eliminando la race che faceva
vincere il profilo sbagliato.

### IP di deck duplicato tra cavo e Wi‑Fi (caso del 2026-10-15)

Sintomo: da un client esterno il tunnel `casa` risulta attivo, il traffico verso
deck esce dall'interfaccia giusta e l'endpoint risolve all'IP pubblico
attuale, ma né `10.20.0.1` né `192.168.0.10` rispondono. Su deck l'IP
`192.168.0.10` è quello giusto, e il riavvio di deck "risolve".

Causa: il profilo Wi‑Fi imperativo `Wind3 HUB - ED30C4`
(`/etc/NetworkManager/system-connections/`, fuori dal repo) era in
`ipv4.method manual` con lo stesso `192.168.0.10/24` di `home0-static` e
autoconnect attivo. Con entrambe le interfacce su, il router associa l'IP ora
a un MAC ora all'altro, e il port-forward UDP 51820 segue l'associazione.
Il journal di NetworkManager lo dichiara:

```text
device (home0): IP address 192.168.0.10 cannot be configured because it is
already in use in the network by host 44:A3:BB:9F:28:6A
```

dove `44:A3:BB:9F:28:6A` è il MAC di `wlp0s20f3`, il Wi‑Fi di deck stesso
(il 2026-10-14 dalle 14:51 alle 21:36, 459 avvisi). Il riavvio rimescola
soltanto quale interfaccia vince: non è un rimedio. La VPN ufficio
(`wireguard-lavoro`) non c'entra.

Verifica:

```bash
ip -4 -br addr                       # 192.168.0.10 su più di un'interfaccia
journalctl -b -u NetworkManager | grep "already in use"
nmcli -f NAME,TYPE,AUTOCONNECT connection show
```

Rimedio, applicato il 2026-10-15 da remoto senza perdere la sessione. Il
Wi‑Fi resta come riserva della rete cablata, in DHCP e con metrica più alta
del cavo; la VPN casa resta sul cavo, perché il port-forward punta a
`192.168.0.10`. Il cambio di profilo può far cadere per poco una sessione che
passa dal tunnel (il router riassocia l'IP al cavo): da remoto lanciarlo con
`systemd-run`, così arriva in fondo anche se la sessione salta. Sotto
`systemd-run` il PATH è ridotto e `nmcli` va chiamato col percorso completo
(senza, l'unità esce con 127, `nmcli: comando non trovato`):

```bash
sudo systemd-run --unit=wifi-dhcp --collect sh -c '
  N=/run/current-system/sw/bin/nmcli
  $N connection modify "Wind3 HUB - ED30C4" \
    ipv4.method auto ipv4.addresses "" ipv4.gateway "" \
    ipv4.route-metric 600 connection.autoconnect-priority -10 &&
  $N connection up "Wind3 HUB - ED30C4"'
# residui di prima di no-auto-default, causa del caso precedente
sudo nmcli connection delete "Connessione via cavo 1" \
  "Connessione via cavo 2" "Connessione via cavo 3"
```

Esito atteso: `ip -4 -br addr` mostra `192.168.0.10` solo su `home0`, il
Wi‑Fi con un indirizzo DHCP, e il journal non riporta più `already in use`.

Il profilo Wi‑Fi resta imperativo: dichiararlo in `ensureProfiles` richiederebbe
di gestire la password come segreto (`environmentFiles`), un costo non
giustificato da una riserva.

Connessioni:

- [network-architecture](network-architecture.md)
- [secrets-management](secrets-management.md)
