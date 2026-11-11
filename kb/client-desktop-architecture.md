---
stato: maturo
---

# Client desktop architecture

I tre host di casa, `deck`, `neve` e `game`, sono il territorio di questo
repo. Condividono desktop Niri,
tooling utente, accesso SSH e sincronizzazione dei dati, ma non sono cloni:
ciascuno ha una responsabilità funzionale propria e quindi una configurazione
host-specifica distinta.

La composizione comune è la baseline `o3/hosts/default.nix`: abilita desktop
Niri, app GUI e policy comuni di rete e lingering. I file host mantengono hardware, utenti, indirizzi e servizi
specifici; i profili `o3/home/<user>/<host>.nix` compongono l'ambiente utente.
La distribuzione delle responsabilità è descritta in `configuration-patterns`.

## Ruoli dei client

- **`deck`** — ruolo funzionale: laptop mobile + gateway casa always-on; utilizzo: custode e familiare (utente `stele`, accesso fisico o via SSH da LAN casa); fonti di verità principali: `o3/hosts/deck/default.nix`, `o3/home/stele/deck.nix`; differenze rilevanti: server WireGuard casa, client VPN lavoro, aMule, layout laptop
- **`neve`** — ruolo funzionale: desktop domestico / media center; utilizzo: custode e familiare (utente `stele`); fonti di verità principali: `o3/hosts/neve/default.nix`, `o3/home/stele/neve.nix`; differenze rilevanti: scanner, fancontrol, Bluetooth, audio-manager, display-manager
- **`game`** — ruolo funzionale: gaming PC + workstation GPU; utilizzo: custode e familiare (utente `stele`; i figli usano Windows nel dual boot); fonti di verità principali: `o3/hosts/game/default.nix`, `o3/home/stele/game.nix`; differenze rilevanti: NVIDIA/CUDA, gaming, OpenRGB, Docker NVIDIA, llama.cpp, whisper-cpp

I tre host hanno lo stesso utente `stele`, di custode e familiare: su `game` i
figli usano Windows, e il loro utente `utente-precedente` con i Drive di Luca, Matteo e
Davide è stato tolto (custode, 2026-11-07). familiare usa anche deck, fisicamente
o tramite SSH dalla LAN casa; per questo non serve un peer VPN personale.
`o3/modules/home/ssh-github-familiare.nix` configura l'alias GitHub nei profili
di game e neve; su deck non si lavora sui repo di familiare (custode,
2026-10-11). Il suo Drive è montato sui tre host, su deck come mount privato
invisibile ai cicli autonomi (custode, 2026-11-07). La distribuzione dei mount per account vive in
`rclone-gdrive` e nei profili home.

## Strato condiviso

- **baseline sistema** — `o3/hosts/default.nix`
- **desktop system-level** — `o3/modules/system/niri.nix`, `o3/modules/system/gui-apps.nix`
- **shell e terminale** — `o3/home/default.nix`, `o3/modules/home/shell.nix`
- **tooling sviluppo** — `o3/modules/home/dev-tools.nix`
- **editor e configurazione utente** — `o3/modules/home/helix.nix`, `o3/modules/home/zed.nix`
- **accesso SSH** — `o3/modules/home/ssh-common.nix`, `ssh-home-lan.nix`, `ssh-work-lan.nix`, `ssh-github-familiare.nix` (alias GitHub per il push di familiare da account condiviso)
- **sync casa** — `o3/modules/home/syncthing-home-mesh.nix`, parametrizzato
  dal profilo con `thisHost`
- **Google Drive** — `o3/modules/home/rclone.nix`, `o3/modules/home/rimonta-drive.nix`

Questo strato comune evita duplicazione, ma non cancella le differenze tra host:
la configurazione resta modulare proprio perché le workstation hanno scopi
diversi.

## Differenze host-specifiche

### deck

`deck` è l'unico client che svolge anche una funzione infrastrutturale
domestica. È il server WireGuard della rete casa, mantiene un IP statico e ospita
anche aMule con accesso limitato a LAN/VPN. La configurazione desktop resta
quella dei client, ma il suo ruolo non è riducibile a semplice laptop.

### neve

`neve` concentra periferiche e comfort domestico. Ha scanner dedicato,
controllo ventole, Bluetooth per speaker esterni e due helper utente specifici:
`audio-manager` per cambiare output HDMI / Bluetooth e `display-manager` per
gestire i profili monitor 27"/47". Questi wrapper sono raccolti nel nodo
`home-cli-helpers`. È il client in cui la personalizzazione hardware e UX è più
evidente.

### game

`game` è insieme postazione gaming e workstation GPU. Oltre allo stack desktop
condiviso, importa driver NVIDIA, gaming tools, OpenRGB, Docker con supporto
NVIDIA e il servizio `llama.cpp` multi-modello esposto solo alla LAN/VPN. La
capability OCR condivisa usata da altri repo ha i dettagli infrastrutturali nel
nodo dedicato. `whisper-cpp` con
CUDA è installato a livello sistema; modello
locale, sorgenti audio testate e procedura di streaming vivono nel nodo dedicato
alla trascrizione live. Questa convergenza rende `game` il punto naturale per
carichi locali accelerati da GPU.

## Servizi locali e confine dichiarativo

`game` fornisce il servizio llama.cpp descritto in `game-local-llm`.
Per ComfyUI questo repository dichiara soltanto regole firewall sulla porta
8188: non contiene il servizio né una procedura di installazione. La porta
consentita non prova che ComfyUI sia in esecuzione. Prima di usarlo o
ripristinarlo, identificare sull'host il processo o container, il checkout e
il relativo runbook; non dedurre l'installazione dalle regole di rete.

## Confine con possibili nodi futuri

Il ruolo GPU di `game` è abbastanza chiaro da emergere come sottosistema, ma al
momento resta ben contenuto qui insieme alla mappa generale del progetto. Un
nodo autonomo su AI locale / workstation GPU diventerebbe utile se crescessero:

- più servizi locali accelerati da GPU;
- procedure operative dedicate;
- relazioni con altri host oltre ai tunnel SSH già presenti;
- decisioni architetturali proprie, distinte dal semplice profilo desktop.

Finché il perimetro dichiarativo resta `llama.cpp + CUDA + whisper-cpp`,
questo nodo aggregatore è sufficiente.

Connessioni:

- [network-architecture](network-architecture.md)
- [syncthing-architecture](syncthing-architecture.md)
- [home-manager](home-manager.md)
- [development-environment](development-environment.md)
- [hardware-inventory](hardware-inventory.md)
- [game-live-transcription](game-live-transcription.md)
- [game-local-llm](game-local-llm.md)
- [home-cli-helpers](home-cli-helpers.md)
- [configuration-patterns](configuration-patterns.md)
- [rclone-gdrive](rclone-gdrive.md)
