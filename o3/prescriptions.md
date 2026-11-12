# Prescriptions

Indice della collezione `o3/`: lo **stadio o3** (Perform) del ciclo. Il
significato dello stadio vive nell'atomo [perform](../method/perform.md). Il
Mondo runtime di NixOS è il sistema in esecuzione: l'o3-runtime è la
configurazione dichiarativa attivata con rebuild o `home-manager switch`. In
questa collezione convivono prescrizioni runtime e strumenti dev; la
distinzione è esplicita nella mappa sotto, non delegata alla root.

## Contenuti

Nessuna prescrizione narrativa aperta.

## Dichiarazione runtime

- `hosts/` — host NixOS e profili di mondo:
  - `hosts/default.nix` — baseline sistema comune ai tre host, desktop compreso
  - `hosts/<host>/` — differenze fisiche e funzionali del singolo host
- `home/` — profili Home Manager:
  - `home/default.nix` — baseline home comune
  - `home/<user>/<host>.nix` — profilo utente su host specifico
- `modules/` — unità riutilizzabili:
  - `modules/system/` — moduli NixOS system-level
  - `modules/home/` — moduli Home Manager e wrapper CLI utente
- `identity/` — template pubblici e istruzioni per l'input locale delle
  identità reali, che restano fuori da Git
- `ciclo/` — il giro senza custode di questo repo: `prompt.md` (il prompt
  dell'unità `ciclo-nixos`) e `permessi.json` (i permessi del solo ciclo
  autonomo), in sola lettura nell'unità (voce `nixos` di `cicli.nix`;
  prescrizione `ciclo-autonomo` di `method`, chiusa il 2026-10-28 e in git).
  Le tracce dei giri stanno in `../i1/giri/`,
  ignorate da git

## Strumenti

- `scripts/con-identita.sh` — passa l'input locale a Nix, Home Manager o
  nixos-rebuild senza scriverlo nel lock pubblico; si ferma se manca la
  directory locale. I permessi dell'atto restano quelli di `CLAUDE.md`.
- `tools/privacy.py` — controlla i file pubblicabili contro le regole private
  in `~/.config/nixos/privacy.json`, riportando solo file, riga e numero
  della regola, mai il dato. Nel gate `--if-configured` dichiara il controllo
  saltato se mancano le regole. Test: `python3 -m unittest discover -s
o3/tools/tests`. Non sostituisce uno scanner di segreti come gitleaks.

- `scripts/maintenance-due.sh [host]` — legge `i1/manutenzione.json` e i
  task world del plan; stampa scadenze, debounce, revisione da valutare e
  presenza in `applicato_su`, senza scrivere né eseguire manutenzione.
  Test: `python3 -m unittest discover -s o3/scripts/tests`.

- `method/../o3/kb_profile.py --root .` — profilo quantitativo della KB:
  manifest dei nodi, dimensioni, maturità e limiti; dalla root usa
  `python3 method/../o3/kb_profile.py --root .`.
  Il protocollo e il profilo di dominio vivono nella skill `kb`.

- `scripts/home-versions.sh` — confronta gli agenti AI installati da `pkgs-ai`
  (input `ai` lockato) con nixpkgs unstable e segnala disponibilita' in cache.
- `scripts/system-versions.sh` — confronta pacchetti di sistema dell'host
  corrente con nixpkgs unstable, includendo input host, peso closure e cache;
  la cache si cerca in quelle configurate per l'host nel checkout, e
  l'intestazione mostra anche quelle attive.
- `scripts/cache-status.sh [-v] <store-path> <cache…>` — stato di uno store
  path nelle cache indicate, dal narinfo: presente, assente, accesso negato
  o non verificata. Test in `scripts/tests/test_cache_status.py`.
- skill `manutenzione` — orchestra gli script sopra per ramo di scope
  (`ia|home-manager|casa|world|all`) e aggiunge la parte di
  giudizio (changelog upstream, rischi, ordine, stato issue upstream);
  esegue i rami `ia` e `home-manager` e il bump dei pacchetti overlay locali in scope (ex skill
  `overlay`, fusa qui il 2026-08-02), diagnostica su `casa`, sorveglia il
  debito upstream tracciato (`world`). I rami `lavoro` e `docker` sono
  passati a `example-org/nixos-ufficio` il 2026-11-04.
- `scripts/system-drift.sh [host rev sistema]` e `scripts/home-drift.sh [host riga]`
  — deriva di configurazione: il sistema e la home che il flake costruisce a
  `HEAD` sono quelli attivi sull'host? Il sistema si confronta sul toplevel,
  identità locale compresa; test in `scripts/tests/test_system_drift.py`.
- `scripts/registro.sh '<filtro jq>'` — scrive `i1/manutenzione.json` in
  place; `scripts/ripristina-lock.sh` riporta `flake.lock` a `HEAD` dopo un
  bump fallito; `scripts/probe.sh` valuta le `probe:` della legenda del plan
  con un vocabolario chiuso.
- `scripts/sonda-grafie.sh` — sonda delle grafie dei permessi del giro
  (`claude -p` coi settings del giro), da lanciare in sessione.
- `scripts/hw-report.sh` — genera un report hardware host-local in `/tmp`;
  richiede `sudo` per `dmidecode`, `hdparm` e `nvme`.
- `tools/check.sh` — review locale non distruttiva (no sudo): formatter, audit KB,
  facts, coverage, fidelity. `--flake` aggiunge `nix flake check`.
- `method/../o3/kb_tools.py --root .` — backend deterministico per audit e fact-check. Comandi:
  - `audit` — audit strutturale (link rotti, orfani, catalogo `kb/kb.md`,
    naming, cluster, facet, candidati termini); il report resta su stdout
  - `facts` — confronto fatti documentali (host, profili, moduli) vs
    `flake.nix` e filesystem
  - `coverage` — copertura di host, moduli, macro-aree e wrapper CLI Home
    Manager
  - `fidelity` — aggregato del drift (facts + coverage) come indicatore unico
  - `inventory` — inventario host, profili home e moduli derivato dal
    filesystem
  - `facets` — attributi di dominio (`ciclo` sugli item di collezione)
  - `backlinks <nodo>` · `orphans` · `readme` (copertura `kb/kb.md`) ·
    `migration` · `terms`
- `kb_tools.toml` e `kb_domain.py` — profilo e controlli NixOS per il nucleo
  canonico: inventario host/moduli, facts, coverage, fidelity e struttura.
- `view/project.py` — identità delle viste: sigla NixOS, lingua inglese,
  accento `#c2410c`, descrizione locale di o3, CSS `nixos.css`, deck
  `presentation/presentation.md`, nessuna esclusione.
- Builder, server e asset delle viste vivono nel canone, senza copie locali:
  `python3 method/../o3/view/build.py --root .` costruisce l'anteprima,
  `--check` verifica senza scrivere e `--publish DIR` pubblica da commit
  pulito. `python3 method/../o3/view/serve.py --root .` serve sulle reti
  private. Contratti e opzioni: [view](../method/view.md).
  Il servizio di deck è descritto in `kb/deck-user-services.md`.
  Le regressioni locali in `view/tests/` importano i builder canonici.

Gli strumenti in `tools/` e `view/` sono **esecutori deterministici del ciclo di sviluppo**
(`ciclo: dev`): agiscono sull'artefatto — KB, viste, audit — non direttamente
sul sistema che gira.

## Skill

Il quartetto operativo vive in `.claude/skills/` (versionato nel progetto),
ritagliato lungo i due archi del ciclo: `eval [perceive|interpret|compare]` è
il braccio di valutazione — grezzo dal sistema in esecuzione, sintesi i2, fili
`i3/` contro i segnali reali e copertura obiettivo→filo; `exec
[plan|specify|perform]` è il braccio di esecuzione — coerenza `o1/plan.md`/`o2/`
e direzione task→obiettivo verso `goal.md`, qualità interna dei task,
supervisione di questa collezione; `kb` interpreta gli script e aggiunge
revisione qualitativa (capacità trasversale ai due archi), `commit` applica
formatter, Conventional Commits e filing back; `method` revisiona
l'allineamento al repository canonico (marker in
`i3/allineamento-metodo.md`). Cfr. [skill](../method/skill.md).
`.codex/skills/` contiene i wrapper agent-agnostici.

La **skill di dominio** è catalogata qui perché il Perform è uno dei suoi
stadi, con la mappa degli archi che il pilota del montaggio ha fissato
(2026-08-01; **mantenuta autonoma**, non assorbita come argomento delle
canoniche):

- `manutenzione [ia|home-manager|casa|world|all]` — attraversa
  entrambi gli archi: gli script di `scripts/` sono `perceive`,
  delta/changelog/stato issue upstream `interpret`, il «vale la pena ora?»
  `compare`, e `perform` copre i rami `ia` e `home-manager` più il bump dei
  pacchetti overlay in scope (ex skill
  `overlay`, fusa qui il 2026-08-02 — stessa procedura, stesso confine
  home/system-level di `CLAUDE.md` sull'attivazione). Non si divide perché
  è il ramo a determinare l'arco, non chi invoca, e `/manutenzione ia` è un
  gesto unico che va da perceive a perform.
