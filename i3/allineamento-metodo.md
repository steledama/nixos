---
ciclo: dev
method_commit: 47289138f25b703e6a4bfc8c3acdce2ad0402171
reviewed_at: 2026-11-11
status: aligned
obiettivo: S
---

# Allineamento al metodo e interpretazioni

NixOS è allineato al canone fino al commit indicato nel frontmatter. Il cursore
resta necessario alla prossima revisione; gli intervalli recepiti e le prove
passate sono ricostruibili in Git. I nodi canonici sono consumati tramite
`method/ -> ../method/kb`, senza copie nel catalogo locale.

## Adattamenti intenzionali

- Lanciatore e motori (method `fce8afe`, `accb3b5`, `4341ff0`, `201a6eb`,
  `6d3938f`, `de73101`, `0eeb2db`, `dbe78b8`, `4728913`, prescrizione `motori-del-ciclo`, recepiti il 2026-11-11). Lo stop
  verificato di `accb3b5` ha chiesto un adattamento sull'host:
  `ciclo-recinto-ferma` al posto di `systemctl stop`, che su un'unità
  transitoria già scaricata risponde `5`. Il recinto tiene in sola lettura
  anche `o3/esecutore_codex.py` del canone (`de73101`). Come host, `deck` passa `--codex`,
  rende `~/.codex` scrivibile nel recinto dei cicli col lanciatore e non
  tiene più minuti né budget degli altri repo: un solo paracadute in
  `registry.nix` (`kb/cicli.md`, «Lanciatore canonico»). Come adottante,
  `nixos` gira col lanciatore dal 2026-11-11, Claude primo e Codex di
  riserva. Col contratto canonico `--recinto-host` il giro a mano con
  Codex primo delle 20:14:17 ha chiuso con commit e push (`5769c3c`);
  il fallback per credito esaurito resta non osservato, task chiuso dal
  custode ([lettura locale](../i2/codex-recinto-host.md)). Il runbook del
  giro a mano di `4728913` (sessione ferma, `start --wait`) è in
  `kb/cicli.md`, «Sessioni concorrenti» e «Uso». Il gate
  col perimetro (`7485488`) è recepito nei fork di `/commit` e `/cycle`.
- Prova locale dell'ingresso selettivo di `/exec` (2026-10-24): nucleo
  in `SKILL.md`, procedure `plan.md`, `specify.md`, `perform.md` nella
  stessa cartella, con oggetto esplicito `specify <task>`. Mappa, confronto
  ed esito della revisione (chiusa il 2026-10-26) sono nella cattura
  `i1/agent-experience-review-20261025.md`; «prossimo task» e `/exec all`
  restano non collaudati, limite accettato dal custode. Concordata la valutazione con la sessione method via Herdr;
  la struttura resta una divergenza sperimentale da confrontare col canone.
  La frase sul commit vuoto è coerente con la correzione canonica
  `e2018a6`; il gate remoto rinvia al criterio locale vigente. Il guardiano
  canonico dello stesso commit copre anche i file di supporto, verificato
  da method sulla copia isolata del prototipo. Questo recepimento puntuale
  non avanza il cursore della revisione completa nel frontmatter.
- Ristrutturazione locale di `/manutenzione` (2026-10-25): nucleo con
  selezione dei rami, file interni e supporti condivisi; nessuna skill
  aggiunta al catalogo. Mappa ed evidenze nella cattura
  `i1/agent-experience-review-20261025.md`. La prescrizione
  `progettazione-skill` punti 4–6 è implementata e collaudata: il giro
  autonomo del 2026-11-04 ha esercitato gli ultimi rami e ha chiuso il task
  del collaudo. Con la separazione del 2026-11-04 i rami `lavoro` e
  `docker` sono passati a `example-org/nixos-ufficio`; restano `ia`,
  `home-manager`, `casa` e `world`, più `remoto` su `game` e `neve`.
- README orienta per intenti NixOS; CLAUDE conserva i guardrail prima degli
  atti sui tre host di casa: autorità sudo, seed dei segreti, Home Manager autonomo, push del solo branch corrente. La sua maggiore
  lunghezza è un vincolo di dominio; i dettagli restano nei nodi.
- `/kb` usa il protocollo comune e il profilo locale
  `.claude/skills/kb/domain.md`: inventario dal filesystem, ledger completo,
  fonti dichiarative e distinzione fra configurazione, generazione e runtime.
  Audit, facts e coverage non certificano l’utilità semantica né ogni invariante.
- Il fork `kb_tools.py` conserva inventory/facts/coverage (la facet `mondo` è
  uscita il 2026-11-05, a separazione fatta) e
  i controlli system/home; footer duplicati e link fuori dai nodi sono coperti.
- `/eval` distingue evidenza di una decisione da prova di un fatto esterno.
  Il codice dichiarativo è fonte primaria della configurazione; l’attivazione
  e lo stato degli host restano da osservare separatamente.
- `/kb`, `/commit`, `/eval`, `/exec` e `/manutenzione` conservano le estensioni
  NixOS. La skill canonica `adottanti` non è forkata. Gli strumenti di formato
  e il gate `o3/tools/check.sh` restano parte del contratto locale.
- `/eval`, `/exec` e `/commit` registrano l’esito per stadio col trailer
  `Esiti:` nel commit che chiude il giro, anche vuoto. `/manutenzione` resta
  fuori: è una skill di dominio autonoma, non uno stadio della tripartizione.
- `/eval interpret` riesamina le ipotesi raggiungibili da indici, fili e
  scadenze anche senza nuovi segnali; `compare` ne conserva il presidio
  prima di potare un filo. La lettura del boot dei server, primo caso, è
  passata con la coppia al repo `example-org/nixos-ufficio` il 2026-11-04.
- La facet di questo filo è `ciclo: dev`: confronta artefatti, non host attivi.
- `autonomy.md` in root istanzia la delega del ciclo (`ciclo-delegato`,
  impatto minimo medio; `confine-delega`) col perimetro NixOS deciso dal
  custode il 2026-10-09: dentro il ciclo solo gli atti che `CLAUDE.md` già
  consente senza chiedere; `ssh` agli altri host in sola lettura e senza
  `sudo` nel perceive; `sudo`, rebuild, reboot, produzione e atti su altri
  host restano fuori. `/method` e `/manutenzione` conservano i propri gate.
- I fork di `/eval` ed `/exec` hanno il gate «autorità prima dell'atto» e
  chiudono con `/commit`; il fork di `/commit` esegue i controlli senza
  domande rituali e porta i trailer `Autonomia:`/`Impatto:`/`Impatto-motivo:`.
- Presidio dei casi della delega: `eval perceive` (passo 3) cattura in `i1/`
  i casi metodologici emersi nell'uso, con stato «da inoltrare» o «acquisita
  da method» nell'indice; il resoconto di `/eval` ed `/exec` distingue
  decisioni autonome, conferme richieste e punti sospesi. Vive nei fork, non
  in questa prescrizione.
- Pull autonomo (`pull-autonomo`, custode in sessione il 2026-10-09):
  `git pull --ff-only` del branch corrente a working tree pulito, qui e nel
  checkout di `method`, in `CLAUDE.md` («Consentiti senza chiedere» e «Pull
  remoto»), nel passo 1 di `/method` e nel passo 1 di `/manutenzione`, che
  prima faceva un `git pull` nudo. Residuo di dominio: su `deck` il pull
  sposta `HEAD` e la path unit ripubblica le viste in LAN, quindi è un
  rilascio delle sole viste. Il custode ha scelto di dichiararlo invece di
  tenere il pull su richiesta; il sistema resta fuori, perché cambia solo con
  `home-manager switch` o `nixos-rebuild`. La frase «il push non è un
  rilascio» è diventata «il push non rilascia il sistema».
- Delega nel checkout servito (`delega-nel-checkout-servito`, custode in
  sessione il 2026-10-10): `~/nixos` è servito solo su `deck` (path unit
  sulle viste); nessun host esegue file dal checkout (`scriptsauto` e
  `controlp` eseguono `bi`). Nessuna eccezione nuova: `autonomy.md` nomina
  il checkout servito e rimanda all'eccezione condizionale già scritta in
  `CLAUDE.md` «Push remoto»; «Rilevamento host» chiede `hostname` prima
  del primo atto, pull compreso, e distingue il ruolo del checkout.
- Momento del commit (`momento-del-commit`, recepito il 2026-10-15): criterio
  in `autonomy.md` accanto a `ciclo-delegato` e precisazione nel gate di
  chiusura dei fork di `/eval` ed `/exec`. Residuo di dominio deciso dal
  custode: `/manutenzione` committa da sola il proprio esito, senza
  concordare il momento, perché è il centro del ciclo di `nixos` gestito in
  autonomia ed è il nucleo del ciclo autonomo di `deck` (criterio
  `ciclo-autonomo` in `autonomy.md`).
- Il fork `/commit` rilegge i trailer dopo il commit e corregge con amend solo
  prima del push; l'amend di commit pubblicati resta su richiesta
  (`CLAUDE.md`).
- `/cycle` è forkata con il wrapper Codex: verifiche del fork di `/commit` e
  categorie di `CLAUDE.md`. Il modo `autonomo` gira su `deck` dal
  2026-10-16, gradino 0, col criterio `ciclo-autonomo` e la voce in
  `o3/cicli.nix`.
- Prossimo task e ipotesi del giro (`prossimo-task-e-ipotesi-del-giro`,
  recepita il 2026-10-20): trailer `Prossimo:` nei fork di `/exec` (formato
  e confronto al passo 4 di `plan`), `/commit` e `/cycle` (trailer e
  resoconto); «Ipotesi formate nel giro» nel fork di `/eval interpret`.
  Adattamento: nixos non ha un registro delle ipotesi, il presidio è la
  sintesi `i2/` pertinente o un filo `i3/`
  con criterio. `o3/ciclo/prompt.md` non elenca il resoconto né i trailer
  del giro (solo quello di copertura) e resta com'è. `/manutenzione` non
  porta `Prossimo:`, come non porta `Esiti:`. Il primo giro dopo il
  recepimento dichiara la testa della coda `(confermato)`. Ritocco del
  2026-10-20 (`5ef45bb`) nello stesso paragrafo del fork: il giro rilegge
  ciò che ha scritto **o toccato**, distingue la derivazione (provenienza
  «derivato», `method/verdict.md`) dall'ipotesi, e il task `o2/` può
  rimandare a un'ipotesi ma non ospitarla.
- Ciclo autonomo (prescrizione `ciclo-autonomo`, chiusa nel canone il
  2026-10-28 perché recepita da tutti, `c1c40b3`): passi 1-4 diretti (skill
  `/cycle`, `o3/view/` con `--ciclo-unita`). Passi 5-8 nella forma del
  2026-10-19, scelta del custode in sessione: `o3/ciclo/prompt.md` e
  `o3/ciclo/permessi.json` spostati da `.claude/` con `git mv`, deny su
  `Edit`/`Write` di `o3/ciclo/**` nei permessi del giro, deny di
  `git add -f`/`--force` in `.claude/settings.json` (lo staging intero non è
  più negato dal 2026-10-21, `20156e0`), `/i1/giri/` in `.gitignore`. I
  percorsi comuni sono default del lettore `o3/modules/home/ciclo/registry.nix`,
  che aggiunge la protezione di `o3/ciclo`; `--ciclo-unita` segue `giri` non
  nullo. Adattamento motivato: lo switch home-manager nel giro rende la home
  scrivibile (`homeWritable`), scelta del custode; `o3/ciclo` resta in sola
  lettura sopra la home scrivibile. Giri riusciti dei quattro repo su deck in
  `i1/cicli-defaults-20261025.md`. Regola delle grafie (`e88d81f`) nel fork
  di `/cycle` dal 2026-10-27, con gli esiti della sonda su 2.1.311
  (`dd0cfb2`) e la clausola locale sull'heredoc del giro del 2026-10-27.
- Task e giro (canone `22ead2d`, `96314f5`, `369d5ea`, `48fff8d`, recepito
  su scelta del custode in sessione il 2026-11-02): il giro pianifica i task
  ma non li esegue, e ogni modifica a plan e task mossa da un fatto nuovo
  nomina la lettura `i2/` e il verdetto `i3/` che l'hanno mossa. Nei fork di
  `/cycle` («Durante il giro»), `/eval` (handoff), `/exec` (`plan.md`,
  `specify.md`, `perform.md`), in `autonomy.md` (`ciclo-autonomo`) e in
  `o3/ciclo/prompt.md` (sezione «Task»). Adattamento: gli atti ricorrenti del
  giro restano `/manutenzione` e `remoto`, che non sono task; i rimandi ai
  nodi passano dal symlink `method/`.
- Trailer del giro (`a1814f7`): `o3/ciclo/prompt.md` distingue «ciclo
  schedulato» da «avvio a mano» dall'orario della `partenza` in
  `i1/giri/tentativi.jsonl`, adattato al timer delle 04:30.
- Stadi del giro (canone `1516fa8`, da un caso di nixos, recepito il
  2026-11-07): `/cycle` invoca `eval all` ed `exec all` col tool Skill,
  `Esiti:` nomina solo gli stadi eseguiti, autovalutazione in stadi e
  procedura, attenzioni con memoria. Ogni stadio ha il suo minimo in fondo
  alla sezione del fork (`eval/SKILL.md`, `exec/plan.md`, `specify.md`,
  `perform.md`); il passo 4 di `perceive` lancia
  `python3 method/../o3/commit_gate.py stadi`. Adattamento:
  `o3/ciclo/prompt.md` aggiunge al minimo di `perceive` `/manutenzione`, le
  unità fallite e `kb_tools.py fidelity`, e non ripete i minimi canonici.
- Skill concesso al giro (canone `a3f6f1c`, recepito il 2026-11-07 col
  consenso del custode in sessione, perché tocca permessi e skill
  dell'agente): `o3/ciclo/permessi.json` concede `Skill(cycle)`,
  `Skill(eval)`, `Skill(exec)` e `Skill(commit)`; `/cycle` lo dichiara,
  porta la proposta di procedura in un task `o2/` e la riga `Attenzione`
  identica fra commit e resoconto; i sette wrapper `.codex/skills/` dicono
  che in Codex la lettura del `SKILL.md` vale come invocazione.
  `commit_gate.py stadi` lo accetta già: nixos lo consuma da
  `method/../o3/`. Il giro schedulato del 2026-11-08, il primo coi permessi,
  ha invocato `cycle`, `eval` ed `exec` col tool Skill senza dinieghi;
  `/manutenzione` resta letta dal suo `SKILL.md`, perché `Skill(manutenzione)`
  non è concesso e il prompt del giro non lo chiede.
- Visione d'insieme (canone `dfdbd1d`): passo 3c in `exec/plan.md` e voce
  nel resoconto di `/cycle`; le tendenze di dominio sono derive, unità
  fallite, versioni indietro e dinieghi.
- Chiusura dei rimandi (canone `6ae4974`, da un caso di nixos): la regola
  di chiusura in `exec/plan.md` nomina i registri di dominio, cioè
  `world.<titolo>` e `promosso` di `i1/manutenzione.json`, che il prospetto
  di `/manutenzione` segnala come orfani (`df6af83`); la legenda la
  verifica `build.py --check`.
- Finestre, traccia del giudizio e atti dopo `compare` (canone `21d4713`, da
  un caso di nixos, recepito il 2026-11-08 col custode in sessione). Nei fork
  di `/cycle`, `/eval` ed `/exec`. Adattamento: `/manutenzione` è divisa in
  fase diagnosi (`perceive`) e fase atti (`perform`); in sessione le due si
  compiono di seguito, e un ramo fermato dal verdetto non si registra.
  `o3/ciclo/prompt.md` tiene i gesti locali: tendenze da `tentativi.jsonl`,
  fatti con data e canale. La regola «rischio solo da fonte aperta» per
  browser e kernel è locale, in `/manutenzione`.
- Ricorrenze (canone `06938c0`, `f6d9a50`, da un caso di nixos, recepite il
  2026-11-08 col custode in sessione): sezione nel plan, parser e test in
  `o3/view/`, fork di `/eval` ed `/exec plan`. Adattamento: la sezione segue
  la legenda delle attese, che resta col suo titolo `## Task`. Il controllo
  con stati `dovuta` e `saltata` è `scadenze.py` del canone (voce seguente).
- `scadenze-nel-canone` recepita il 2026-11-08, col custode in sessione.
  Lo strumento si consuma da `method/../o3/scadenze.py` nei fork di `exec plan`
  ed `eval compare`, col solo permesso previsto in `o3/ciclo/permessi.json`.
  `maintenance-due.sh` ha perso il ramo dei `by:` e tiene registro, `probe:` e
  orfane. Il plan era già nella forma, senza `o3/scadenze.toml`.
- `uscita-dal-deck` recepita il 2026-11-08, col custode in sessione.
  Copia canonica in `o3/view/`; il test è in `o3/view/tests/`.
- `## Direzione` (canone `4e8325e`, `7d01c83`, recepito il 2026-11-09 col
  testo scelto dal custode in sessione): sezione in testa a `o1/plan.md`,
  confronto a ogni giro nel fork `exec/plan.md`, controllo in `sources.py`.
  Dichiara `nixos` a regime, con la pubblicazione del repo come fronte vivo.
- Atto fallito (canone `841a5d1`, nato dal bump di `nixos` del 2026-11-09,
  recepito lo stesso giorno): il principio sta nel fork di `/cycle`; controllo
  e comando per atto restano in `o3/ciclo/prompt.md`, oggi per il solo bump
  fallito in build con `flake.lock` cambiato (`8167598`).
- Il fork `/method` rilegge a ogni giro le prescrizioni aperte di `method`
  (passo 4) e le verifica nei file: `aligned` copre il delta dei commit e le
  prescrizioni aperte, non solo il primo.

## Adattamenti delle viste

- `o3/view/` è il canone: `build.py`, `publish.py`, `sources.py`,
  `build_pages.py`, `serve.py`, `assets/` e `ruff.toml` sono identici;
  anche `ciclo.py`, col campo `oggetto` acquisito dal canone (`f631d08`) e
  il prossimo task del giro (`218a025`, `5b89e17`), la storia git
  illeggibile dichiarata (`974d934`), il commit del giro non ancora nel checkout servito
  (`8f9af31`), la sezione «Da decidere» e `autonomy.md` come pagina
  (`789a324`) e `git` senza finestra su Windows
  (`2eeeb5e`, inerte qui). Le
  uniche parti locali sono quelle che il fork parametrizza per costruzione —
  `project.py`, la CONFIG delle descrizioni degli slot in
  `build_system_image.py` (descrizione locale di `o3`).
- Il deck vive in `presentation/presentation.md`, dichiarato in `DECK` e reso
  dal canone: dal 2026-10-31 niente builder di dominio né Mermaid, la
  topologia è la tavola `presentation/rete.svg`.
- `project.py`: sigla «NixOS», `LINGUA = "en"`, accento `#c2410c`,
  `CSS_LOCALI = ["nixos.css"]` (in `presentation/`: la tavola e i riquadri
  del deck), `ESCLUSE` vuota.
- I test vivono in `o3/view/tests/` (`test_build_pages.py`,
  `test_publish.py`, `test_ciclo.py`, `test_legenda.py`, `test_ricorrenze.py`, `test_uscita_deck.py`, `test_direzione.py`; il repo non ha `tests/` in root): differiscono dal
  canone solo per il path dei builder.
- `view/` è fuori da git (`.gitignore`), e `.gitattributes` porta solo la riga
  canonica `o3/view/**`. In locale `build.py` rende l'anteprima. Il gate di
  `/commit` e il contratto di `exec plan` usano `build.py --check`.
- Esposizione: le viste rendono ogni item delle sei collezioni, inclusi i log
  di boot in `i1/`. Rilette le fonti il 2026-10-04: hostname, IP privati e
  topologia, nessun segreto. La decisione del custode del 2026-10-03 resta
  com'è, e `CLAUDE.md § Comportamenti vincolati` nomina ora le viste
  pubblicate da commit.
- Servizio permanente: `deck` pubblica da commit pulito tutti i suoi repo,
  `method` (8001), `nixos` (8002), `salute` (8003) ed `economia` (8004),
  elenco `published` di `o3/presentations.nix`. Le viste di `bi` e
  `baserow` sulla production le dichiara dal 2026-11-04 il repo
  `example-org/nixos-ufficio`. La forma vecchia
  `presentation/` è uscita dal modulo, collaudata su tutti e tre gli host
  il 2026-10-15 (nessuna unit `-vista` residua).

## Prescrizioni aperte del canone

Rilette a `18a9f5a`: nessuna prescrizione aperta. La prescrizione del
lanciatore agli adottanti non è ancora nata
(`o2/lanciatore-ciclo-nel-metodo.md` di `method`, passo 3): `nixos` è previsto
per ultimo. Il primo giro del canone dal timer è partito il 2026-11-09;
la chiusura locale `5d068878` conferma commit, push e tree pulito, senza
anticipare la decisione sulla propagazione.

## Intervallo revisionato

`6aa4ea82222f5c3c289938f2eb87c97f2ea57521..47289138f25b703e6a4bfc8c3acdce2ad0402171`:
7 commit, revisionati il 2026-11-11.

- **Già soddisfatto:** `0eeb2db` e `dbe78b8`, l'esecutore Codex col solo
  recinto dell'host, letto dal canone; provati dal giro `5769c3c`.
  `10c09e7`, codice canonico dell'esecutore letto dal recinto.
- **Adattamento:** `4728913`, il runbook del giro a mano (sessione ferma,
  `start --wait`) in `kb/cicli.md`, «Sessioni concorrenti» e «Uso».
- **Non pertinente:** `da94452`, `dc6e902`, `dcadab3`, il profilo di method.

Prescrizione `motori-del-ciclo` riletta: recepita. A revisione chiusa, col
passaggio di tutti e quattro i cicli al lanciatore, `nixos` ha rimosso il
proprio percorso dell'host (`ciclo-avvio`, `ciclo-chiusura`,
`ciclo-namespace`, l'hook `ciclo-concorrenti`) e i campi del registro che
servivano solo a lui. I passaggi precedenti sono nella storia di questo file.

Verifiche della revisione: audit strutturale, inventory, facts, coverage,
fidelity e `o3/tools/check.sh` riusciti. Riletto il target dopo
l'aggiornamento del marker: intervallo vuoto.
