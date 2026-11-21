---
stato: iniziale
---

# Indirizzi della rete casa

Registro degli indirizzi IPv4 della LAN casa `192.168.0.0/24`: piano di
assegnazione, dispositivi censiti, router e procedura per assegnare un
indirizzo statico. Sostituisce il foglio di calcolo `ipStatici` su Google
Drive, trascritto il 2026-10-16 e incrociato con una scansione da `neve` lo
stesso giorno. Speculare al piano della LAN ufficio, nel repo
`example-org/nixos-ufficio`. Stampabile con
`md2pdf kb/home-lan-addresses.md`.

Il router è la fonte di verità per DHCP e port forwarding: il flake non li
applica. Gli indirizzi che il flake consuma vivono in
`~/.config/nixos/identity/home.nix` (`lan.hosts`, `printers`); questo nodo registra
anche quelli che il flake non vede.

## Router Wind Tre

- **Indirizzo LAN** — `192.168.0.1`, apparato ZTE
- **DNS dinamico** — `home.example.com` tramite dyndns.it: è
  l'endpoint pubblico della VPN casa (`wireguard-home`)
- **Server DHCP** — menu **Network → Rete locale LAN → Configurazione LAN**;
  la sottovoce **Indirizzi IP dei dispositivi client** elenca i lease
- **Port forwarding** — elenco in `network-architecture § Port Forwarding
Router Casa`

### Range DHCP

Letto sul pannello il 2026-10-16:

- **Range** — da `192.168.0.21` a `192.168.0.254`
- **Lease** — 1 giorno
- **Riserva un indirizzo IP per lo stesso dispositivo** — disattivata: il
  router non prenota indirizzi, gli statici si impostano sul dispositivo

## Piano di assegnazione

Gli statici vivono **sotto `.21`**, fuori dal range DHCP: il router non li
assegnerà mai a un altro dispositivo. Lo spazio è stretto, quindi le fasce
sono piccole.

- **`.1`–`.2`** — router e repeater
- **`.3`–`.7`** — liberi
- **`.8`–`.14`** — PC e telefoni
- **`.15`–`.18`** — stampanti e multifunzione
- **`.19`–`.20`** — console e altri dispositivi
- **`.21`–…** — DHCP

## Indirizzi statici

- **`.1`** — router Wind Tre
- **`.2`** — repeater, con MAC casuale
- **`.8`** — `neve`, interfaccia cablata `enp0s31f6`; assente dal foglio
- **`.9`** — `game` in entrambi i sistemi del dual boot: sotto NixOS
  profilo NetworkManager impostato sull'host, non nel flake; sotto Windows
  statico sulla scheda `Ethernet 2` dal 2026-10-16 (prima prendeva un
  indirizzo DHCP, `.21`, e il tunnel SSH verso `.9` cadeva). Stessa scheda
  nei due sistemi (ASUSTek), `enp7s0` sotto NixOS
- **`.10`** — `deck` (CHUWI MiniBook X, nel foglio `minibook`), interfaccia
  cablata `home0`
- **`.11`** — `telefono`, il telefono; in VPN casa è `10.20.0.3`
- **`.15`** — Ricoh IM 550, statico impostato sul
  dispositivo il 2026-10-16 (prima in DHCP su `.30`). Dettagli in § Ricoh
  IM 550
- **`.19`** — PS5

Il foglio riportava anche `telefono` su `.3`, `svezia` su `.4` e
`norvegia` su `.5`, «tramite vpn»: voci superate. Il telefono usa `.11`; i
server non hanno indirizzi sulla LAN casa, stanno sulla LAN ufficio
(repo `example-org/nixos-ufficio`) e da casa li raggiunge solo deck, con la sua VPN
ufficio (`network-architecture`). Le tre posizioni sono libere.

## Dispositivi in DHCP

Lease rilevati il 2026-10-16, quindi possono cambiare.

- **`.22`, `.23`, `.25`, `.26`** — MAC casuali: telefoni o tablet
- **`.35`** — `neve`, secondo indirizzo DHCP sulla stessa scheda accanto
  allo statico `.8`: NetworkManager prende anche un lease
- **`.39`** — `deck`, interfaccia Wi-Fi `wlp0s20f3`. Dalla tabella ARP di un altro host può comparire col
  MAC di `home0`: Linux risponde all'ARP da qualunque interfaccia

## Assegnare un indirizzo statico

1. Scegli un indirizzo libero nella fascia giusta. Verifica che sia libero:
   `ping 192.168.0.<n>`, poi `ip neigh show 192.168.0.<n>` deve dare
   `FAILED` o `INCOMPLETE`. Un dispositivo spento non risponde: in caso di
   dubbio controlla l'elenco client del router.
2. Configura l'indirizzo **sul dispositivo**: maschera `255.255.255.0`,
   gateway e DNS `192.168.0.1`.
3. Verifica dalla LAN con `ping` e col servizio del dispositivo.
4. Se il flake lo consuma, aggiorna `~/.config/nixos/identity/home.nix` e rebuilda gli
   host interessati; poi aggiorna la voce in questo nodo.

Per la multifunzione Ricoh la procedura sul dispositivo è nel nodo
`printer-ricoh-im550`.

## Ricoh IM 550

La multifunzione sta su `.15`. Coda di stampa, scan-to-FTP verso `deck` e
pannello di amministrazione sono nel nodo `printer-ricoh-im550`.

## Rifare il censimento

Da un host casa, senza `sudo`:

```bash
nmap -sn 192.168.0.0/24                 # sveglia la LAN e popola la tabella ARP
ip neigh show dev enp0s31f6 | grep -v -e FAILED -e INCOMPLETE
nmap -Pn --top-ports 200 192.168.0.<n>  # porte aperte, per identificare
```

Il produttore si ricava dal prefisso MAC in `share/nmap/nmap-mac-prefixes`
del pacchetto `nmap`; i MAC col secondo bit del primo byte acceso (`x2`,
`x6`, `xa`, `xe`) sono casuali, tipici dei telefoni.

Connessioni:

- [network-architecture](network-architecture.md)
- [wireguard-home](wireguard-home.md)
- [hardware-inventory](hardware-inventory.md)
- [md2pdf](md2pdf.md)
- [printer-ricoh-im550](printer-ricoh-im550.md)
