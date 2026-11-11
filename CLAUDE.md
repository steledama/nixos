# CLAUDE.md

Costituzione operativa per agenti che lavorano su questo repository NixOS multi-host. Contiene solo regole d'azione: la conoscenza di dominio (architettura, host, servizi, pattern, comandi) vive nei nodi `kb/`. Quando un'istruzione qui rimanda a un nodo, leggi il nodo prima di agire.

## Separazione da lavoro

Fino al 2026-11-04 questo era il repo unico di casa e lavoro. Il custode ha
deciso di separarlo: casa resta qui, la coppia server `norvegia`/`svezia`
passa a `example-org/nixos-ufficio`. Lo stesso giorno i checkout `~/nixos` dei due
server sono passati al repo di lavoro, a sistema invariato, e questo repo è
stato potato di output, moduli, nodi KB, skill e procedure dei server.

La divisione è chiusa dal 2026-11-05; gli accessi e i checkout incrociati
restano per decisione del custode del 2026-11-04 (storia di `goal.md`).
Leggi in quest'ottica ciò che ancora nomina i server:

- è un residuo o un legame dichiarato (la VPN ufficio di `deck`, gli alias
  SSH, la VPN casa dello standby), non un invito ad agire: il lavoro sui
  server si fa in `example-org/nixos-ufficio`. Modificare quel repo dal suo
  checkout su `deck` (`~/nixos-lavoro`) non è un atto sui server ed è
  ammesso; gli atti sui server restano alle sessioni lì;
- un'istruzione che presuppone ancora il repo unico va verificata prima di
  applicarla; nel dubbio chiedi al custode.

## Rilevamento host

Esegui `hostname` all'inizio di ogni sessione, prima del primo atto e quindi anche prima del pull. Host validi: `deck`, `game`, `neve`. `norvegia` e `svezia` non sono più target di questo repo dal 2026-11-04 (§ Separazione da lavoro). Menziona l'host rilevato nel primo aggiornamento dopo il rilevamento. Usalo come target predefinito per rebuild e comandi host-specifici, salvo override esplicito. Se l'utente dice "questo sistema" o "qui" senza specificare, vale l'host rilevato.

L'host distingue anche il ruolo del checkout: su `deck` `~/nixos` è servito, perché la path unit ripubblica le viste in LAN a ogni spostamento di `HEAD`; sugli altri host nessun processo esegue o pubblica i suoi file. La delega del ciclo vale in entrambi i casi (`autonomy.md`).

## Bootstrap di sessione

Dopo il rilevamento dell'host, in quest'ordine:

1. `README.md` — la bussola: orientamento, host, accessi cognitivi; `o1/plan.md` per i task aperti
2. `CLAUDE.md` — questo file: vincoli operativi e confini di autorità; `autonomy.md` per la delega del ciclo
3. nodo KB tematico pertinente al cambiamento richiesto

La root contiene le collezioni `i1/`–`i3/` e `o1/`–`o3/`, ciascuna col proprio
indice, più `kb/`, `presentation/` (il deck), `view/` (le viste generate, non versionate) e i register `goal.md` e `world.md`. Il
cruscotto è `o1/plan.md` con i fili pertinenti in `i3/`; catalogo, register e
altre collezioni si aprono quando servono. Gli item delle collezioni dichiarano
`ciclo: dev|runtime`.

La forma di `o1/plan.md` (tabella per esecuzione, identità per titolo, footer)
vive nel nodo `method/plan.md`: il file non la ripete e si auto-spiega quando letto.

## Identità del flake

Il flake senza override usa esempi pubblici. Per valutare, costruire o
attivare la configurazione reale usare `o3/scripts/con-identita.sh` davanti
a `nix`, `home-manager` o `sudo nixos-rebuild`; il wrapper richiede
`~/.config/nixos/identity/` e non scrive l'override nel lock. Non leggere o
pubblicare i valori reali nei resoconti. Update e controlli dei template
usano il lock pubblico. Bootstrap: `o3/identity/README.md`.

## Cosa Claude può eseguire autonomamente

Regola unica: se il file modificato vive in `o3/modules/system/` o `o3/hosts/`, è system-level → chiedi all'utente di rebuildare. Se vive in `o3/modules/home/` o `o3/home/`, è home-manager-level → esegui direttamente con `o3/scripts/con-identita.sh home-manager switch --flake .#user@host`.

Categorie di comandi:

- **Consentiti senza chiedere** (non-sudo, area utente): `home-manager switch`, `systemctl --user`, `git status/add/commit`, `git pull --ff-only` del branch corrente a working tree pulito (anche nel checkout di `method`), `git push` del branch corrente su `origin` dopo ogni commit riuscito, `nix flake update`, `nix-collect-garbage --delete-old`, `o3/tools/check.sh` (anche `--flake`), operazioni su file in directory utente; da `deck`, `remoto stato|allinea` su `game` e `neve` (criterio `atti-remoti` di `autonomy.md`; i server li rifiuta dal 2026-11-04).
- **Richiedono autorizzazione esplicita**: ogni comando con `sudo` (`nixos-rebuild`, `systemctl` di sistema, `nix-collect-garbage -d`), push di altri branch, `amend` di commit già pubblicati, operazioni distruttive (`reset --hard`, force push, `branch -D`).

Procedure complete: `kb/common-commands.md`. Workflow git (commit → rebuild → rollback): `kb/development-workflow.md`.

## Delega del ciclo

Leggere [`autonomy.md`](autonomy.md) prima di operare: il ciclo avviato dal
custode (`/eval`, `/exec`, ciclo congiunto) prosegue entro la delega fino a
verifiche, commit e push, senza conferme intermedie sugli esiti ordinari.
Chiedere sui punti riservati e continuare il lavoro indipendente. La delega
non estende sudo, rebuild, reboot né atti su altri host: valgono le categorie
qui sopra. La presenza in chat non è ratifica preventiva delle decisioni
dell'agente. Il giro senza custode segue il criterio `ciclo-autonomo` di
`autonomy.md` (gradino 1 su `deck` dal 2026-10-17, timer alle 04:30).

## Comunicazione fra sessioni con Herdr

Quando il custode chiede di passare un messaggio a un'altra sessione aperta,
usa Herdr, non gli strumenti di messaggistica interni all'harness. Leggi il
protocollo nel nodo [`session-messaging`](method/session-messaging.md).

Il messaggio si dichiara inoltrato dalla sessione nixos e conserva regole e
autorizzazioni della sessione destinataria. Il collegamento non estende la
delega su altri repo, host, sudo o rebuild.

## Skill

Una skill non è un task: è una capacità permanente e versionata, non entra
negli indici di lavoro futuro (`o1/plan.md`, `o2/`). Se il workflow che
orchestra è ricorrente, la ricorrenza vive in `## Ricorrenze` di `o1/plan.md`
(forma in `method/plan.md`, «Ricorrenze»), non in un task che si
riapre da solo; una skill multi-scope porta **una riga per ricorrenza** —
l'orologio appartiene alla porzione di mondo servita, non allo strumento. Se
l'esecuzione è automatizzata da uno scheduler, la sua configurazione
versionata è la fonte di verità e `Prossima` vale `config`. Quando le porzioni
di mondo si moltiplicano oltre poche righe leggibili (entità con ricorrenze
proprie, non solo scope), la cadenza migra in **config dichiarativa per
entità** accanto alla skill, e `## Ricorrenze` tiene solo il polso aggregato —
cfr. `/manutenzione`, compresa nella riga del ciclo autonomo, cadenze per
ramo/task in `i1/manutenzione.json`.
L'inventario vivo è l'`ls` di `.claude/skills/` (wrapper Codex in
`.codex/skills/`); l'elenco qui è il bootstrap di sessione. Cfr.
`method/skill.md`.

**Skill di metodo** (quartetto canonico, `/cycle` che ne compone il giro e
`method`, forkate dal canone):

- `/eval [perceive|interpret|compare|all]` — il braccio di valutazione: raccolta del grezzo dal sistema in esecuzione (i1), sintesi con provenienza e cascata (i2), verdetto dei fili contro `goal.md` e bonifica del plan (i3)
- `/exec [plan|specify|perform|all]` — il braccio di esecuzione: coda e priorità (o1), qualità interna dei task (o2), supervisione della collezione e atti autorizzati (o3)
- `/kb [audit|review]` — audit deterministico o revisione semantica profonda
  della KB (diagnosi, non corregge; capacità trasversale ai due archi)
- `/commit` — gate di filing back prima di fissare le modifiche nella storia
- `/cycle [autonomo]` — il ciclo congiunto: `eval all` → `exec all` → `/commit`, in sessione o come ciclo autonomo su `deck` (criterio `ciclo-autonomo`, gradino 1)
- `/method` — drift rispetto ai commit del repo canonico `method` (marker in `i3/allineamento-metodo.md`: cfr. `.claude/skills/method/SKILL.md`)

**Skill di dominio** (locale al progetto, **autonoma**: il pilota del
montaggio 2026-08-01 non l'ha assorbita come argomento delle canoniche —
dichiara la propria mappa di stadi in testa al file):

- `/manutenzione [ia|home-manager|casa|world|all]` — punto sugli aggiornamenti disponibili per il ramo scelto (default `all`) e valutazione se e come aggiornare; esegue in autonomia i rami `ia` e `home-manager` (input omonimo) e i bump di pacchetti overlay home-level (es. `gogcli`), diagnostica su `casa` (inclusi i bump di pacchetti overlay system-level: versione upstream, hash sorgente/vendor, eventuale patch toolchain minimale, build/test — l'attivazione via `nixos-rebuild` resta un atto separato autorizzato) e sorveglia il debito upstream tracciato (`world`, righe `Dip.: w<n>` di `o1/plan.md`). Attraversa entrambi gli archi: è il ramo a determinare l'arco, non chi invoca. Assorbe l'ex skill `/overlay` (fusa qui il 2026-08-02: la diagnosi "c'è un pacchetto overlay da aggiornare" e l'esecuzione del bump vivevano in due skill separate senza necessità)

## Strumenti

Per ogni intento ricorrente, lo strumento da usare con il comando minimo sicuro e il nodo di approfondimento. La reference completa vive nei nodi.

- **review locale pre-commit (no sudo)** — `o3/tools/check.sh`
  - Comando minimo: `o3/tools/check.sh` (`--flake` aggiunge `nix flake check`)
  - Approfondimento: `kb/development-environment.md`
- **audit strutturale KB** — `kb_tools.py audit`
  - Comando minimo: `python3 o3/tools/kb_tools.py audit --format markdown`
  - Approfondimento: `method/kb-tools.md`
- **attributi di dominio** — `kb_tools.py facets`
  - Comando minimo: `python3 o3/tools/kb_tools.py facets` (verifica la facet `ciclo: dev | runtime` sugli item di collezione; l'audit la integra come problemi `[FACET]`. La facet `mondo` è uscita il 2026-11-05, a separazione fatta)
  - Approfondimento: `method/node.md`
- **fatti KB vs filesystem** — `kb_tools.py facts`
  - Comando minimo: `python3 o3/tools/kb_tools.py facts`
  - Approfondimento: `method/cognitive-fidelity.md`
- **copertura host, moduli e wrapper CLI** — `kb_tools.py coverage`
  - Comando minimo: `python3 o3/tools/kb_tools.py coverage`
  - Approfondimento: `method/cognitive-fidelity.md`
- **aggregato drift** — `kb_tools.py fidelity`
  - Comando minimo: `python3 o3/tools/kb_tools.py fidelity`
  - Approfondimento: `method/cognitive-fidelity.md`
- **switch home-manager (autonomo)** — `home-manager`
  - Comando minimo: `o3/scripts/con-identita.sh home-manager switch --flake .#user@host`
  - Approfondimento: `kb/home-manager.md`
- **rebuild sistema (richiede autorizzazione)** — `nixos-rebuild`
  - Comando minimo: `sudo nixos-rebuild switch --flake .#<host>`
  - Approfondimento: `kb/nixos-rebuild.md`

Formatter e controlli prima di ogni commit li lancia il gate di `/commit`,
sui soli file cambiati: `python3 method/../o3/commit_gate.py prima`, col
profilo `o3/commit_gate.toml` (`alejandra`, `ruff format`, `prettier`,
`o3/tools/check.sh`, `build.py --check`, i test dovuti).

## Convenzioni di scrittura

- **Commit**: Conventional Commits, dettagli in `kb/development-workflow.md § Commit conventions`. La skill `commit` applica formatter e convenzioni come default.
- **Nuovi nodi KB**: struttura, frontmatter e footer Connessioni in `method/node.md`. Il frontmatter dei nodi nixos porta `stato` (nessun campo `data`: le date vivono in git; la facet `mondo` è uscita il 2026-11-05 col suo scopo, lo split dei repo). Prima di creare un nodo nuovo verificare se un nodo esistente può essere arricchito (`method/cognitive-artifact-design.md § Regole di revisione`).
- **Modifiche architetturali**: aggiornare in place il filo pertinente in
  `i3/` quando cambia il verdetto (un file per filo, indice `i3/verdicts.md`);
  la cronologia resta in Git (`method/verdict.md`).
- **Naming di input, opzioni e interfacce**: identificatori di codice Nix in inglese, nomi runtime che l'utente digita e vocabolario di dominio in italiano. Regola e razionale: `kb/configuration-patterns.md § Vocabolario dei nomi`.
- **Naming dei file pilastro**: distinzione UPPERCASE (auto-caricati) vs lowercase (su richiesta) in `method/project-structure.md`.

## Comportamenti vincolati

- **Secrets**: `.env`, `rclone.conf` e chiavi private sono gitignored. Mai committarli. Mappa completa dei segreti del progetto: `kb/secrets-management.md`.
- **Presentazione sulle reti private**: decisione del custode del 2026-10-03, canone `method/presentation.md § Vincolo conservato`. `serve.py` a mano ascolta sulla 8000 su ogni host; `deck` serve in modo permanente `nixos` sulla 8002 (e `method`, `salute`, `economia` sulle 8001, 8003, 8004). Solo reti private, mai la rete pubblica. Il server è senza autenticazione e, una volta permanente, espone in modo continuo le viste pubblicate da commit: lì entrano le pagine 1:1 di register e di ogni item delle sei collezioni e il deck, con hostname, IP privati e topologia delle reti, mai segreti, chiavi, password o contenuti di `.env`/`rclone.conf`. Servizi utente, firewall, rotta statica e stato del collaudo: `kb/network-architecture.md § Presentazione sulla LAN`.
- **Pacchetti unfree**: dichiarazione esplicita in `unfree.allowedNames` (nel modulo che installa il pacchetto) con commento `# UNFREE:`; il predicate vive solo in `o3/modules/system/unfree.nix`. Lista corrente per host: `kb/unfree-packages.md`.
- **Push remoto**: dal 2026-10-08 il custode autorizza il push del branch
  corrente su `origin` dopo ogni commit riuscito. Restano su richiesta
  esplicita `--force`, `amend` di commit già pubblicati e il push di altri
  branch; un push rifiutato non si forza, ci si ferma e si riferisce. Il
  push non rilascia il sistema: nessun processo degli host fa `pull` da
  solo (la pubblicazione delle viste costruisce l'`HEAD` del checkout
  locale, mai un fetch) e nessun host ha `autoUpgrade`. Se un ciclo
  automatico iniziasse a fare `pull` ed eseguire, il push tornerebbe su
  richiesta finché il custode non sceglie. `remoto allinea`
  (2026-10-19) non è questo caso: lo switch parte dall'albero che `deck`
  invia, e il `pull --ff-only` che segue porta solo il checkout al commit. `sudo` e `nixos-rebuild` restano sotto
  le loro regole.
- **Pull remoto**: dal 2026-10-09 il custode autorizza senza richiesta
  `git pull --ff-only` del branch corrente da `origin`, a inizio sessione,
  prima di un giro e quando un confronto trova il checkout indietro, solo a
  working tree pulito. Vale per questo repository e per il
  checkout di `method` letto dal symlink; per i checkout di altri repository,
  dove può lavorare un'altra sessione, bastano `fetch` e `origin`. Con
  modifiche locali o branch divergente non si fa merge né rebase: ci si
  ferma e si riferisce. Il pull dell'agente aggiorna il checkout e, dove il
  repo è in `published` di `o3/presentations.nix` (oggi su `deck`), ripubblica
  le viste servite in LAN tramite il path unit su `.git/logs/HEAD`: è un
  rilascio delle sole viste, di contenuto già committato e pushato, scelto
  dal custode il 2026-10-09. Non cambia mai il sistema, che si aggiorna solo
  con `home-manager switch` o `nixos-rebuild` sotto le loro regole.

## Tabelle vs elenchi

Le tabelle markdown sono illeggibili su schermi stretti (mobile): preferire elenchi puntati per confronti e liste di voci. Eccezione: `o1/plan.md` (forma tabellare canonica, cfr. `method/plan.md`).

## Dove cercare la conoscenza di dominio

L'instradamento per intento — architettura, livelli di configurazione, rete e
VPN, servizi, sync, setup e recovery — vive nella sezione «Se devi…» di
`README.md`, che è la bussola. Qui non se ne tiene una seconda copia: due
router per lo stesso intento divergono in silenzio, e questo file contiene
regole d'azione, non conoscenza di dominio.
