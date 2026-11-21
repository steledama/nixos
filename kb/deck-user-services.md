---
stato: maturo
---

# Deck user services

Servizi utente permanenti con cui `deck` espone alle sole reti private di
casa le viste generate dei repo e la PWA delle misure pressorie. Sono unità
`systemd --user` del profilo `stele@deck`, tenute vive dal lingering, e si
gestiscono senza sudo. Porte e repo vivono in due registri, `o3/presentations.nix`
e `o3/pressione.nix`, letti sia dai moduli home sia dal firewall di `deck`.

## Presentazione sulla LAN

Decisione del custode (2026-10-03): ogni progetto ha un host privilegiato che
ne serve in modo permanente le viste generate alle sole reti private, e
`python3 method/../o3/view/serve.py --root .` lanciato a mano ascolta per default sulla
porta 8000. Repo e porte vivono in un solo registro, `o3/presentations.nix`
(`deck`: `method` 8001, sito del gruppo `casa` 8002). Le
viste di `bi` e `baserow` su `svezia` le dichiara il repo
`example-org/nixos-ufficio`. Il modulo home `o3/modules/home/presentations.nix` ne
genera un servizio utente `presentazione-<repo>` per ogni repo con porta propria
e `presentazione-gruppo-<istanza>` per ogni sito di gruppo. Per un repo fuori
dalla forma pubblicata il servizio lancia `o3/view/serve.py --port` dal
checkout e resta saltato se manca `view/index.html`: dal 2026-10-07 nessun
repo è in questa forma e il ramo è inerte. La forma vecchia `presentation/`
(prescrizione di metodo `migrazione-viste`), con il suo wrapper e le unit
`-vista`, è uscita dal modulo il 2026-10-07. Si gestiscono senza sudo:

```bash
systemctl --user status 'presentazione-*'
systemctl --user restart presentazione-gruppo-casa
```

**Sito di gruppo** (canone `kb/view-publishing.md § Sito di gruppo`, voce
`groups` del registro). `presentazione-gruppo-casa` lancia dal checkout
`~/casa` `serve.py --gruppo ~/.local/state/view --istanza casa --port 8002`:
`/` è la home del gruppo, `/<repo>/` la vista pubblicata di un membro.
I membri (`nixos`, `salute`, `economia`) li dichiara `## Membri` nel
`world.md` di `casa`, riletto dalla sua versione pubblicata; nel registro
sono i repo di `published` senza porta propria, e la coerenza la controlla
`/adottanti` di method. I membri tengono la propria unità di pubblicazione,
non un server. `ExecCondition` su `--check` salta il sito finché `casa` non
ha una versione valida; ogni pubblicazione, di qualunque repo, lo avvia se
saltato o lo riavvia se l'impronta di `o3/view` è cambiata, quindi i timer
delle pubblicazioni ne sono anche l'innesco periodico.

**Forma pubblicata** (prescrizione di metodo `viste-fuori-da-git`, elenco
`published` del registro: tutti i repo di `deck`, cioè `method`, `casa`,
`nixos`, `salute` ed `economia`). Le viste non si
servono più dal checkout ma da una cartella di pubblicazione fuori dal
working tree, `~/.local/state/view/<repo>`. La unit oneshot
`presentazione-<repo>-pubblicazione` lancia `build.py --publish` dal
checkout, con `git`, `pandoc`, `prettier` e `python3` presi dal flake e non
dal profilo. Il build parte dal commit di `HEAD` esportato con
`git archive`, quindi le modifiche locali non entrano, e il puntatore
`current` si sposta solo a build riuscita. `presentazione-<repo>` lancia
`serve.py --publish-root` e rilegge il puntatore a ogni richiesta, quindi uno
scambio di versione non chiede riavvii.

- **Codice del server.** I repo migrati eseguono i builder e il server da
  `~/method/o3/view/` con `--root .`; quelli con builder locali continuano
  a usarli fino al proprio `/method`. L'impronta del server comprende
  entrambi gli alberi committati `o3/view`, dell'adottante e del canone:
  dopo la pubblicazione un cambio riavvia il server con `try-restart`.
  Il timer limita il ritardo. La versione pubblicata di un repo migrato
  dichiara in `provenance.json` sia il commit locale sia quello di method;
  l'avanzamento del canone richiede una nuova build. Un riavvio del server
  esegue i file presenti nel checkout, incluse eventuali modifiche locali.

- **Innesco.** La path unit `presentazione-<repo>-pubblicazione.path` osserva
  `.git/logs/HEAD` del repo e di `method`. Ogni spostamento di `HEAD` (commit, checkout, un pull)
  la fa scattare. Un `git fetch` non la fa scattare, e nessuna unit fa fetch
  o pull (decisione del custode del 2026-10-07): il
  pull lo fa il custode o l'agente in sessione, che dal 2026-10-09 lo esegue
  senza richiesta (`CLAUDE.md` «Pull remoto») e così ripubblica le viste. Un commit che arriva durante una build lo raccoglie
  `publish.py` nello stesso giro. Resta però una finestra di qualche
  millisecondo: tra l'ultimo controllo di `HEAD` di `publish.py` e la fine
  della oneshot (`ExecStartPost`) la path unit non è riarmata, e
  `PathChanged` non recupera il cambio (osservato e riprodotto il
  2026-10-07).
- **Controllo periodico.** Accanto alla path unit, che resta l'innesco
  rapido, il timer `presentazione-<repo>-pubblicazione.timer` avvia la
  stessa oneshot ogni 5 minuti dalla sua ultima chiusura
  (`OnUnitInactiveSec`), e 5 minuti dopo l'avvio del gestore utente
  (`OnStartupSec`). Il giro è
  idempotente: con `HEAD` già servito `publish.py` risponde «già servito» in
  un decimo di secondo, senza costruire. Recupera il cambio perso dalla path
  unit e ritenta una build fallita, entro un intervallo più l'`AccuracySec`
  predefinito di 1 minuto (canone `method/view-publishing.md`). A mano:
  `systemctl --user start presentazione-<repo>-pubblicazione`.
- **Avvio e recupero.** La pubblicazione è anche `WantedBy=default.target`,
  e il server la ordina prima di sé con `Wants`/`After`. Al login si
  ripubblica quindi un output arretrato prima di servire. Se la build
  fallisce, il server parte comunque sull'ultima versione buona e l'errore
  si legge su `http://deck:8001/_stato`.
- **Switch Home Manager.** Ogni `home-manager switch` rilancia le
  pubblicazioni, anche quando la generazione non cambia: la oneshot non ha
  `RemainAfterExit`, quindi a riposo è `inactive`, e l'attivazione avvia le
  unit `WantedBy=default.target` che trova ferme (osservato il 2026-10-19 a
  generazione invariata: `Result=success`, server delle viste mai fermati).
  Con `HEAD` già servito il giro è il «già servito» idempotente; se
  `o3/view` è cambiato, la pubblicazione riavvia il server (`try-restart`,
  sopra). Uno switch non è quindi neutro per le viste, anche quando la home
  non cambia.
- **Nessuna versione valida.** `serve.py` esce con 3, distinto dall'1 di un
  crash qualsiasi. L'`ExecCondition` lancia `serve.py` con `--check`:
  l'uscita 3 lascia il server saltato, non fallito, senza riavvii, con la
  diagnosi e `status.json` nel journal. Se la versione
  sparisce mentre il server gira, `RestartPreventExitStatus=3` evita il
  ciclo di riavvii. La prima pubblicazione riuscita lo avvia da sé
  (`ExecStartPost`).
- **Interruzione.** Uno stop o il timeout di 5 minuti della oneshot mandano
  SIGTERM. `publish.py` chiude il giro senza lasciare `.lock` né `.partial`,
  e la versione servita resta.

```bash
journalctl --user -u presentazione-method-pubblicazione -n 20
curl -s http://localhost:8001/_stato
```

Il firewall ammette le porte delle presentazioni solo dalle reti private, e
le ricava dallo stesso registro:

- **tutti gli host** (`deck`, `game`, `neve`) — 8000 dalla LAN casa
  `192.168.0.0/24` (`o3/hosts/default.nix`). I peer della VPN
  casa raggiungono `game` e `neve` mascherati dal NAT di deck, quindi con la
  sua sorgente LAN: per loro basta la regola LAN;
- **`deck`** — in più 8001-8002 dalla LAN casa e 8000-8002 dalla VPN casa
  `10.20.0.0/24`, così ci arrivano anche `norvegia` e il telefono
  (`extraCommands` dell'host).
  La rete pubblica non è mai ammessa; senza un server sulla porta non ascolta
  nessuno.

Stato: `deck`, `game` e `neve` hanno regole, rotta e servizi attivi dal
2026-10-03.

## Inserimento delle misure pressorie su deck

La PWA di `~/salute/o3/pressione/` è servita dall'unità utente permanente
`pressione-salute`, installata dal profilo `stele@deck`. Porta TCP 8010 e
nome della cartella di stato sono registrati in `o3/pressione.nix`, letto
dal modulo home `o3/modules/home/pressione-salute.nix` e dal firewall di
`deck`: ammesse solo LAN casa `192.168.0.0/24` e VPN casa `10.20.0.0/24`.
Nessuna apertura generica né forwarding sul router.

Il servizio esegue `python3 o3/pressione/serve.py --port 8010` dal checkout
`~/salute`, con casella esplicita `%S/pressione-salute/inserite.jsonl` e
`StateDirectory=pressione-salute`. Il checkout è in sola lettura nel
servizio; `PYTHONDONTWRITEBYTECODE=1` evita anche i file Python compilati.
La cartella ha permessi 0700, la casella 0600, proprietario `stele`.
Una sessione di salute, con lo stesso utente, legge la casella senza
ulteriori permessi; salute non ha ciclo autonomo. Il server non importa
misure nel repository e non fa commit; l'importazione compete a salute.
Il lingering di `stele`, già configurato su deck, mantiene il servizio
anche senza sessione aperta.

Dal telefono:

- su Wi-Fi casa: `http://192.168.0.10:8010/`;
- su rete mobile con VPN casa attiva: `http://10.20.0.1:8010/`;
- aggiungere il collegamento alla schermata Home dal browser. In HTTP il
  service worker resta inattivo; HTTPS è un eventuale secondo passo.

Verificato il 2026-10-20: unità abilitata e attiva, pagina HTTP 200 in
loopback, casella creata con i permessi previsti. Le due regole firewall
sono nella configurazione attiva di `deck` (sistema allineato a `HEAD` dopo
il rebuild del 2026-11-11). Il collaudo da telefono su LAN e VPN non è
registrato in questo repo: l'uso delle misure e la loro importazione
appartengono a `salute`.

```bash
systemctl --user status pressione-salute
journalctl --user -u pressione-salute -n 20
```

Connessioni:

- [network-architecture](network-architecture.md)
- [home-manager](home-manager.md)
- [wireguard-home](wireguard-home.md)
