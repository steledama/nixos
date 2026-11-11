---
stato: maturo
---

# Game local LLM and OCR capability

Capability host-specifica di `game` per servire modelli locali alla LAN,
inclusa la pipeline OCR usata dal repo `~/economia`. `llama.cpp` è il backend
operativo sulla porta 11434, unico servizio LLM dell'host.

Dal 2026-11-01 il servizio non parte al boot (`autoStart = false`, decisione
del custode: nessun uso richiede che resti sempre acceso, e la GPU da 12 GB
serve anche a Strata e ComfyUI). L'unità resta installata e si avvia a mano
con `sudo systemctl start llama-cpp`, che va lanciato su `game` prima di
usare l'OCR di `~/economia` o il tunnel dai server lavoro (repo
`example-org/nixos-ufficio`). Un
`nixos-rebuild switch` non lo avvia più.

## Confine cross-repo

Il repo `~/economia` è la fonte del workflow OCR di dominio:

- conversione PDF image-based in immagini;
- ridimensionamento immagini;
- chiamata REST al backend OCR configurabile;
- prompt OCR e gestione del testo estratto;
- decisione su quando usare GLM-OCR invece di estrazione PDF tradizionale.

Il repo `~/nixos` è la fonte dell'infrastruttura:

- servizio `llama.cpp` multi-modello;
- pesi GGUF fissati per revisione e SHA-256;
- selezione automatica del pacchetto CUDA su host NVIDIA;
- binding di rete;
- firewall LAN/VPN-only;
- ruolo di `game` come server locale per modelli.

## Configurazione NixOS

La capability è composta da:

- `o3/modules/system/services/llama-cpp.nix` - pesi e preset dichiarativi del
  servizio;
- `o3/hosts/game/default.nix` - attivazione host-specifica;
- `o3/modules/system/hardware/nvidia.nix` - supporto CUDA per RTX 4070.

Il profilo NVIDIA limita `cudaCapabilities` a `8.9`, il target Ada della
RTX 4070, per i pacchetti del pin principale, incluso llama.cpp. Gli import
nixpkgs isolati hanno una configurazione propria: Whisper dichiara CUDA nel
flake e non eredita automaticamente questa restrizione.

`cache.nixos.org` non distribuisce pacchetti CUDA. Il modulo NVIDIA aggiunge
per il solo `game` la cache del team CUDA di NixOS, `cache.nixos-cuda.org`
(URL e chiave dalla wiki `CUDA` e dalla pagina della cache), accanto a
`cache.nixos.org` e `nix-community.cachix.org`; i componenti CUDA di base
erano già serviti da quest'ultima. Al 2026-11-11 la cache CUDA conteneva il
path esatto di `whisper-cpp` 1.9.2 selezionato da game, non quello di
llama.cpp 0.8.0: la causa dell'assenza non è verificata. La presenza di un
path non garantisce i successivi, e una build locale dello stesso path può
avere un NAR diverso da quello in cache. Lo stato di un path si legge con
`o3/scripts/cache-status.sh -v`; la cache è attiva solo dopo il rebuild.

Su `game`:

```nix
services.llamaCppServer = {
  enable = true;
  host = "0.0.0.0";
  port = 11434;
  chatContextSize = 32768;
  ocrContextSize = 8192;
};
```

`openFirewall = false` è intenzionale: l'accesso non viene aperto a tutti. Le
regole in `networking.firewall.extraCommands` permettono la porta `11434` solo
da subnet LAN/VPN:

```text
192.168.0.0/24
172.16.0.0/12
```

## Endpoint

Il custode ha verificato il catalogo `/models` su `game` dopo
l'aggiornamento a llama-cpp 0.8.0 (riscontro dichiarato il 2026-11-11).

Endpoint locale su `game`:

```text
http://localhost:11434
```

Endpoint da altri host LAN:

```text
http://192.168.0.9:11434
```

Il router usa `models-max = 1`: chat e OCR sono caricati su richiesta e non
risiedono insieme in VRAM. Gli alias API stabili sono:

```text
qwen3.8-27b-iq3_xxs
glm-ocr-q8_0
```

Il modulo `o3/modules/system/services/llama-cpp.nix` è la fonte unica di nomi
file, revisioni e hash dei pesi chat, OCR e proiettore multimodale. I file sono
output `fetchurl` del Nix store: nessun download manuale in una directory
persistente dell'host. Gli alias sopra costituiscono invece il contratto
operativo usato dai client e vanno coordinati con i consumatori se cambiano.

Limite del 27B (misura del 2026-10-08): con tutti i layer in GPU e contesto
32768 il picco è 11.254 MiB sui 12.282 della RTX 4070, partendo da 216 MiB
a desktop scarico; restano circa 1 GB. Il preset forza `n-gpu-layers = all`,
quindi llama.cpp non adatta i layer alla VRAM libera: con Chromium aperto
(circa 630 MiB per il suo processo GPU, circa 930 in tutto col desktop) il
modello va in `CUDA error: out of memory` alla prima richiesta e il router
risponde 500. Il 27B si usa poco: va usato a desktop scarico, senza browser
né gioco. GLM-OCR non ha questo problema. Il modello (`qwen35`, attenzione
piena ogni 4 layer) è addestrato a 262144 token: i 32768 sono una scelta del
servizio per stare in VRAM, non un limite del modello. Se il 27B tornasse
d'uso quotidiano, le leve sono un contesto più corto o i layer lasciati al
calcolo di llama.cpp, a costo di velocità.

`cors-origins = "localhost"` sostituisce il default permissivo `*`: i client
non-browser e la UI servita same-origin continuano a funzionare, mentre pagine
web su origini arbitrarie non possono usare il browser per chiamare il servizio.

La porta è indicizzata anche in `network-architecture.md` tra i servizi della
rete casa.

## Accesso dai server lavoro

Legame d'uso dichiarato nel goal del repo `example-org/nixos-ufficio` (2026-11-04):
i profili `sviluppo` dei server aprono un tunnel SSH verso `game` che porta
il loro `127.0.0.1:11434` su `127.0.0.1:11434` di `game`, passando dalla VPN
casa dello standby (`wireguard-home`). Procedura e verifica vivono in quel
repo. Dal 2026-11-08 il custode ha tolto le chiavi dei server da `game` per
tenere minimi gli accessi (`ssh-matrix`), quindi il tunnel non si apre finché
non torna autorizzata una chiave. Se torna, il forward arriva a llama.cpp da
localhost e le regole firewall della porta 11434 non c'entrano.

## Modello OCR

Il workflow OCR di `~/economia` usa per default:

```text
glm-ocr-q8_0
```

Modello e proiettore multimodale sono artefatti dichiarativi nel Nix store. Il
client `o3/ocr.py` di `~/economia` parla il contratto OpenAI-compatible di
`llama-server`.

Verifica modelli disponibili da LAN:

```bash
curl -s http://192.168.0.9:11434/models \
  | python3 -c "import sys,json; [print(m['id']) for m in json.load(sys.stdin)['data']]"
```

Atteso per il workflow OCR:

```text
qwen3.8-27b-iq3_xxs
glm-ocr-q8_0
```

## Uso operativo

Per OCR di PDF image-based usare il workflow nel repo `~/economia`, non comandi
ad hoc nel repo `~/nixos`. Questo evita duplicazione di prompt, soglie di resize,
convenzioni sui file e criteri di quando conservare il testo estratto.

Il ruolo di questo nodo è ricordare che `game` fornisce il servizio condiviso:
se OCR fallisce da `economia`, verificare prima rete, `llama-cpp.service` e
catalogo `/models` su `game`. Il contratto è quello OpenAI
(`/v1/chat/completions` con content block `image_url`), non il `/api/chat` di
Ollama usato prima della migrazione: la costruzione del payload vive nel client
del repo di dominio, non nell'infrastruttura NixOS.

## Strata: prova in area utente

Qwen3.8-Flash-Next (MoE 177B) gira solo su Strata IQ3_XXS low-RAM a
contesto 64K (decisione del custode, 2026-10-07). A decidere è il prefill:
un agente come pi rilegge 30–50K token a ogni passo. Misure su `game` (48
GB, RTX 4070; bench e run in `~/llm-bench`, fuori dal repo), a cache calda:

- Strata IQ3_XXS low-RAM: prefill circa 2000 tok/s, decode circa 50 tok/s,
  48K token letti in 29 s; RAM disponibile circa 3 GB, swap leggero;
- llama.cpp `UD-IQ3_XXS` (`cpu-moe`, esperti in RAM via mmap): prefill circa
  150 tok/s (54 a freddo), decode circa 18 tok/s, circa 5 minuti per la
  stessa lettura, swap continuo. Con 64 GB sparirebbe lo swap, non la
  lentezza del prefill.

Per questo il preset Flash-Next di llama.cpp è stato rimosso dal servizio il
2026-10-08 insieme ai suoi tre frammenti GGUF (circa 77 GB nello store): il
preset, i pin e le misure restano recuperabili da git. llama.cpp resta per
il 27B denso e per GLM-OCR. Strata resta però fuori dal servizio, come prova
in area utente (decisione del custode, 2026-10-08):

- avvio a mano con `~/Strata/run.sh` (porta 18080, solo locale), che ferma
  `llama-cpp.service` se attivo (con sudo); con Strata acceso la GPU è sua,
  quindi niente 27B, GLM-OCR, Whisper o gioco;
- checkout su `main` di upstream, oggi `v0.2.9` (motore 0.1.55),
  compilato con CUDA 13.0 di nixpkgs (GC root `~/Strata/.cuda-env`,
  ambiente in `~/Strata/nixos-env.sh`), pesi, pack ed `experts.bin` in
  `~/Strata-data`; da `v0.1.39` a `v0.2.9` il pack è rimasto
  `FORMAT_VERSION = 1` e `experts.bin` non è stato rigenerato. Misura del
  2026-11-01 dopo l'aggiornamento: 39K token in 19 s (prefill circa 2000
  tok/s), decode circa 55 tok/s, RAM disponibile circa 1 GB;
- nel repo c'è solo la compattazione di pi per il modello
  `strata/qwen3.8-flash-next-iq3_xxs-64k` (`o3/modules/home/pi.nix`); se
  l'id del modello cambia, l'override smette di applicarsi senza errori.

Perché non un pacchetto Nix né un container:

- upstream molto giovane: 46 tag in circa due settimane, più al giorno, e
  il 2026-10-08 un force push ha riscritto storia e tag (`v0.1.39` da
  `6f32ec0` a `a1641e9`, stessi file): un pin per commit può sparire dal
  remoto;
- costo stimato il 2026-10-06: pacchetto Nix 2–4 giorni e 1–3 ore per
  aggiornamento; container mezza giornata o una e circa un'ora per
  aggiornamento, ma senza pin per hash di immagine e pesi;
- il costo ricorrente maggiore non è il packaging ma la GPU esclusiva, da
  coordinare con il router llama.cpp, Whisper, GLM-OCR e il gioco.

L'aggiornamento è diretto, sul posto (decisione del custode, 2026-11-01:
il contesto è sperimentale, senza dati da perdere né utenti del servizio):
fermare llama.cpp, poi `cd ~/Strata && . ./nixos-env.sh && ./update.sh`,
che fa `git pull --ff-only`, ricompila il motore e aggiorna `.venv` e
settings dei modelli senza toccare i pesi. Se un cambio di formato del pack
chiede di rigenerare `experts.bin` (circa 40 GiB), lo si accetta. L'integrazione
torna un task quando valgono insieme tre condizioni: upstream smette di
riscrivere la storia e rallenta i rilasci, Strata diventa il motore d'uso
quotidiano, e la condivisione della GPU è decisa. Un fork o mirror del
repo tiene disponibile il commit in uso, qualunque cosa faccia upstream.

Connessioni:

- [client-desktop-architecture](client-desktop-architecture.md)
- [network-architecture](network-architecture.md)
- [ssh-matrix](ssh-matrix.md)
- [wireguard-home](wireguard-home.md)
- [development-environment](development-environment.md)
- [hardware-inventory](hardware-inventory.md)
