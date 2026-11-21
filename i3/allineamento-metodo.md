---
ciclo: dev
method_commit: 719fb7b5c0282dbf2d1200948e00754cc4833121
reviewed_at: 2026-11-18
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
  fonte aperta» per browser e kernel è locale. `Skill(manutenzione)` è
  invocabile senza allow specifico: le regole Skill non sono una lista
  esclusiva. Il caso su Claude Code 2.1.321 è coerente con la documentazione
  ufficiale; non è un'anomalia aperta. La spiegazione è in
  `method/skill.md`, «Permessi di invocazione in Claude Code».
- Il fork `/cycle` distingue preautorizzazione e lista esclusiva; il
  riscontro locale è acquisito dal canone (`639999f`) e resta in git.
  La correzione non cambia permessi o delega e non costituisce più una
  divergenza intenzionale. Il cursore generale resta quello nel frontmatter;
  il recepimento di questa segnalazione non dichiara revisionati gli altri
  cambi del canone.
- `/kb` usa il protocollo comune e il profilo locale
  `.claude/skills/kb/domain.md`: inventario dal filesystem, ledger completo,
  fonti dichiarative e distinzione fra configurazione, generazione e
  runtime. Audit, facts e coverage non certificano l'utilità semantica né
  ogni invariante.
- Il nucleo KB si esegue dal canone con `--root .`; `o3/kb_tools.toml`
  dichiara il perimetro locale e `o3/kb_domain.py` conserva inventory,
  facts, coverage, fidelity e il controllo dei link fra kb e tech.
  Footer duplicati, traduzioni e task sono coperti dal nucleo canonico.
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
  `sudo` nel perceive; `sudo`, rebuild, reboot e atti sugli altri host
  restano fuori, compresi gli host di lavoro. `/method` e `/manutenzione` conservano i propri gate.
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

- `nixos` non adotta il ciclo autonomo: a casa nessun giro senza custode
  (custode, 2026-11-20; `autonomy.md`, «Nessun ciclo senza custode»). Il
  meccanismo dell'host (registro, modulo `cicli`, recinto, sonda) e
  `o3/ciclo/` sono tolti e restano in git; il modo `autonomo` di `/cycle`
  non si usa. Le prescrizioni del canone sul giro
  autonomo non si recepiscono finché non cambia la scelta.
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

- `o3/view/` contiene solo `project.py` e le regressioni locali: builder,
  server e asset si eseguono dal canone con `--root .`. La descrizione
  locale di o3 è in `project.py`, nel campo `DESCRIZIONI`.
- `project.py`: sigla «NixOS», `LINGUA = "en"`, accento `#c2410c`,
  `CSS_LOCALI = ["nixos.css"]` (in `presentation/`: la tavola e i riquadri
  del deck), `ESCLUSE` vuota.
- Il deck vive in `presentation/presentation.md`, dichiarato in `DECK` e
  reso dal canone, senza builder di dominio né Mermaid: la topologia è la
  tavola `presentation/rete.svg`.
- I test vivono in `o3/view/tests/` (il repo non ha `tests/` in root),
  importano i builder canonici e seguono il contratto di pubblicazione
  con provenienza di entrambi i commit.
- `view/` è fuori da git, e `.gitattributes` porta solo la riga canonica
  `o3/view/**`. In locale `build.py` rende l'anteprima; il gate di `/commit`
  e il contratto di `exec plan` usano `build.py --check`.
- Esposizione: le viste rendono ogni item delle sei collezioni, con
  hostname, IP privati e topologia, nessun segreto. Vale la decisione del
  custode in `CLAUDE.md § Comportamenti vincolati`.
- Il riavvio dopo un cambio di `o3/view/` del canone è osservato su `deck`:
  la pubblicazione ha segnalato il cambio, il servizio è ripartito dopo il
  commit e l’impronta registrata coincide con l’albero corrente del canone.
- Servizio permanente: `deck` pubblica da commit pulito tutti i suoi repo
  (elenco `published` di `o3/presentations.nix`) e li serve in due siti:
  `method` sulla 8001, il gruppo `casa` sulla 8002 con `casa`, `nixos`,
  `salute` ed `economia` sotto `/<repo>/` (`serve.py --gruppo`).

## Prescrizioni aperte del canone

Nessuna: le tre precedentemente riportate sono state chiuse nel canone.
Il fallback per credito esaurito resta non osservato.

## Intervallo revisionato

`b59bcb9184bf524480c3de63e87c82b239096efa..719fb7b5c0282dbf2d1200948e00754cc4833121`:
48 commit.

- **Già soddisfatto (7):** `64fa0cc`, `863b184`, `c803294`, `6985d1e`
  e `719fb7b` sono strumenti consumati dal canone; `639999f` è già nel
  fork del ciclo; `5832a13` è documentazione canonica consumata direttamente.
- **Adattamento (2):** `64032d3` riguarda pulizia e indici, già adattati
  alla struttura locale; `02a2231` separa la pubblicazione delle viste e
  sposta sezioni del plan: aggiornati i riferimenti locali interessati.
- **Non pertinente (39):** gli altri commit riguardano il territorio, i
  task, l'osservatorio e i profili propri di `method`, incluso `2261e69`,
  esplicitamente limitato al suo gate locale.

Nessun task locale aggiunto. Il cambio delle viste `719fb7b` ha risvegliato
l'attesa sul riavvio: pubblicazione, riavvio e impronta sono stati verificati
su `deck`, e il task è chiuso. La correzione rende visibile lo stream del
motore finale, incluso Codex, dalle viste che usano il canone.
