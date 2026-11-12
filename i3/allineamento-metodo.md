---
ciclo: dev
method_commit: 47289138f25b703e6a4bfc8c3acdce2ad0402171
reviewed_at: 2026-11-11
status: aligned
obiettivo: S
---

# Allineamento al metodo e interpretazioni

NixOS è allineato al canone fino al commit indicato nel frontmatter. Qui
stanno il cursore e le sole differenze locali volute, che la prossima
revisione non deve ri-segnalare: ciò che è recepito senza adattamento non
compare, e quando e da quale commit ogni voce è arrivata è nella storia git
di questo file. I nodi canonici sono consumati tramite
`method/ -> ../method/kb`, senza copie nel catalogo locale.

## Adattamenti intenzionali

### Ingressi e skill

- README orienta per intenti NixOS; CLAUDE conserva i guardrail prima degli
  atti sui tre host di casa: autorità sudo, seed dei segreti, Home Manager
  autonomo, push del solo branch corrente. La sua maggiore lunghezza è un
  vincolo di dominio; i dettagli restano nei nodi.
- `/kb`, `/commit`, `/eval`, `/exec`, `/cycle`, `/method` e `/manutenzione`
  sono fork che conservano le estensioni NixOS; `/cycle` ha il wrapper
  Codex. La skill canonica `adottanti` non è forkata. Gli strumenti di
  formato e il gate `o3/tools/check.sh` restano parte del contratto locale.
- `/exec` ha l'ingresso selettivo: nucleo in `SKILL.md`, procedure
  `plan.md`, `specify.md`, `perform.md` nella stessa cartella, con oggetto
  esplicito `specify <task>`. È una divergenza sperimentale da confrontare
  col canone; «prossimo task» e `/exec all` restano non collaudati, limite
  accettato dal custode.
- `/manutenzione` è una skill di dominio autonoma, non uno stadio della
  tripartizione: nucleo con selezione dei rami (`ia`, `home-manager`,
  `casa`, `world`, più `remoto` su `game` e `neve`), file interni e supporti
  condivisi. Non porta `Esiti:` né `Prossimo:` e committa da sola il proprio
  esito, senza concordare il momento, perché è il centro del ciclo di
  `nixos` (scelta del custode). È divisa in fase diagnosi (`perceive`) e
  fase atti (`perform`); in sessione le due si compiono di seguito, e un
  ramo fermato dal verdetto non si registra. La regola «rischio solo da
  fonte aperta» per browser e kernel è locale. `Skill(manutenzione)` non è
  concesso al giro, che la legge dal suo `SKILL.md`.
- `/kb` usa il protocollo comune e il profilo locale
  `.claude/skills/kb/domain.md`: inventario dal filesystem, ledger completo,
  fonti dichiarative e distinzione fra configurazione, generazione e
  runtime. Audit, facts e coverage non certificano l'utilità semantica né
  ogni invariante.
- Il fork `kb_tools.py` conserva inventory, facts, coverage e i controlli
  system/home; footer duplicati e link fuori dai nodi sono coperti.
- `/eval` distingue evidenza di una decisione da prova di un fatto esterno:
  il codice dichiarativo è fonte primaria della configurazione, mentre
  l'attivazione e lo stato degli host si osservano a parte. `nixos` non ha
  un registro delle ipotesi: il presidio è la sintesi `i2/` pertinente o un
  filo `i3/` con criterio.
- Presidio dei casi della delega: `eval perceive` (passo 3) cattura in `i1/`
  i casi metodologici emersi nell'uso, con stato «da inoltrare» o «acquisita
  da method» nell'indice. Vive nei fork.
- I sette wrapper `.codex/skills/` dicono che in Codex la lettura del
  `SKILL.md` vale come invocazione.
- La facet di questo filo è `ciclo: dev`: confronta artefatti, non host
  attivi.

### Delega

- `autonomy.md` in root istanzia la delega del ciclo col perimetro NixOS
  deciso dal custode: dentro il ciclo solo gli atti che `CLAUDE.md` già
  consente senza chiedere; `ssh` agli altri host in sola lettura e senza
  `sudo` nel perceive; `sudo`, rebuild, reboot, produzione e atti su altri
  host restano fuori. `/method` e `/manutenzione` conservano i propri gate.
- Pull autonomo: su `deck` il pull sposta `HEAD` e la path unit ripubblica
  le viste in LAN, quindi è un rilascio delle sole viste. Il custode ha
  scelto di dichiararlo invece di tenere il pull su richiesta; il sistema
  resta fuori, perché cambia solo con `home-manager switch` o
  `nixos-rebuild`. Da qui «il push non rilascia il sistema» in `CLAUDE.md`.
- Checkout servito: `~/nixos` è servito solo su `deck` e nessun host esegue
  file dal checkout. Nessuna eccezione nuova: `autonomy.md` nomina il
  checkout servito e rimanda all'eccezione condizionale di `CLAUDE.md`
  «Push remoto»; «Rilevamento host» chiede `hostname` prima del primo atto,
  pull compreso.
- Il fork `/commit` corregge con amend solo prima del push; l'amend di
  commit pubblicati resta su richiesta (`CLAUDE.md`).

### Ciclo autonomo

- Come host, `deck` ferma l'agente con `ciclo-recinto-ferma` al posto di uno
  stop di `systemctl`, passa `--codex`, rende `~/.codex` scrivibile nel
  recinto e tiene un solo paracadute in `registry.nix`, senza minuti né
  budget degli altri repo (`kb/cicli.md`, «Lanciatore canonico»).
- Come adottante, `nixos` gira con Claude primo e Codex di riserva; il
  fallback per credito esaurito resta non osservato
  ([lettura locale](../i2/codex-recinto-host.md)).
- Lo switch home-manager nel giro rende la home scrivibile (`homeWritable`,
  scelta del custode); `o3/ciclo` resta in sola lettura sopra la home
  scrivibile. I permessi del giro negano `Edit`/`Write` su `o3/ciclo/**`, e
  `.claude/settings.json` nega `git add -f`/`--force`.
- `o3/ciclo/prompt.md` tiene i gesti locali e non ripete i minimi canonici
  né elenca resoconto e trailer del giro: aggiunge al minimo di `perceive`
  `/manutenzione`, le unità fallite e `kb_tools.py fidelity`; legge le
  tendenze da `tentativi.jsonl` e chiede fatti con data e canale; distingue
  «ciclo schedulato» da «avvio a mano» dall'orario della `partenza`,
  adattato al timer delle 04:30; per l'atto fallito tiene controllo e
  comando del solo bump fallito in build con `flake.lock` cambiato.
- Gli atti ricorrenti del giro sono `/manutenzione` e `remoto`, che non sono
  task; i rimandi ai nodi passano dal symlink `method/`.
- Visione d'insieme: le tendenze di dominio sono derive, unità fallite,
  versioni indietro e dinieghi.
- Plan: la sezione delle ricorrenze segue la legenda delle attese, che resta
  sotto il titolo `## Task`. La regola di chiusura dei rimandi nomina i
  registri di dominio, cioè `world.<titolo>` e `promosso` di
  `i1/manutenzione.json`, che il prospetto di `/manutenzione` segnala come
  orfani. `maintenance-due.sh` tiene registro, `probe:` e orfane; le
  scadenze `by:` le legge `scadenze.py` del canone, senza
  `o3/scadenze.toml`.
- La clausola sull'heredoc nella regola delle grafie di `/cycle` è locale.

## Adattamenti delle viste

- `o3/view/` è la copia del canone. Le uniche parti locali sono quelle che
  il fork parametrizza per costruzione: `project.py` e la CONFIG delle
  descrizioni degli slot in `build_system_image.py` (descrizione locale di
  `o3`).
- `project.py`: sigla «NixOS», `LINGUA = "en"`, accento `#c2410c`,
  `CSS_LOCALI = ["nixos.css"]` (in `presentation/`: la tavola e i riquadri
  del deck), `ESCLUSE` vuota.
- Il deck vive in `presentation/presentation.md`, dichiarato in `DECK` e
  reso dal canone, senza builder di dominio né Mermaid: la topologia è la
  tavola `presentation/rete.svg`.
- I test vivono in `o3/view/tests/` (il repo non ha `tests/` in root) e
  differiscono dal canone solo per il path dei builder.
- `view/` è fuori da git, e `.gitattributes` porta solo la riga canonica
  `o3/view/**`. In locale `build.py` rende l'anteprima; il gate di `/commit`
  e il contratto di `exec plan` usano `build.py --check`.
- Esposizione: le viste rendono ogni item delle sei collezioni, con
  hostname, IP privati e topologia, nessun segreto. Vale la decisione del
  custode in `CLAUDE.md § Comportamenti vincolati`.
- Servizio permanente: `deck` pubblica da commit pulito tutti i suoi repo,
  `method` (8001), `nixos` (8002), `salute` (8003) ed `economia` (8004),
  elenco `published` di `o3/presentations.nix`.

## Prescrizioni aperte del canone

All'ultima revisione nessuna prescrizione aperta restava da recepire:
`motori-del-ciclo`, l'unica in elenco, è recepita. Le prescrizioni nate dopo
il cursore le rilegge la prossima revisione.

## Intervallo revisionato

`6aa4ea82222f5c3c289938f2eb87c97f2ea57521..47289138f25b703e6a4bfc8c3acdce2ad0402171`:
7 commit, revisionati il 2026-11-11.

- **Già soddisfatto:** `0eeb2db`, `dbe78b8` e `10c09e7`, l'esecutore Codex
  col solo recinto dell'host, letto dal canone.
- **Adattamento:** `4728913`, il runbook del giro a mano (sessione ferma,
  `start --wait`) in `kb/cicli.md`, «Sessioni concorrenti» e «Uso».
- **Non pertinente:** `da94452`, `dc6e902`, `dcadab3`, il profilo di method.

Verifiche della revisione: audit strutturale, inventory, facts, coverage,
fidelity e `o3/tools/check.sh` riusciti. Riletto il target dopo
l'aggiornamento del marker: intervallo vuoto.
