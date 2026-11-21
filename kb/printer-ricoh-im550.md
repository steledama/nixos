---
stato: maturo
---

# Ricoh IM 550 printer

La multifunzione Ricoh IM 550 della LAN casa, all'indirizzo statico
`192.168.0.15`: stampa via CUPS dai tre host e da Windows su `game`, e
scansione verso `deck` via FTP, con i file che Syncthing porta sugli altri
host. Indirizzo e piano della LAN sono in `home-lan-addresses`.

## Stampa e servizi

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
- **Web Image Monitor** — `http://192.168.0.15/`, con l'account
  amministratore della multifunzione; le sue credenziali non si registrano
  nel repo.
- **Firmware** — aggiornato il 2026-10-16 dal pannello (RICOH Application
  Site): Sistema 9.02, NIB 19.00, Web Image Monitor 8.03, PDF Emulation 1.18.
- **Scan-to-FTP verso `deck`** — `o3/modules/system/services/scan-ftp.nix`:
  login `scansioni` senza shell, rimappato da vsftpd su `stele`; i file
  arrivano in `~/sync/scansioni` e Syncthing li porta su `neve` e `game`.
  Porta 21 e porte passive 50000-50009 aperte solo da `.15` su `home0`.

## Configurare lo scan-to-FTP

Dopo il rebuild di `deck`, una volta sola: `sudo passwd scansioni`. Poi da
Web Image Monitor (`http://192.168.0.15/`, account amministratore) in **Gestione
dispositivo → Gestione rubrica → Aggiungi utente**: nome a piacere (es.
«deck»), scheda **Cartella**, protocollo **FTP**, server `192.168.0.10`,
porta `21`, percorso vuoto (la radice FTP è già la cartella), utente
`scansioni` con la password appena impostata; **Test connessione** prima di
salvare. Sul pannello si sceglie la voce in **Scanner → Cartella**. I nomi
esatti delle voci dipendono dal firmware. Diagnosi lato `deck`:
`journalctl -u vsftpd` e `journalctl -t vsftpd`.

## Impostare l'indirizzo sul dispositivo

Per una stampante Ricoh l'indirizzo si imposta da Web Image Monitor
(`http://<ip attuale>/`, login amministratore) in **Gestione dispositivo →
Configurazione → Interfaccia → Impostazioni interfaccia**, oppure dal
pannello (**Impostazioni**, poi la voce rete/interfaccia e **Indirizzo IPv4
macchina**; i nomi esatti dipendono dal firmware), scegliendo l'assegnazione manuale al posto di DHCP.

Connessioni:

- [home-lan-addresses](home-lan-addresses.md)
- [network-architecture](network-architecture.md)
- [secret-inventory](secret-inventory.md)
- [syncthing-architecture](syncthing-architecture.md)
