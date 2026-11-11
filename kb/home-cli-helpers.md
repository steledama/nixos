---
stato: maturo
---

# Home CLI helpers

Raccolta dei piccoli wrapper CLI distribuiti via Home Manager che non richiedono
un nodo dedicato ciascuno, ma sono strumenti utente reali e devono restare
scopribili dalla KB.

## Criterio

Questi helper vivono in `o3/modules/home/*.nix`, usano wrapper come
`writeShellScriptBin`, vengono installati in `home.packages` e spesso espongono
anche una voce desktop. Sono user-space: si applicano con `home-manager switch`,
non con `nixos-rebuild`, salvo modifiche al livello system sottostante.

Il controllo `o3/tools/kb_tools.py coverage` segnala i wrapper CLI Home Manager
importati che non sono citati in README o KB. Questo nodo evita che helper
piccoli ma importanti restino invisibili.

## Helper

- **`audio-manager`** — modulo: `o3/modules/home/audio-manager.nix`; profili: `stele@neve`; funzione: cambio uscita HDMI e gestione Bluetooth su neve
- **`audio-rec` / `audio-txt`** — modulo: `o3/modules/home/game-audio-rec.nix`; profili: `stele@game`; funzione: registrazione WAV dal microfono Blue Snowflake USB e trascrizione locale con whisper-cpp
- **`remoto`** — modulo: `o3/modules/home/remoto.nix`; profili: `stele@deck`; funzione: atti fissi dell'agente su `game` e `neve` (stato, switch home); i server li rifiuta; dettaglio in `cicli § Atti remoti`
- **`display-manager`** — modulo: `o3/modules/home/display-manager.nix`; profili: `stele@neve`; funzione: profili monitor 27"/47" su neve via `wlr-randr`
- **`rimonta-drive`** — modulo: `o3/modules/home/rimonta-drive.nix`; profili: `stele@deck`, `stele@neve`, `stele@game`; funzione: stato e restart dei mount rclone Google Drive
- **`steam`** — modulo: `o3/modules/home/steam-pipewire-wrapper.nix`; profili: `stele@game`; funzione: riavvio preventivo PipeWire prima di Steam su game

`md2pdf` è anch'esso un wrapper CLI home-manager, ma ha un nodo dedicato perché
ha una pipeline più ampia con Pandoc, Mermaid e LaTeX.

## audio-manager

`audio-manager` è specifico di `neve`. Mostra un menu interattivo in `foot` per:

- selezionare HDMI 1, schermo 47";
- selezionare HDMI 2, schermo 27";
- connettere dispositivi Bluetooth noti o nuovi;
- disconnettere dispositivi Bluetooth connessi.

Usa `pactl` e `bluetoothctl`; espone anche una desktop entry "Audio Manager".

## audio-rec / audio-txt

`audio-rec` e `audio-txt` sono specifici di `stele@game`. `audio-rec`
incapsula il comando `pw-record` testato per il microfono USB Blue Snowflake e
registra audio mono WAV a 16 kHz. Senza argomenti scrive in `~/audio-rec.wav`;
con un argomento usa il percorso indicato:

```bash
audio-rec
audio-rec /tmp/call-backup-$(date +%Y%m%d-%H%M).wav
```

`audio-txt` trascrive con `whisper-cli`, modello
`~/.local/share/whisper/ggml-large-v3.bin`, lingua italiana. Senza argomenti legge
`~/audio-rec.wav` e scrive `~/audio-rec.txt`; con argomenti accetta input e
output espliciti:

```bash
audio-txt
audio-txt ~/audio-rec.wav ~/audio-rec.txt
```

Fish espone le abbreviazioni `arec` e `atxt`, che espandono rispettivamente a
`audio-rec` e `audio-txt`. Il workflow di trascrizione e backup call vive in
`game-live-transcription`.

## display-manager

`display-manager` è specifico di `neve`. Può essere usato da menu interattivo o
da CLI:

```bash
display-manager dual
display-manager solo27
display-manager solo47
display-manager status
```

Usa `wlr-randr` per gestire il monitor 27" FHD e il 47" 4K. Su `neve`, Niri
avvia `display-manager solo27` allo startup per riportare il desktop al profilo
predefinito.

## rimonta-drive

`rimonta-drive` mostra lo stato dei servizi utente
`rclone-mount-gdrive-<nome>.service` montati dal profilo: l'elenco degli
account si ricava da `services.rcloneMount.mounts`, quindi su ogni host compare
solo ciò che quell'host monta (cfr. `rclone-gdrive § Configurazione attuale per
host`).

Dal menu permette di riavviare un singolo account o tutti i mount. La logica
operativa dei mount resta nei nodi rclone; questo nodo registra solo la
distribuzione e la funzione del wrapper.

## steam

Su `stele@game`, `steam` shadowa il launcher di sistema con un wrapper
Home Manager. Prima del primo avvio del client riavvia i servizi utente
`pipewire.service`, `wireplumber.service` e `pipewire-pulse.service`, poi delega
a `/run/current-system/sw/bin/steam`. Se `steamwebhelper` è già in esecuzione
non tocca PipeWire, così un rilancio del client non interrompe l'audio durante
una sessione già attiva.

Il workaround preserva una catena causale non deducibile dalla configurazione:
il crash è innescato da uno stato corrotto di PipeWire sul path PulseAudio
usato dalla `libaudio.so` bundlata da Steam. La condizione di rimozione vive in
`o1/plan.md`: eliminare il wrapper quando il fix upstream rende superfluo il
riavvio preventivo.

## Manutenzione

Quando si aggiunge un nuovo wrapper CLI in `o3/modules/home/*.nix`:

1. importarlo nel profilo home corretto;
2. verificare se merita un nodo dedicato o una riga in questo nodo;
3. eseguire `python3 o3/tools/kb_tools.py coverage`;
4. applicare con `o3/scripts/con-identita.sh home-manager switch --flake .#user@host`.

Connessioni:

- [home-manager](home-manager.md)
- [client-desktop-architecture](client-desktop-architecture.md)
- [game-live-transcription](game-live-transcription.md)
- [rclone-gdrive](rclone-gdrive.md)
- [rclone-operations](rclone-operations.md)
- [md2pdf](md2pdf.md)
