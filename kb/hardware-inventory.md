---
stato: maturo
---

# Hardware inventory

Inventario conciso dell'hardware che influenza la configurazione. Modelli,
capacità e workaround sono conoscenza corrente; benchmark puntuali e confronti
con versioni firmware disponibili non vengono conservati qui perché invecchiano
senza cambiare la struttura del sistema.

## neve

- macchina: Gigabyte H170N-WIFI, Mini-ITX;
- CPU: Intel Core i5-6600, 4 core / 4 thread;
- RAM: 16 GiB DDR4-2133 dual channel;
- storage: Samsung 850 EVO M.2 SATA 120 GB per `/`, Crucial MX500 SATA 1 TB su
  `/media/storage`;
- ruolo: desktop, media center e scanner.

Una porta USB del controller xHCI (`usb1-port3`) non completa l'enumerazione e
può bloccare per circa 90 secondi gli altri dispositivi sul controller durante
il boot. Il workaround corrente vive in `o3/hosts/neve/default.nix`: una regola
udev nell'initrd imposta `early_stop=yes` e disabilita la porta; un servizio
runtime ripete la protezione dopo resume. È una mitigazione del difetto fisico,
non una riparazione.

## deck

- macchina: CHUWI MiniBook X;
- CPU: Intel N150, 4 E-core / 4 thread;
- RAM: 12 GiB LPDDR5-4800 saldata;
- storage: AirDisk NVMe 512 GB;
- ruolo: laptop mobile, workstation e gateway VPN casa.

## game

- scheda madre: ASUS ROG STRIX B550-F GAMING;
- CPU: AMD Ryzen 5 5600X, 6 core / 12 thread;
- GPU: NVIDIA GeForce RTX 4070, 12 GB VRAM;
- RAM: 48 GiB DDR4-3600 dual channel (24 GiB per canale), quattro moduli
  single rank: 2×16 GiB Corsair Vengeance RGB Pro SL `CMH32GX4M2D3600C18`
  in A1/B1 e 2×8 GiB Corsair Vengeance RGB Pro `CMW16GX4M2D3600C18` in
  A2/B2, tutti a `Configured Memory Speed: 3600 MT/s` (DOCP). I due kit non
  sono validati insieme dal produttore, ma a 3600 il collaudo è riuscito:
  quattro passate memtest86+ senza errori (voce di systemd-boot,
  2026-10-06), Windows vede 47,9 GB a 3600 e regge una lunga sessione di
  gioco, OpenRGB gestisce l'illuminazione di tutti e quattro i moduli
  (2026-10-08);
- storage: NVMe 1 TB NixOS + NVMe 1 TB Windows;
- ruolo: gaming, CUDA, llama.cpp LLM/OCR e trascrizione.

Dopo reset o aggiornamento UEFI, verificare che la RAM sia ancora configurata a
3600 MT/s su tutti e quattro i moduli:

```bash
sudo dmidecode -t memory | grep -E "Size|Part Number|Configured Memory Speed|Rank|Locator"
```

Espansione a 64 GiB (valutata il 2026-10-10, rimandata): i quattro slot sono
pieni, quindi si sostituisce il kit 2×8 in A2/B2 con un 2×16. Va bene solo un
kit **single rank**, per non mescolare ranghi diversi sullo stesso canale e
non rischiare di perdere i 3600 MT/s. L'ideale è un secondo
`CMH32GX4M2D3600C18`. Il rank si legge dalla `ver X.Y.Z` sull'etichetta
Corsair:

- `X`: produttore dei chip (3 Micron, 4 Samsung, 5 Hynix, 8 Nanya);
- `Y`: densità dei chip (3 = 8 Gbit, quindi dual rank su moduli da 16 GB;
  4 = 16 Gbit, quindi single rank);
- `Z`: revisione del chip.

Scartati per questo motivo `CMK32GX4M2D3600C18` ver 8.35 (Nanya, dual rank) e
`CMW32GX4M2D3600C18` ver 3.31 (Micron, dual rank). Il bisogno concreto oggi è
solo il margine per la prova Strata (`game-local-llm.md`).

Per l'inferenza locale il limite pratico principale è la VRAM.

### Scheda di rete onboard: difetto accettato

La Intel I225-V onboard (`07:00.0`, **rev 02**, driver `igc`, interfaccia
`enp7s0`) va periodicamente in blocco di trasmissione: `NETDEV WATCHDOG:
transmit queue N timed out`, poi `Reset adapter` ogni 30-40 s, con il link che
cade e risale. Nei casi peggiori il flapping blocca lo switch di casa, che si
ripristina spegnendolo e riaccendendolo. Succede a sistema acceso, subito dopo
un avvio a freddo e senza sospensione; sotto Windows, sulla stessa porta, il
custode ha visto problemi minori.

Escluse con prove fra il 2026-10-11 e il 2026-10-25: ASPM (già disattivato),
EEE (off di default in `igc`), firmware (NVM 1.45, l'ultima indicata da ASUS
per la scheda; le immagini Intel generiche sono sconsigliate sulle schede
OEM), offload TSO/GSO (spenti, il blocco è tornato con 144 watchdog in un
boot) e il cambio di kernel. Anche il reload del driver attorno alla
sospensione non lo fermava. La causa più probabile è la revisione hardware:
le I225-V rev 01/02 hanno difetti di stabilità del link corretti dalla rev 03.

Decisione del custode del 2026-10-26: si convive col difetto, senza
mitigazioni nella configurazione (tolte il 2026-10-26) e senza hardware
nuovo, perché `game` è usato soprattutto sotto Windows. Si riapre se la
questione si aggrava: blocchi dello switch frequenti o LAN di casa
compromessa. L'uscita pronta è una scheda di rete PCIe o USB con un chip
diverso da I225/I226, fuori dal driver `igc`, con la porta onboard
disattivata. Misure, se servono:

```bash
journalctl -k -b | grep -c 'NETDEV WATCHDOG'
ethtool -S enp7s0 | grep tx_timeout_count
```

### Dual boot Windows

NixOS e Windows hanno ESP distinte. La voce Windows è dichiarata in
`o3/hosts/game/default.nix`. Il modulo NixOS genera l'id
`windows_windows.conf` per l'attributo `windows."windows"`; il default di
systemd-boot deve usare quell'id esatto.

```bash
bootctl status | grep -i default
```

## Raccolta dati

Usa il report versionato quando serve aggiornare l'inventario:

```bash
o3/scripts/hw-report.sh
```

Per verifiche mirate:

```bash
sudo dmidecode -t system -t baseboard -t processor -t memory
lsblk -o NAME,SIZE,MODEL,TYPE,MOUNTPOINTS
lspci -nn
```

Aggiorna questo nodo soltanto quando cambia un fatto che influenza capacità,
moduli, recovery o decisioni operative. Le misure diagnostiche occasionali
restano nell'output del comando o nella storia Git se motivate da un intervento.

Connessioni:

- [network-architecture](network-architecture.md)
- [unfree-packages](unfree-packages.md)
- [configuration-patterns](configuration-patterns.md)
- [client-desktop-architecture](client-desktop-architecture.md)
