---
ciclo: dev
method_commit: b59bcb9184bf524480c3de63e87c82b239096efa
reviewed_at: 2026-11-12
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
- Servizio permanente: `deck` pubblica da commit pulito tutti i suoi repo,
  `method` (8001), `nixos` (8002), `salute` (8003) ed `economia` (8004),
  elenco `published` di `o3/presentations.nix`.

## Prescrizioni aperte del canone

- `motori-del-ciclo`: già recepita; il profilo sceglie Claude e Codex,
  l'host offre binari e recinto. Le correzioni dell'esecutore sono lette
  direttamente dal canone. Il fallback per credito esaurito resta non osservato.
- `ultimo-giro`: recepita nelle skill eval/exec e nei permessi del giro;
  `python3 method/../o3/ultimo_giro.py` legge giro, Esiti e Prossimo.
  L'assenza di dinieghi nel prossimo giro resta da osservare.
- `strumenti-dal-canone`: recepita nei file. Rimossi i builder, gli asset,
  kb_profile e il fork KB; profilo e modulo di dominio conservano i controlli
  NixOS. Gate, skill, permessi e comandi usano il canone. Il modulo home
  delle viste considera anche il canone nell'impronta e nell'innesco e
  conserva i builder locali degli adottanti non ancora migrati. La versione
  pubblicata dichiara i due commit in `provenance.json`. Lo switch Home
  Manager su deck è riuscito: server attivo, pubblicazione riuscita e
  `/_stato` valido; la pubblicazione segue i commit, non il working tree.

## Intervallo revisionato

`47289138f25b703e6a4bfc8c3acdce2ad0402171..b59bcb9184bf524480c3de63e87c82b239096efa`:
16 commit.

- **Già soddisfatto (3):** `bb03684`, esecutore Codex; `1f29f66`, gate
  degli stadi; `cbd4c4e`, protocollo Herdr, consumati direttamente dal canone.
- **Adattamento (4):** `de3fe56`, ultimo giro nelle skill e nei permessi;
  `e07b485`, descrizioni della home in project; `7bde89a`, builder dal
  canone; `b59bcb9`, nucleo KB dal canone e controlli di dominio separati.
- **Non pertinente (9):** `20a8e2f`, `e330430`, `d8610be`, `4d551d3`,
  `27181d3`, `633eba8`, `669896b`, `000730e`, `c12512c`: osservatorio,
  accessi agli adottanti e stato del ciclo e della coda interni a method.

Nessun task locale aggiunto. Verifiche: audit, inventory, facts, coverage,
fidelity, review locale, contratto delle viste e regressioni dei builder;
confronto dei quattro report NixOS con il fork precedente (output identici),
65 test delle viste riusciti e valutazione Home Manager valida. Una
pubblicazione reale in un repository temporaneo con i file del recepimento
ha prodotto la versione con entrambi i commit in `provenance.json`. Il marker è
riletto sullo stesso target per verificare l'intervallo vuoto.
