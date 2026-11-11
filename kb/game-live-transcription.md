---
stato: maturo
---

# Game transcription capability

Capability host-specifica di `game` per trascrizione audio locale con
`whisper-cpp` accelerato da CUDA. Il workflow operativo di dominio per
registrazioni, telefonate, allegati Gmail e gestione dei file conservati vive in
`~/economia/kb/trascrizione-audio.md`; questo nodo documenta solo ciò che
appartiene alla configurazione NixOS e all'hardware di `game`.

## Contesto

`game` ha `whisper-cpp` installato a livello sistema con supporto CUDA su RTX 4070. Il supporto CUDA è attivato da `o3/modules/system/hardware/nvidia.nix`; il
pacchetto `whisper-cpp` è dichiarato in `o3/hosts/game/default.nix`.

Il modello locale usato per la trascrizione è:

```text
~/.local/share/whisper/ggml-large-v3.bin
```

Il file pesa 3,1 GB, SHA1 `ad82bf6a9043ceed055076d0fd39f5f186ff8062`,
scaricato il 2026-11-02 dal catalogo ufficiale di whisper.cpp. Ha sostituito
`ggml-small.bin` il 2026-11-02: sulla stessa telefonata `small` sbagliava punti
che cambiavano il senso (confronto della sessione economia), mentre con CUDA
`large-v3` trascrive sei minuti di audio in circa 20 secondi, caricamento
compreso. Su `game` `small` non c'è più; resta sui client senza GPU come
`deck`, per la via di riserva su CPU del runbook di economia.

Il modello non dipende dai mount Google Drive e non viene installato dal flake.
Il pacchetto CUDA proviene dall'import isolato `nixpkgs-whisper` in `flake.nix`;
il modulo NVIDIA governa driver e CUDA dei pacchetti del pin principale.

## Ripristinare il modello locale

Prima di reinstallare, conservare una copia del modello già collaudato e il
suo SHA-256 su un supporto indipendente. Nella directory della copia:

```bash
sha256sum ggml-large-v3.bin > ggml-large-v3.bin.sha256
```

Sul sistema ripristinato, montare quel supporto, sostituire il percorso e
verificare il checksum prima di installare il file come `stele`:

```bash
cd /percorso/backup-whisper
sha256sum --check ggml-large-v3.bin.sha256 &&
  install -D -m 644 ggml-large-v3.bin ~/.local/share/whisper/ggml-large-v3.bin
cmp ggml-large-v3.bin ~/.local/share/whisper/ggml-large-v3.bin
```

Il checksum deve provenire dalla copia collaudata, non essere rigenerato sul
file da verificare. Se manca il backup, procurare il modello multilingue
`large-v3` dalla distribuzione ufficiale di whisper.cpp, verificare provenienza
e checksum (SHA1 sopra) e collaudarlo prima dell'uso. Non sostituirlo
implicitamente con un modello diverso. Il test microfono sotto verifica anche che
il modello venga caricato correttamente.

## Confine con economia

Il repo `~/economia` è la fonte per:

- recupero allegati audio con `gog`;
- conversione audio con `ffmpeg`;
- trascrizione di registrazioni conservate in `data/`;
- convenzioni su dove salvare audio e trascrizioni;
- scelta del modello operativo per telefonate reali.

Il repo `~/nixos` è la fonte per:

- installazione system-level di `whisper-cpp`;
- supporto CUDA/NVIDIA;
- disponibilità del modello locale fuori da Drive;
- sorgenti audio testate su `game`;
- comandi di verifica hardware/runtime.

## Uso live locale

Per una call audio, `game` può essere usato come stazione affiancata per:

- trascrizione in tempo reale visibile a schermo;
- registrazione audio integrale come backup WAV;
- eventuale ritrascrizione offline del backup a fine call.

Il caso d'uso verificato è tablet Android con Teams in vivavoce e `game`
affiancato con microfono USB Blue Snowflake. Se audio e trascrizione devono
entrare nel dominio economia, seguire le convenzioni di
`~/economia/kb/trascrizione-audio.md`.

## Microfono

Per verificare le sorgenti disponibili:

```bash
pw-cli list-objects | grep -A3 "node.name" | grep -iE "usb|input|micro"
```

Dispositivi osservati su `game` durante il collaudo iniziale:

- `alsa_input.usb-Blue_Blue_Snowflake-00.mono-fallback` - Blue Snowflake USB
- `alsa_input.usb-Logitech_G533_Gaming_Headset-00.mono-fallback` - G533 headset

Test rapido registrazione e trascrizione, 10 secondi a 16 kHz:

```bash
pw-record --target=alsa_input.usb-Blue_Blue_Snowflake-00.mono-fallback \
  --rate=16000 --channels=1 --format=s16 \
  --sample-count=160000 /tmp/test-mic.wav

whisper-cli -m ~/.local/share/whisper/ggml-large-v3.bin \
  -l it -otxt -of /tmp/test-mic /tmp/test-mic.wav

cat /tmp/test-mic.txt
```

`pw-record` usa `--sample-count`, non `--duration`. Per N secondi a 16 kHz:
`N * 16000` campioni.

## Streaming live

Prima della call individuare l’indice SDL. Nella versione di riferimento
whisper.cpp 1.8.7, `whisper-stream` stampa all’avvio l’elenco
`Capture device #N` prima di aprire la sorgente. Eseguire una breve sessione
di prova, senza `--capture`, e interromperla con `Ctrl+C` dopo aver annotato
l’indice del Blue Snowflake:

```bash
whisper-stream -m ~/.local/share/whisper/ggml-large-v3.bin -l it
```

La prova può aprire il microfono predefinito e iniziare la trascrizione: farla
prima della call. Non usare l’ID numerico PipeWire né il successivo `SDL Id`,
che identificano oggetti diversi. Se il binario installato non stampa l’elenco,
verificare il suo `--help` e la versione prima di proseguire; non inventare un
indice. Questo comportamento è riscontrato nel sorgente upstream, mentre
l’elenco dei dispositivi va osservato ogni volta su game.

Terminale 1, trascrizione live:

```bash
whisper-stream -m ~/.local/share/whisper/ggml-large-v3.bin \
  -l it --step 3000 --length 10000 --capture <indice-blue-snowflake>
```

L'indice passato a `--capture` non è un'identità stabile: può cambiare dopo boot,
aggiornamenti o modifiche alle periferiche. Prima della sessione esegui la
discovery delle sorgenti e sostituisci il segnaposto con l'indice osservato.
Senza una selezione esplicita, il default SDL può puntare alla scheda audio
onboard invece che al microfono USB.

Terminale 2, backup audio integrale:

```bash
audio-rec
```

Su `stele@game`, Home Manager installa `audio-rec` e l'abbreviazione fish
`arec`. Senza argomenti registra dal Blue Snowflake USB in `~/audio-rec.wav`;
per scegliere un altro file:

```bash
audio-rec /tmp/call-backup-$(date +%Y%m%d-%H%M).wav
```

Interrompere la registrazione con `Ctrl+C` a fine call.

Trascrizione rapida del backup predefinito:

```bash
audio-txt
```

Su `stele@game`, Home Manager installa anche l'abbreviazione fish `atxt`.
Senza argomenti trascrive `~/audio-rec.wav` in `~/audio-rec.txt`; con argomenti:

```bash
audio-txt ~/audio-rec.wav ~/audio-rec.txt
```

## Fallback a chunk

Se `whisper-stream` non funziona, usare chunk successivi da Bash. La latenza
comprende 30 secondi di cattura più l'inferenza. Questa versione attende il
risultato prima di leggerlo e lascia una pausa fra le catture durante la
trascrizione: tenere in un altro terminale `audio-rec` come backup continuo.

```bash
chunk_dir=$(mktemp -d /tmp/call-chunks.XXXXXX)
printf 'Chunk e testi: %s\n' "$chunk_dir"
i=0
while true; do
  chunk="$chunk_dir/c$(printf '%06d' "$i").wav"
  out="$chunk_dir/t$(printf '%06d' "$i")"
  pw-record --target=alsa_input.usb-Blue_Blue_Snowflake-00.mono-fallback \
    --rate=16000 --channels=1 --format=s16 \
    --sample-count=480000 "$chunk" || break
  whisper-cli -m ~/.local/share/whisper/ggml-large-v3.bin \
    -l it -otxt -of "$out" "$chunk" || break
  cat "${out}.txt" || break
  i=$((i+1))
done
```

Interrompere con `Ctrl+C`; i chunk restano nella directory stampata. Per la
trascrizione completa usare il WAV continuo prodotto da `audio-rec`: unire i
chunk non ricostruisce l'audio perso nelle pause.

## Trascrizione post-call

La trascrizione live di `whisper-stream` non viene salvata su file. Per ottenere
un testo permanente con timestamp, trascrivere il backup WAV a fine call:

```bash
whisper-cli -m ~/.local/share/whisper/ggml-large-v3.bin \
  -l it -otxt -osrt -of /tmp/trascrizione-$(date +%Y%m%d-%H%M) \
  ~/audio-rec.wav
```

Il file `.txt` contiene testo semplice; il `.srt` contiene i timestamp dei
segmenti. Sostituire `~/audio-rec.wav` con il file esatto se la registrazione
usa un altro percorso, evitando glob che possano selezionare più call.

## Piano di fallback

Se `whisper-stream` o CUDA non sono disponibili durante la call, registrare
comunque il backup WAV. La trascrizione si può eseguire offline dopo la call;
`-ng` forza la CPU se CUDA è il componente indisponibile. Con `large-v3` su CPU
la trascrizione è molto più lenta che su GPU:

```bash
whisper-cli -m ~/.local/share/whisper/ggml-large-v3.bin \
  -ng -l it -otxt -osrt -of /tmp/trascrizione ~/audio-rec.wav
```

## Note operative

- Con CUDA su RTX 4070 e `small`, l'encode di 10 secondi di audio è stato
  osservato in circa 70 ms e il caricamento del modello a caldo in circa
  450 ms. Con `large-v3`, 6 minuti di telefonata in circa 20 secondi, caricamento
  compreso (2026-11-02). `whisper-stream` con `large-v3` non è ancora
  collaudato in una call dal vivo.
- Posizionare il microfono tra il tablet in vivavoce e il parlante, in modo da
  catturare entrambe le voci nella stessa traccia.
- La configurazione è locale a `game`; non richiede servizi di rete o cloud.

Connessioni:

- [client-desktop-architecture](client-desktop-architecture.md)
- [development-environment](development-environment.md)
- [hardware-inventory](hardware-inventory.md)
- [nix-flakes](nix-flakes.md)
- [post-installation](post-installation.md)
- [Whisper SDL capture discovery](https://github.com/ggml-org/whisper.cpp/blob/v1.8.7/examples/common-sdl.cpp)
- [Whisper CLI output formats](https://github.com/ggml-org/whisper.cpp/blob/v1.8.7/examples/cli/cli.cpp)
