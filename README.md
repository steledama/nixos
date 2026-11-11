# Configurazione NixOS

Configurazione NixOS dei tre host di casa, con flakes e home-manager
standalone. La coppia server di lavoro vive nel repo `example-org/nixos-ufficio`;
verso l'ufficio resta il solo client VPN di `deck`.

[![Nix Flakes](https://img.shields.io/badge/Nix-Flakes-blue.svg?logo=nixos&logoColor=white)](https://nixos.wiki/wiki/Flakes)
[![Hosts](https://img.shields.io/badge/Hosts-3-green.svg)](#)
[![Open Source First](https://img.shields.io/badge/Software-Open%20Source%20First-brightgreen.svg)](#)

Le identità reali restano locali: indirizzi, nomi personali e account
nella configurazione pubblica e negli esempi della documentazione sono
segnaposto. Prima di configurare un host, leggere
[`o3/identity/README.md`](o3/identity/README.md). I comandi di attivazione
usano un input locale esplicito; il flake senza override usa i template.
Il metodo è pubblico e si prepara accanto al checkout con
`git clone https://github.com/steledama/method ../method`, per risolvere il
symlink `method/`. La storia privata precedente resta in un bundle fuori
dal checkout, non in branch o tag del repo pubblico.

## Host

- **deck** — Intel N150, Intel UHD Graphics, Laptop + Server, rete casa
- **neve** — Intel i5-6600, Intel HD Graphics 530, Desktop PC, rete casa
- **game** — AMD Ryzen 5 5600X, NVIDIA GeForce RTX 4070, Gaming PC, rete casa

Architettura di rete: [`kb/network-architecture.md`](kb/network-architecture.md).

## Principi Guida

Zero dead code, DRY, modularità, nessuna configurazione manuale fuori dal repository,
policy unfree esplicita. Dettaglio: [`method/design-principles.md`](method/design-principles.md).

## Metodo

Il cognitive artifact design applicato qui è centralizzato nel repo separato
`~/method`, esposto come dipendenza trans-repo tramite il symlink
`method/ -> ../method/kb`. L'hub d'ingresso è
[`method/cognitive-artifact-design.md`](method/cognitive-artifact-design.md), il
solo nome di nodo assunto stabile. I nodi metodologici non vengono indicizzati in
questo README: sono il metodo portabile, non dominio nixos. I link puntuali sotto
`method/...` restano validi e leggibili grazie al symlink.

I poli del ciclo vivono nei register di root: [`goal.md`](goal.md) (il nord:
i due goal in tensione e i puntatori ai segnali che li misurano, custode
umano) e
[`world.md`](world.md) (il territorio: host, profili, macro-aree e superfici
della membrana).

## Tasks aperti

La supervisione del lavoro futuro vive in **[`o1/plan.md`](o1/plan.md)** (lo stadio Plan del cruscotto); i dettagli operativi in `o2/`. I task completati vengono rimossi quando chiusi.

## Strumenti

La review locale, gli audit della KB e gli altri esecutori vivono in
[`o3/tools/`](o3/tools/) e sono registrati in
[`o3/prescriptions.md`](o3/prescriptions.md). Le regole d'uso e i confini di
autorità sono in [`CLAUDE.md`](CLAUDE.md), la delega del ciclo avviato dal
custode e il suo perimetro in [`autonomy.md`](autonomy.md); il workflow di sviluppo è in
[`kb/development-workflow.md`](kb/development-workflow.md), la baseline degli
strumenti in [`kb/development-environment.md`](kb/development-environment.md).

## Presentazione

`view/` contiene le viste generate, non versionate: `view/index.html` è la home statica della system image NixOS — la mappa del ciclo d'azione, generata dai register dei poli (`goal.md`, `world.md`) — più una pagina 1:1 per `goal.md`, `world.md` e ogni `.md` delle sei collezioni, allo stesso path del repo (`o1/plan.md` → `view/o1/plan.html`), e il deck `view/presentation.html`, reso con i diagrammi Mermaid dalla sua sola sorgente `presentation/presentation.md`. Un solo entrypoint le genera dal checkout come anteprima: `python3 o3/view/build.py` (`--check` verifica senza scrivere); `python3 o3/view/serve.py` serve l'anteprima sulle reti private (porta 8000, Ctrl-C per chiudere). Il servizio permanente su `deck` le pubblica da commit pulito sulla porta 8002 (`kb/network-architecture.md § Presentazione sulla LAN`).

## Documentazione

La KB locale del dominio nixos vive in `kb/`: host, rete, servizi e
runbook operativi. Ogni file è un nodo atomico collegato agli altri tramite la
sezione finale `Connessioni:`. README.md fa da bootstrap; il catalogo statico
completo dei nodi è l'indice interno omonimo [`kb/kb.md`](kb/kb.md) (si vede
aprendo la collezione, si legge on-demand); CLAUDE.md raccoglie le regole
operative.

Per ricostruire il sistema dall'alto verso il basso, il register di riferimento è
[`world.md`](world.md), il polo-territorio: collega host, profili home, macro-aree,
fonti di verità tecniche e nodi di approfondimento.

L'artefatto cognitivo comprende configurazione dichiarativa, KB, strumenti e
skill. La membrana host-local `world` punta al sistema NixOS attivo; atti e
segnali runtime restano nel mondo reale, mentre configurazioni, runbook e
catture diagnostiche vengono versionati solo quando servono precisione o durata.

### Capire il progetto in 5 minuti

1. [world](world.md) — Il polo-territorio: host, profili, macro-aree, fonti di verità
2. [network-architecture](kb/network-architecture.md) — Rete casa, accesso all'ufficio, servizi esposti e ruolo delle VPN
3. [client-desktop-architecture](kb/client-desktop-architecture.md) — Ruoli dei tre host di casa e strato desktop condiviso
4. [syncthing-architecture](kb/syncthing-architecture.md) — Mesh Syncthing dei client domestici e mount Drive

### Se devi...

- **capire la struttura complessiva del repository**: [world](world.md)
- **capire come sono distribuite le configurazioni**: [configuration-patterns](kb/configuration-patterns.md)
- **aggiungere host, profili o moduli**: [project-extension](kb/project-extension.md)
- **intervenire su rete, VPN o accessi SSH**: [network-architecture](kb/network-architecture.md), [home-lan-addresses](kb/home-lan-addresses.md), [wireguard-home](kb/wireguard-home.md), [ssh-matrix](kb/ssh-matrix.md)
- **assegnare o avviare il ciclo autonomo di un repo**: [cicli](kb/cicli.md)
- **aggiornare o fare rollback**: [development-workflow](kb/development-workflow.md), [common-commands](kb/common-commands.md)
- **capire sync e mount Google Drive**: [syncthing-architecture](kb/syncthing-architecture.md), [rclone-gdrive](kb/rclone-gdrive.md)
- **capire i client di casa e il desktop comune**: [client-desktop-architecture](kb/client-desktop-architecture.md)
- **usare LLM/OCR o trascrizione su game**: [game-local-llm](kb/game-local-llm.md), [game-live-transcription](kb/game-live-transcription.md)
- **fare setup, restore o recovery**: [post-installation](kb/post-installation.md), [disaster-recovery](kb/disaster-recovery.md)
- **diagnosticare un problema senza sapere da dove partire**: [troubleshooting](kb/troubleshooting.md)
- **consultare l'inventario hardware degli host**: [hardware-inventory](kb/hardware-inventory.md)

### Catalogo completo

Il catalogo statico completo dei nodi `kb/`, raggruppato per area, vive
nell'indice interno omonimo [`kb/kb.md`](kb/kb.md): si vede aprendo la
collezione, si legge on-demand. Si rigenera e si verifica con
`o3/tools/kb_tools.py audit`.
