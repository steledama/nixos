# Configurazione NixOS

La configurazione completa dei tre computer di casa: un portatile che fa
anche da piccolo server, un desktop e un PC da gioco. Tutto è dichiarato in
questo repository con NixOS, flakes e home-manager standalone: sistema,
desktop, servizi, sincronizzazione dei file e strumenti di sviluppo. Ogni
host si ricostruisce da qui, senza configurazioni manuali fuori dal repo.

[![Nix Flakes](https://img.shields.io/badge/Nix-Flakes-blue.svg?logo=nixos&logoColor=white)](https://nixos.wiki/wiki/Flakes)
[![Hosts](https://img.shields.io/badge/Hosts-3-green.svg)](#)
[![Open Source First](https://img.shields.io/badge/Software-Open%20Source%20First-brightgreen.svg)](#)

Il progetto tiene in equilibrio due obiettivi che si tirano a vicenda: un
sistema **snello e minimalista** e tre host **affidabili**, che si
ricostruiscono dal repository e i cui servizi ripartono da soli. Il primo
chiede di togliere, il secondo di aggiungere ridondanza: come si bilanciano
è scritto in [`goal.md`](goal.md).

Accanto alla configurazione vivono la sua documentazione, il piano di lavoro
e un ciclo autonomo quotidiano in cui un agente AI controlla gli
aggiornamenti e tiene allineata la conoscenza del sistema. È un'applicazione
del metodo descritto più sotto.

## Per iniziare

I dati personali (indirizzi, nomi, account) restano fuori dal repository:
nella configurazione pubblica e negli esempi sono segnaposto, e il flake
senza override costruisce i template. Prima di configurare un host leggere
[`o3/identity/README.md`](o3/identity/README.md), che spiega come fornire
l'identità locale ai comandi di attivazione.

Il metodo è in un repository pubblico separato, da clonare accanto a questo
per risolvere il symlink `method/`:

```bash
git clone https://github.com/steledama/method ../method
```

## Host

- **deck** — Intel N150, Intel UHD Graphics, portatile e server di casa
- **neve** — Intel i5-6600, Intel HD Graphics 530, desktop
- **game** — AMD Ryzen 5 5600X, NVIDIA GeForce RTX 4070, PC da gioco e
  inferenza locale

Ruoli, profili e fonti di verità di ciascuno: [`world.md`](world.md).

## Da dove partire

In cinque minuti:

1. [world](world.md) — host, profili, macro-aree e fonti di verità
2. [network-architecture](kb/network-architecture.md) — rete di casa, VPN e servizi esposti
3. [client-desktop-architecture](kb/client-desktop-architecture.md) — ruoli dei tre host e desktop condiviso
4. [syncthing-architecture](kb/syncthing-architecture.md) — sincronizzazione fra gli host e mount Google Drive

Se devi...

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

## Stato e lavoro aperto

Il lavoro futuro è in **[`o1/plan.md`](o1/plan.md)**, con una riga per task
e la direzione corrente; i dettagli operativi stanno in `o2/`. I task
chiusi si rimuovono, la loro storia resta in git.

## Metodo

Il repository applica il _cognitive artifact design_: configurazione,
conoscenza, piano e strumenti formano un unico artefatto che persone e
agenti AI leggono e mantengono con lo stesso ciclo, dalla percezione del
sistema in esecuzione agli atti che lo cambiano. Il metodo vive nel repo
separato `method`, esposto qui dal symlink `method/ -> ../method/kb`;
l'ingresso è [`method/cognitive-artifact-design.md`](method/cognitive-artifact-design.md).

I due poli del ciclo sono i register di root: [`goal.md`](goal.md), gli
obiettivi e i segnali che li misurano, e [`world.md`](world.md), il
territorio.

Principi di progetto (zero dead code, DRY, modularità, policy unfree
esplicita): [`method/design-principles.md`](method/design-principles.md).

## Struttura

- `kb/` — la conoscenza del dominio: host, rete, servizi e runbook, un nodo
  atomico per file con le sue `Connessioni:`. Catalogo completo in
  [`kb/kb.md`](kb/kb.md).
- `o3/` — configurazione Nix (`o3/hosts/`, `o3/modules/`, `o3/home/`),
  script e strumenti. Review locale e audit della KB in
  [`o3/tools/`](o3/tools/), registrati in [`o3/prescriptions.md`](o3/prescriptions.md).
- `i1/`–`i3/`, `o1/`–`o2/` — le collezioni del ciclo: osservazioni,
  interpretazioni, verdetti, piano e task.
- `presentation/` e `view/` — il deck e le viste HTML generate (non
  versionate). `python3 method/../o3/view/build.py --root .` le costruisce come anteprima e
  `python3 method/../o3/view/serve.py --root .` le serve sulle reti private; `deck` le pubblica
  in modo permanente ([`kb/deck-user-services.md`](kb/deck-user-services.md)).

Le regole operative e i confini di autorità per gli agenti sono in
[`CLAUDE.md`](CLAUDE.md); la delega del ciclo in [`autonomy.md`](autonomy.md);
il workflow di sviluppo in [`kb/development-workflow.md`](kb/development-workflow.md).
