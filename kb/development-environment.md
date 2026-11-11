---
stato: maturo
---

# Development environment

Gli strumenti di sviluppo trasversali sono distribuiti in user space tramite
Home Manager e risultano disponibili in ogni profilo che importa il baseline.
Le toolchain specifiche restano invece nei flake dei singoli progetti.

## Avvio rapido

```bash
# Agenti AI — su tutti i profili
claude
codex
pi

# Google Workspace — su tutti i profili
gog

# Formatter — su tutti i profili
prettier file.md        # Markdown/JS/TS/JSON/YAML/CSS/HTML
ruff format script.py   # Python
ruff check script.py    # lint Python
eslint src/             # lint JavaScript/TypeScript
alejandra flake.nix     # Nix

# Parsing e ispezione
python3 script.py       # stdlib: ast, json, tomllib, argparse
jq '.key' file.json     # parsing e trasformazione JSON
sqlite3 data.db         # ispezione e query SQLite
rg "pattern" .          # ricerca veloce in codice e documentazione
pdftotext file.pdf -    # estrazione testo da PDF (poppler-utils)
qpdf --check file.pdf   # validazione struttura PDF
md2pdf report.md        # Markdown -> PDF con Pandoc, Mermaid e LaTeX
ffprobe file.mp4        # metadata audio/video
```

`gog` non viene da `dev-tools.nix`: ha un modulo home proprio, importato dalla
baseline `o3/home/default.nix`. Dettaglio in `google-workspace-cli`.

## Python e strumenti di parsing

Gli strumenti globali Python sono volutamente minimi e stabili. Il baseline
home-manager fornisce `python3` per scripting, parsing con libreria standard e
utility di manutenzione della KB, e `ruff` come formatter/linter Python usato da
editor e CLI.

Per parsing Python strutturale, il primo strumento disponibile è quindi la
libreria standard:

- `ast`: parsing sintattico Python per analisi locali o script di audit
- `json`: lettura/scrittura JSON senza dipendenze esterne
- `tomllib`: lettura TOML in Python moderno
- `argparse`: CLI deterministiche per strumenti versionati
- `pathlib`: attraversamento filesystem portabile

Per parsing e ispezione di altri formati sono globali:

- `jq`: JSON da shell e pipeline
- `sqlite3`: ispezione e query di database SQLite, inclusi gli export di Health
  Connect usati dal repository `salute`
- `ripgrep` (`rg`): ricerca veloce in codice e documentazione
- `poppler-utils`: estrazione e ispezione PDF (`pdftotext`, `pdfinfo`)
- `qpdf`: validazione e trasformazione PDF
- `ffmpeg` / `ffprobe`: metadata e flussi audio/video
- ImageMagick: metadata e trasformazioni immagini
- Pillow: scripting Python su immagini (`from PIL import Image`)
- `md2pdf`: conversione Markdown in PDF con Pandoc, Mermaid e LaTeX, distribuita
  via Home Manager a tutti i profili

Non sono globali, al momento: `uv`, `mypy`, `pyright`, `pylint`, `black`,
`semgrep`, `ast-grep`, `tree-sitter`, `yq` e `fd`. Se un progetto richiede uno
di questi strumenti, va preferito il flake del progetto invece di allargare il
baseline globale, salvo uso trasversale reale su più repository.

Esempio attuale: `~/economia` dichiara nel `devShell` del proprio flake un
Python 3.12 con le librerie di analisi, `uv`, Tesseract con l'italiano e
`poppler-utils`. Questa è la forma corretta per strumenti non ancora baseline
globale.

## Gestione degli agenti AI

### Perché un input `ai` separato

Gli agenti AI a cadenza rapida (Claude Code, Codex, Pi) e il loro multiplexer Herdr
sono installati via Home Manager da un **input nixpkgs separato** (`ai`),
aggiornabile senza toccare il sistema. Vantaggi:

- si aggiornano gli agenti senza muovere i pacchetti di sistema;
- niente `node_modules` né conflitti di `package-lock`: gestisce Nix;
- disponibili in ogni terminale, su tutti i profili;
- l'aggiornamento resta un gesto manuale ed esplicito (`hfu`).

Codex ha temporaneamente un input dedicato `nixpkgs-codex`, fermo alla
revisione `f9a75f4` con Codex 0.166.0 e le sue dipendenze: la build di
0.167.0 fallisce in `aws-lc-sys` (NixOS/nixpkgs #585124). L'override di
`pkgs-ai.codex` in `flake.nix` permette agli altri agenti di avanzare.
`home-versions.sh` legge il pin effettivo; `/manutenzione ia` ne sorveglia
la rimozione, subordinata a cache o build riuscita del Codex nell'input `ai`.

`gogcli` (binario `gog`) segue una strada diversa: arriva dai `pkgs` ordinari
con un overlay locale permanente in `flake.nix` (segue le release upstream di
`openclaw/gogcli`, più rapide di nixpkgs), e vive in un modulo home proprio.
Il confronto funzionale tra CLI e MCP vive in `google-workspace-cli`.

### Dove vive ogni pezzo

- **`o3/modules/home/dev-tools.nix`** — language server, formatter e linter dai
  `pkgs` ordinari, più `claude-code`, `codex` e `pi-coding-agent` da `pkgs-ai`. È il modulo che
  ogni profilo importa per il tooling di sviluppo.
- **`o3/modules/home/pi.nix`** — estensione web di Pi, importata da
  `dev-tools.nix`; configurazione e dipendenze fissate in Nix.
- **`o3/modules/home/herdr.nix`** — Herdr da `pkgs-ai`, con la propria config
  TOML. Importato da `o3/home/default.nix`, quindi presente ovunque.
- **`o3/modules/home/google-workspace-cli.nix`** — `gogcli`. Importato da
  `o3/home/default.nix`, quindi presente ovunque.

La separazione conta: cercare `gogcli` o `herdr` dentro `dev-tools.nix` non
porta da nessuna parte.

### Memoria degli agenti: versionata nel repo

La memoria del progetto vive versionata in `kb/`, `i3/` e `o2/`, non nello
store auto-memory dell'harness (`~/.claude/projects/.../memory/`), che è locale
alla macchina e fuori da Git. `o3/modules/home/claude-code.nix` spegne
l'auto-memory in due punti — `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`
nell'ambiente Home Manager e nell'`env` di `~/.claude/settings.json` — così il
vincolo è dichiarato nel repository e arriva a ogni profilo che importa il
modulo. Lo stato effettivo di un host resta da verificare dopo il suo
`home-manager switch`.

Lo stesso modulo dichiara le istruzioni globali `~/.claude/CLAUDE.md`, valide
in ogni repository: solo preferenze personali dell'utente (es. dare del tu in
italiano), mai regole di progetto, che restano nel `CLAUDE.md` di ciascun repo.

### Pi: ricerca web minimale

`pi.nix` distribuisce **pi-web-access** da npm con versione in
`o3/modules/home/pi-web-access/package.json`, dipendenze transitive nel
`package-lock.json` adiacente e hash `npmDepsHash`. La build Nix installa le
sole dipendenze runtime, senza script npm né copie dei peer Pi. Non serve
`pi install`: l'estensione viene scoperta tramite
`~/.pi/agent/extensions/web-access.ts`, che importa il percorso assoluto nello
store (necessario perché il loader risolva le dipendenze npm). `settings.json`
e le credenziali Pi restano scrivibili e non sono gestiti dal modulo.

La policy in `~/.pi/agent/web-search.json` abilita tre strumenti:
`web_search`, `fetch_content` e `get_search_content`. Ricerca solo su **Exa**
(senza chiave, tramite MCP pubblico), lettura pagine via HTTP diretto e
recupero dei risultati lunghi dalla cache. Le query vengono inviate a Exa;
il servizio gratuito può imporre limiti. Non configurare `EXA_API_KEY` se
si vuole restare sul percorso senza chiave.

Il workflow predefinito restituisce risultati senza riepiloghi generati né
apertura del browser. Comandi aggiuntivi, cookie, clonazione GitHub,
gestione speciale di issue/PR, immagini, PDF e video sono disabilitati;
nessun fallback a servizi di estrazione remoti. Le pagine che richiedono
JavaScript o bloccano HTTP possono quindi fallire. Queste opzioni limitano
le funzionalità, ma non isolano il codice dell'estensione: gira con i
permessi di Pi. Il terminale usa il `bash` integrato, senza estensioni.

Dopo uno switch Home Manager, riavviare Pi o usare `/reload`.
Per aggiornare l'estensione: modificare la versione nel manifest,
rigenerare il lock con `npm install --package-lock-only --ignore-scripts
--legacy-peer-deps`, aggiornare `npmDepsHash` e collaudare la build e gli
strumenti prima dello switch. L'input `ai` aggiorna Pi, non questa estensione.

### Input e cadenze

La fonte tecnica è `flake.nix`; `nix-flakes` descrive input, cadenze e pin
strutturali. Ogni profilo home richiede un'attivazione separata sul proprio
host.

### Aggiornare gli agenti AI

Si usa l'abbreviazione fish `hfu` (home fresh update):

```bash
cd ~/nixos

# Aggiorna solo l'input ai (stack agentico)
hfu                    # espande a: nix flake update ai

# Applica via home-manager (senza sudo)
hms                    # espande a: o3/scripts/con-identita.sh home-manager switch --flake .#$USER@(hostname)

# Fra update e attivazione: validare e committare il delta
# secondo development-workflow; hms applica poi la revisione verificata.
```

### Abbreviazioni fish

- **`hfu`** — aggiorna solo l'input `ai`
- **`hms`** — applica il profilo Home Manager dell'utente e host correnti
- **`nrs`** — applica la configurazione NixOS corrente (richiede sudo)

Gli aggiornamenti degli input di sistema vanno eseguiti per nome; non usare un
update globale. Comandi e cadenze sono documentati in `nix-flakes`.

### Verificare le versioni

```bash
# Versioni installate
claude --version
codex --version
pi --version
herdr --version
gog --version

# Versioni disponibili su nixpkgs
nix search nixpkgs claude-code
nix search nixpkgs codex
nix search nixpkgs pi-coding-agent
nix search nixpkgs herdr
nix search nixpkgs gogcli
```

Lo script `o3/scripts/home-versions.sh` confronta in un colpo solo la versione
installata dei pacchetti `pkgs-ai` (agenti AI e Herdr) con quella disponibile
su nixpkgs unstable e verifica la cache binaria. `gogcli` segue invece
l'overlay ordinario in `flake.nix`.

## Confine con i repository applicativi

Questo nodo descrive soltanto il baseline fornito da NixOS e Home Manager. Le
toolchain specifiche devono vivere nei flake dei rispettivi repository; i repository
applicativi custodiscono le proprie prescrizioni; `world.md` instrada alle
macro-aree e alle fonti tecniche dell'infrastruttura.

Connessioni:

- [development-workflow](development-workflow.md)
- [game-local-llm](game-local-llm.md)
- [md2pdf](md2pdf.md)
- [common-commands](common-commands.md)
- [configuration-patterns](configuration-patterns.md)
- [client-desktop-architecture](client-desktop-architecture.md)
- [google-workspace-cli](google-workspace-cli.md)
- [nix-flakes](nix-flakes.md)
