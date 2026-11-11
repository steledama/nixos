# World

Il Mondo runtime di `nixos` è il sistema in esecuzione: i tre host della
rete casa, i dischi e i servizi attivi su cui la configurazione dichiarativa
agisce.

- **deck** — laptop + server, rete casa
- **neve** — desktop, rete casa
- **game** — gaming + workstation GPU, rete casa

Il Mondo di sviluppo è l'artefatto stesso: KB, strumenti e viste.

## Superfici della membrana

Register del polo World, gemello di [`goal.md`](goal.md): il goal è il nord,
il world è il territorio. Forma e contratto (l'intro è il polo che la home
rende) in [world](method/world.md).

- `world -> /run/current-system` — symlink host-local gitignorato verso la
  closure NixOS attiva sull'host corrente: espone il sistema che gira senza
  versionare il runtime. Materializzazione facoltativa.
- Gli altri host si raggiungono via SSH (matrice in
  [ssh-matrix](kb/ssh-matrix.md)): stesso Mondo runtime, nessuna superficie
  locale dedicata.
- `i1/` nasce col solo indice e si popola solo quando una cattura reale
  richiede precisione o durata.

## Fonti

Le fonti grezze restano principalmente il sistema in esecuzione, ma la skill
`/manutenzione` (cfr. `.claude/skills/manutenzione/SKILL.md`) confronta quel sistema
con fonti-mondo esterne autorevoli — superano il test «avrebbero ancora
significato senza questo artefatto?» (`method/world.md`): esistono e contano a
prescindere da `nixos`. Divergenza dal canone chiusa.

- **nixpkgs-unstable** — `github:NixOS/nixpkgs`, branch `nixos-unstable`.
  Fonte del confronto versioni per i rami `ia`/`casa` (flake input
  `ai`/`nixpkgs`, stesso branch, cadenze di aggiornamento diverse). Non regge un nodo KB: regge il giudizio "cosa c'è di più
  recente" della skill.
- **changelog/release-notes upstream** — pagine non versionate consultate
  on-demand per il giudizio di rischio di un delta specifico (kernel.org,
  chromereleases.googleblog.com, docs.docker.com/engine/release-notes e le
  altre radici elencate in `.claude/skills/manutenzione/SKILL.md`). Non hanno
  un'edizione fissa da versionare: cambiano a ogni release, la skill le
  consulta al momento del giudizio.

- **Google Cloud Console personale** — fonte per identità del progetto,
  ruoli IAM, client OAuth e stato del consenso usati da `gog` e rclone.
  Progetto di riferimento: `autonomous-tube-485017-e4`, numero
  `371243294687`; il display name riportato nel setup è `my-project-99364`.
  Verificare i valori e i permessi nella console prima di operare; il JSON
  locale non certifica lo stato IAM. Nodo di setup: `google-workspace-cli`.

## Host e ruoli

Tre client con responsabilità distinte, `deck`, `neve` e `game`, che
condividono rete, sync e tooling ma non sono equivalenti tra loro.

- **deck** — laptop + server casa
  - Fonte di verità: `o3/hosts/deck/default.nix`
  - Caratteristiche distintive: WireGuard casa, client di una VPN esterna, aMule, presentazioni permanenti di `method`, `nixos`, `salute`, `economia` (8001-8004)
- **neve** — desktop casa
  - Fonte di verità: `o3/hosts/neve/default.nix`
  - Caratteristiche distintive: scanner, fancontrol, audio/display workflow
- **game** — gaming PC + workstation GPU
  - Fonte di verità: `o3/hosts/game/default.nix`
  - Caratteristiche distintive: NVIDIA, gaming, OpenRGB, llama.cpp, whisper-cpp, dual boot Windows (default via systemd-boot — entry `windows_windows.conf`, cfr. hardware-inventory § Dual boot Windows)

La baseline di sistema comune ai tre host vive in `o3/hosts/default.nix`:
porta anche le policy desktop — stack Niri, GUI apps e toggle
rete/firewall/user lingering — mentre i fatti per-host (hardware, utente e
gruppi, porte aperte, `system.stateVersion`) restano nei file host. Il catalogo
degli output NixOS e Home Manager vive in `flake.nix`.

L'**identità** dell'infrastruttura — IP, chiavi pubbliche, email, endpoint
VPN — è isolata dalla configurazione strutturale nei file-dati
`~/.config/nixos/identity/home.nix` e `~/.config/nixos/identity/work.nix` (locali, fuori da Git; template pubblici in `o3/identity/`); il secondo porta solo la VPN esterna di `deck`.
`flake.nix` li passa come `specialArgs.identity` /
`extraSpecialArgs.identity`; ogni consumer legge `identity.home.*` o
`identity.work.*`. Approfondimento: nodo secrets-management.

## Profili home-manager

- **`stele@deck`** — `o3/home/stele/deck.nix`
  - dev tools, SSH, rclone, Syncthing, Niri
- **`stele@neve`** — `o3/home/stele/neve.nix`
  - dev tools, SSH, rclone, Syncthing, Niri, audio/display
- **`stele@game`** — `o3/home/stele/game.nix`
  - dev tools, SSH, rclone, Syncthing, Niri

La baseline home comune vive in `o3/home/default.nix`; i moduli riutilizzabili
vivono in `o3/modules/home/`.

## Macro-aree del sistema

- **rete e accesso**
  - Fonte di verità tecnica: host configs, moduli WireGuard, moduli SSH home
  - Nodi KB: network-architecture, wireguard-home, home-lan-addresses, ssh-matrix
- **sync e mount**
  - Fonte di verità tecnica: `o3/modules/home/syncthing-home-mesh.nix`, `o3/modules/home/rclone.nix`
  - Nodi KB: syncthing-architecture, rclone-gdrive
- **client desktop**
  - Fonte di verità tecnica: `o3/hosts/default.nix`, file host, `o3/modules/system/niri.nix`, moduli home condivisi
  - Nodi KB: client-desktop-architecture
- **configurazione di base**
  - Fonte di verità tecnica: `flake.nix`, `o3/hosts/default.nix`, `o3/home/default.nix`
  - Nodi KB: nix-flakes, home-manager, nixos-rebuild
- **identità dell'infrastruttura**
  - Fonte di verità tecnica: `~/.config/nixos/identity/work.nix`, `~/.config/nixos/identity/home.nix` (template `*.example.nix`)
  - Nodi KB: secrets-management
- **estensione del sistema**
  - Fonte di verità tecnica: `o3/hosts/`, `o3/home/`, `o3/modules/`
  - Nodi KB: configuration-patterns, project-extension, design-principles
- **tooling di sviluppo**
  - Fonte di verità tecnica: `o3/modules/home/dev-tools.nix`, `o3/modules/home/shell.nix`
  - Nodi KB: development-environment, development-workflow
- **hardware e host fisici**
  - Fonte di verità tecnica: `o3/hosts/*/hardware.nix`, moduli hardware
  - Nodi KB: hardware-inventory, unfree-packages

## Come leggere il codice

Il repository si legge dall'esterno verso l'interno:

1. `flake.nix` dice quali host e quali profili esistono.
2. `o3/hosts/<host>/default.nix` dice cosa rende diverso ogni host.
3. `o3/hosts/default.nix` contiene la baseline sistema comune.
4. `o3/home/<user>/<host>.nix` dice cosa rende diverso ogni profilo utente.
5. `o3/home/default.nix` contiene la baseline home condivisa.
6. `o3/modules/system/` e `o3/modules/home/` contengono le unità riutilizzabili che
   realizzano le policy.

Quando una policy è trasversale, la fonte di verità deve stare nel modulo
riutilizzabile, non nei file host; quella condivisa da più host ma non da
tutti si importa dai file host che la usano.

## Frontiere ancora aperte

Resta una frontiera reale da osservare: il ruolo di `game` come workstation GPU
e nodo di AI locale. Due capability hanno già guadagnato un nodo proprio —
LLM/OCR locale e trascrizione whisper — entrambe servite dallo stesso profilo
CUDA dell'host, con `whisper-cpp` su un pin dedicato. Quello che ancora non esiste è una **macro-area**: `game` non
compare in § Macro-aree del sistema con una fonte di verità tecnica propria, e
le sue capability restano appese al modello dei client desktop.

La frontiera si chiude quando la GPU smette di essere un attributo di un client
e diventa un sottosistema: più servizi accelerati con dipendenze reciproche,
oppure consumatori su altri host che ne facciano un'infrastruttura condivisa.
Fino ad allora la soglia del singolo nodo architetturale resta valutata in
[client-desktop-architecture](kb/client-desktop-architecture.md), che possiede
l'aggregazione; qui si osserva soltanto la soglia della macro-area.
