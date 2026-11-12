# Goal

Il motivo di `nixos` è tenere **due goal in tensione**: un sistema **snello,
semplice e minimalista** e insieme un'**affidabilità multi-host** dei tre
host di casa (replicabilità, servizi e mount che ripartono da soli) che
richiede ridondanza. L'artefatto bilancia il «meno» del minimalismo col «di
più» della resilienza: la tensione è informazione, non un difetto da
risolvere. Un terzo obiettivo, l'inferenza locale su `game`, non è un terzo
polo: è una capacità che mette alla prova entrambi, e ne dichiara la tensione.

## Obiettivi runtime

### 1. Sistema snello e minimalista

Zero dead code, DRY, nessuna configurazione manuale fuori dal repository,
workaround upstream solo temporanei e tracciati.

- **Deriva dal minimalismo sotto controllo** — ogni workaround upstream ha
  una condizione di rimozione e una dipendenza `w<n>` nel plan. Segnali: filo
  [workaround-desktop-upstream](i3/workaround-desktop-upstream.md), aggregato
  `kb_tools.py fidelity`, sorveglianza di `/manutenzione world`.
- **Solo casa, confine netto** — il repo descrive i tre host di casa e
  nient'altro. L'unico legame esterno è un client VPN di `deck`, con la sua
  identità in un file locale separato (`identity.work`). Segnali: i
  consumer di `identity.work` in questo repo.

### 2. Affidabilità multi-host

I tre host di casa restano replicabili e i loro servizi ripartono da soli.

- **Replicabilità piena dal repository** — ogni host si ricostruisce dal
  repository e dal seed dei segreti nella cassaforte personale, con una
  procedura provata; la cifratura in-repo è stata valutata e non adottata
  (custode, 2026-11-07). Segnali: inventario e decisione in
  [secrets-management](kb/secrets-management.md), ripristino in
  [post-installation](kb/post-installation.md), ricorrenza
  [prova annuale del seed](kb/secrets-management.md#prova-annuale-del-seed).
- **Servizi e mount affidabili** — mount e servizi ripartono in ordine e
  senza intervento manuale, anche dopo una manutenzione. Segnali:
  osservazione runtime dei mount e architettura in
  [rclone-gdrive](kb/rclone-gdrive.md), registro `i1/manutenzione.json`.

### 3. Inferenza locale su game

`game` serve modelli locali alla LAN — servizio stabile per i consumer
(OCR di `~/economia`, chat, batch su dati riservati) e banco di prova per
modelli e motori nuovi su hardware consumer — senza che i dati escano di
casa.

- **Servizio dichiarativo, sperimentazione reversibile** — segnali:
  catalogo `/models` di `game`, modelli in servizio, prove in corso e misure
  in [game-local-llm](kb/game-local-llm.md). Ciò che serve i consumer vive nel
  repo con pesi e sorgenti fissati per hash. Le prove stanno in area utente,
  fuori dal repo, con criteri fissati prima, e si smontano senza residui. Una
  prova entra nel servizio solo se vince sia sulla misura sia sulla qualità
  letta alla cieca dal custode, e se il suo costo di manutenzione (pacchetto
  proprio, fork, overlay) è dichiarato e accettato contro l'obiettivo 1. In
  tensione con l'obiettivo 1: la tensione si pesa caso per caso, non si
  risolve in anticipo.

I task che servono questi obiettivi si leggono dalla colonna `Ob.` di
[`o1/plan.md`](o1/plan.md); lo stato del lavoro vive nel plan e nei fili
`i3/`, non in questo register.

## Goal di sviluppo

Posizione auspicata lungo le dimensioni comuni
([development-goal](method/development-goal.md)): KB **fedele al sistema**
(facts/coverage/fidelity a drift zero), **governo operativo delegato
all'agente nei cicli avviati dal custode**, con supervisione degli esiti e
decisione umana su scopi, territorio e deleghe ([autonomia](autonomy.md)),
umano **in-the-loop** sui rebuild di sistema e sugli atti sugli host,
**basso attrito di lettura** (bussola snella, register dei poli, viste
generate). Segnali: `o3/tools/check.sh`, `kb_tools.py fidelity`,
`python3 method/../o3/view/build.py --root . --check`, filo
[allineamento-metodo](i3/allineamento-metodo.md), assetto delle viste in
`kb/deck-user-services.md` § Presentazione sulla LAN. Il lavoro è
raggiungibile dalla colonna `Ob. S` di [`o1/plan.md`](o1/plan.md).

## Disciplina

- Register del polo Goal, gemello di [`world.md`](world.md): il goal è il
  nord, il world è il territorio. Forma e contratto (l'intro è il polo che
  la home rende) in [goal](method/goal.md).
- Motivo, obiettivi e puntatori ai segnali; lo stato corrente vive nei fili e
  nel plan, le misure nelle fonti. Contratto in
  [goal-register](method/goal-register.md).
- Custode umano: custode. Gli agenti propongono scostamenti, non riscrivono
  il nord.
- Ogni obiettivo ha almeno un segnale vivo; ogni task di `o1/plan.md` serve
  un obiettivo di questo register — `/exec plan` verifica la direzione
  task→obiettivo, `/eval compare` la direzione obiettivo→segnale/filo.
- La direzione task→obiettivo vive nella colonna `Ob.` del plan, non in un
  elenco qui: la chiave è il **numero** dell'obiettivo runtime, `S` per il Goal
  di sviluppo ([plan](method/plan.md)). Numerazione stabile: rinumerare un
  obiettivo invalida le chiavi in tabella.
