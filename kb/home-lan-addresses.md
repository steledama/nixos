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

- **Indirizzo LAN** — `192.168.0.1`, MAC `e8:6e:44:ed:30:c4` (ZTE)
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
- **`.2`** — repeater, MAC casuale `32:91:ab:0a:f4:2d`
- **`.8`** — `neve`, interfaccia cablata `enp0s31f6`; assente dal foglio
- **`.9`** — `game` in entrambi i sistemi del dual boot: sotto NixOS
  profilo NetworkManager impostato sull'host, non nel flake; sotto Windows
  statico sulla scheda `Ethernet 2` dal 2026-10-16 (prima prendeva un
  indirizzo DHCP, `.21`, e il tunnel SSH verso `.9` cadeva). Stessa scheda
  nei due sistemi, MAC `24:4b:fe:5a:40:8d` (ASUSTek), `enp7s0` sotto NixOS
- **`.10`** — `deck` (CHUWI MiniBook X, nel foglio `minibook`), interfaccia
  cablata `home0`, MAC `48:65:ee:18:1c:45`
- **`.11`** — `telefono`, il telefono; in VPN casa è `10.20.0.3`
- **`.15`** — Ricoh IM 550, MAC `58:38:79:33:04:e5`, statico impostato sul
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
- **`.39`** — `deck`, interfaccia Wi-Fi `wlp0s20f3`, MAC
  `44:a3:bb:9f:28:6a`. Dalla tabella ARP di un altro host può comparire col
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

Per una stampante Ricoh l'indirizzo si imposta da Web Image Monitor
(`http://<ip attuale>/`, login amministratore) in **Gestione dispositivo →
Configurazione → Interfaccia → Impostazioni interfaccia**, oppure dal
pannello (**Impostazioni**, poi la voce rete/interfaccia e **Indirizzo IPv4
macchina**; i nomi esatti dipendono dal firmware), scegliendo l'assegnazione manuale al posto di DHCP.

## Ricoh IM 550

- **Consumer** — `o3/modules/system/hardware/printer-ricoh-im550.nix` su
  `deck`, `game` e `neve`; ping, 80, 631 e 9100 verificati da `neve`.
- **Coda CUPS** — IPP col PPD `Ricoh-IM_550_PDF`. Col PPD PostScript la
  stampante scarta il lavoro (via 9100 in silenzio, via IPP con
  `document-unprintable-error`), mentre il PDF esce; CUPS converte in PDF
  anche testo, immagini e PostScript in ingresso. Stampa verificata da
  AbiWord e Chromium su `neve`, coda presente su `deck` e `game`.
- **Dopo un rebuild** — CUPS aggiorna la coda solo alla prima richiesta
  (`lpstat`, una stampa): è attivato da socket.
- **Windows su `game`** — coda `RICOH IM 550`, IPP
  `http://192.168.0.15:631/ipp/print` col Microsoft IPP Class Driver, senza
  driver Ricoh; A4 e predefinita, aggiunta con `Add-Printer -IppURL`.
- **Web Image Monitor** — `http://192.168.0.15/`, amministratore `admin`
  senza password: il default di fabbrica, lasciato così per scelta del
  custode (2026-10-16).
- **Firmware** — aggiornato il 2026-10-16 dal pannello (RICOH Application
  Site): Sistema 9.02, NIB 19.00, Web Image Monitor 8.03, PDF Emulation 1.18.
- **Scan-to-FTP verso `deck`** — `o3/modules/system/services/scan-ftp.nix`:
  login `scansioni` senza shell, rimappato da vsftpd su `stele`; i file
  arrivano in `~/sync/scansioni` e Syncthing li porta su `neve` e `game`.
  Porta 21 e porte passive 50000-50009 aperte solo da `.15` su `home0`.

## Scan-to-FTP dalla Ricoh

Dopo il rebuild di `deck`, una volta sola: `sudo passwd scansioni`. Poi da
Web Image Monitor (`http://192.168.0.15/`, login `admin`) in **Gestione
dispositivo → Gestione rubrica → Aggiungi utente**: nome a piacere (es.
«deck»), scheda **Cartella**, protocollo **FTP**, server `192.168.0.10`,
porta `21`, percorso vuoto (la radice FTP è già la cartella), utente
`scansioni` con la password appena impostata; **Test connessione** prima di
salvare. Sul pannello si sceglie la voce in **Scanner → Cartella**. I nomi
esatti delle voci dipendono dal firmware. Diagnosi lato `deck`:
`journalctl -u vsftpd` e `journalctl -t vsftpd`.

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
