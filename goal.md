# Goal

Il motivo di `nixos` è avere **computer di casa piacevoli da usare, puliti,
aggiornati e sicuri**, la cui configurazione sia comprensibile e
ricostruibile senza dipendere dalla memoria o da aggiustamenti nascosti.

Il progetto cura tre computer con ruoli diversi. Codice dichiarativo,
documentazione e manutenzione supervisionata servono quattro obiettivi:
**semplicità e pulizia, riproducibilità e controllo dei cambiamenti,
aggiornamento continuo e consapevole, sicurezza e riservatezza**.

## Obiettivi runtime

### 1. Semplicità e pulizia

Ogni componente ha un'utilità riconoscibile e un costo di manutenzione
accettabile. Ridurre ciò che bisogna ricordare, spiegare e mantenere:
evitare duplicazioni, togliere configurazioni inutilizzate e limitare patch,
pin e workaround locali.

- **Complessità sotto controllo** — le scelte comuni vivono nei moduli
  condivisi; le differenze degli host rispondono ai loro usi. Ogni workaround
  temporaneo ha una condizione di rimozione e un'attesa nel plan. Segnali:
  filo [workaround-desktop-upstream](i3/workaround-desktop-upstream.md),
  controlli di copertura e `kb_tools.py fidelity`.
- **Confine dichiarativo esplicito** — la configurazione necessaria all'uso
  ordinario è dichiarata; ciò che resta locale ha una ragione e, quando
  serve, una procedura di ripristino. Identità, segreti e prove in area
  utente non sono eccezioni da nascondere. Segnali:
  [configuration-patterns](kb/configuration-patterns.md),
  [secrets-management](kb/secrets-management.md),
  [client-desktop-architecture](kb/client-desktop-architecture.md).

### 2. Riproducibilità e controllo dei cambiamenti

Poter capire cosa è attivo su ciascun computer, ricostruirlo e tornare a una
configurazione precedente quando una modifica va male. I tre host hanno
ruoli distinti: non devono essere equivalenti né sostituirsi a vicenda.

- **Provenienza e attivazione verificabili** — distinguere commit,
  configurazione costruita e generazione attiva, sia per il sistema sia per
  la home. Ogni modifica ha controlli e una via di ritorno. Segnali:
  `o3/scripts/system-drift.sh`, `o3/scripts/home-drift.sh` e
  [development-workflow](kb/development-workflow.md).
- **Ripristino possibile e provato** — repository, identità locale e seed
  dei segreti completano la ricostruzione. Distinguere ciò che è predisposto
  da ciò che è stato effettivamente ripristinato. Segnali:
  [secrets-management](kb/secrets-management.md),
  [secret-inventory](kb/secret-inventory.md),
  [post-installation](kb/post-installation.md) e ricorrenza
  [prova annuale del seed](kb/secrets-management.md#prova-annuale-del-seed).

### 3. Aggiornamento continuo e consapevole

Tenere il software al passo senza trasformare ogni aggiornamento in un
piccolo progetto. Un ritardo è accettabile quando ha un motivo esplicito e
un momento di riesame; evitare arretrati inconsapevoli e pin dimenticati.

- **Novità, decisione e applicazione distinte** — sapere quali aggiornamenti
  sono disponibili, scegliere quando adottarli e verificare su quali host
  sono attivi. Un lock aggiornato o uno switch su deck non certificano gli
  altri computer. Segnali: registro [manutenzione](i1/manutenzione.json),
  `o3/scripts/maintenance-due.sh`, `o3/scripts/home-versions.sh` e derive
  di sistema e home.
- **Eccezioni presidiate** — rami, cadenze e pacchetti dedicati sono
  espliciti; gli aggiornamenti rinviati hanno motivo e riesame nel registro
  o nel task pertinente. Segnali: registro di manutenzione,
  [nix-flakes](kb/nix-flakes.md), attese di [plan](o1/plan.md) e
  [cicli](kb/cicli.md).

### 4. Sicurezza e riservatezza proporzionate alla casa

Mantenere il controllo su accessi, servizi esposti, credenziali e dati
personali. Ogni servizio o accesso aggiuntivo ha una ragione; la protezione
va valutata insieme al suo costo e alla praticità d'uso.

- **Accessi ed esposizione intenzionali** — chiavi autorizzate, peer VPN,
  servizi e regole firewall corrispondono agli usi voluti. La rete di lavoro
  è un territorio separato: qui si configura soltanto il collegamento di
  deck. Segnali: configurazione degli host e dei moduli di rete,
  [network-architecture](kb/network-architecture.md),
  [ssh-matrix](kb/ssh-matrix.md), [wireguard-home](kb/wireguard-home.md).
- **Identità, segreti e pubblicazione sotto controllo** — dati locali e
  credenziali hanno fonti, percorsi e consumatori espliciti; codice pubblico
  e viste rispettano il proprio perimetro. Segnali:
  [secret-inventory](kb/secret-inventory.md),
  [secrets-management](kb/secrets-management.md), gate privacy e
  [deck-user-services](kb/deck-user-services.md).
- **Limite della misura esplicito** — questi segnali coprono aspetti
  specifici, non certificano un sistema sicuro nel suo insieme. Il confronto
  con vulnerabilità note e la verifica runtime completa di accessi ed
  esposizione non hanno oggi una misura aggregata: il buco di copertura va
  dichiarato quando si valuta questo obiettivo. Aggiornamento e sicurezza
  restano distinti; una versione recente non prova da sola la sicurezza.

## Usi del sistema e affidabilità quotidiana

Desktop, rete, mount e strumenti abituali devono funzionare dopo l'avvio e
la manutenzione. Questa affidabilità è un requisito trasversale dei quattro
obiettivi; non implica ridondanza o sostituzione automatica fra computer.
Segnali: unità fallite e journal degli host,
[rclone-gdrive](kb/rclone-gdrive.md),
[syncthing-architecture](kb/syncthing-architecture.md) e riscontri d'uso.

Gaming, lavoro personale, media, OCR, chat e trascrizione sono usi da
servire. L'AI locale su game è una capacità del sistema: infrastruttura e
modelli in servizio sono descritti in
[game-local-llm](kb/game-local-llm.md) e
[game-live-transcription](kb/game-live-transcription.md). Le prove in area
utente restano reversibili. Una prova entra nella configurazione ordinaria
quando il beneficio è verificato e il suo costo di manutenzione è accettato
contro i quattro obiettivi, considerando anche il contesto d'uso e la qualità
valutata dal custode.

Le tensioni si pesano caso per caso: aggiornare può introdurre regressioni,
sperimentare può aggiungere complessità, proteggere può rendere meno comodo
un accesso. Nessuno di questi compromessi giustifica da solo una scelta.

## Goal di sviluppo

**Ridurre il tempo e l'attenzione necessari alla manutenzione, conservando
comprensione e controllo delle decisioni.** La delega agli agenti e il
ciclo autonomo sono strumenti per questo risultato, valutati sul lavoro
utile assorbito e sulla leggibilità degli esiti.

La KB resta fedele alla configurazione e distingue il dichiarato dal
verificato. Piano, documentazione e viste permettono di capire cosa c'è,
perché c'è e cosa richiede una decisione. L'agente conduce gli atti delegati;
il custode conserva scopi, territorio, condizioni della delega e gli atti
riservati da [autonomy](autonomy.md).

Segnali: `o3/tools/check.sh`, `kb_tools.py fidelity`, verifica della build
delle viste, filo [allineamento-metodo](i3/allineamento-metodo.md),
resoconti e chiusure del ciclo in `i1/giri/` (costo, durata, dinieghi,
questioni aperte). L'esito di un'automazione conta più del numero di giri o
di commit. Il lavoro di sviluppo è raggiungibile dalla colonna `Ob. S` del
plan.

## Disciplina

- Questo register dichiara motivo, obiettivi e puntatori ai segnali;
  `world.md` descrive il territorio. Forma in
  [goal-register](method/goal-register.md).
- Stato corrente, misure e lavoro aperto restano nei fili, nei registri e
  nel plan. Un controllo deterministico riuscito non dimostra da solo il
  raggiungimento di un obiettivo.
- Il custode decide il nord; gli agenti propongono cambiamenti e valutano
  gli esiti entro la delega vigente.
- Ogni obiettivo ha un segnale raggiungibile o un buco di misura esplicito.
  Ogni task e ricorrenza del plan dichiara l'obiettivo servito nella colonna
  `Ob.`: numero runtime oppure `S` per il Goal di sviluppo.
- Le chiavi degli obiettivi sono stabili per i lettori correnti. Quando un
  obiettivo cambia significato, si riesaminano task, ricorrenze e fili che
  lo citano; le valutazioni storiche si leggono contro il Goal del loro
  commit.
