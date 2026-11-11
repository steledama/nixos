---
stato: maturo
---

# Secrets management

Mappa dei segreti del progetto e delle scelte architetturali che li governano.
La configurazione usa file locali tradizionali invece di segreti cifrati nel
repository: i valori sensibili restano fuori da Git, mentre il repository
documenta posizioni, riferimenti e procedure dichiarative che li consumano.

## Principio generale

Il progetto privilegia una gestione file-based per:

- semplicità operativa;
- trasparenza;
- portabilità tra host;
- debugging diretto;
- backup con strumenti ordinari.

La conseguenza è esplicita: i file sensibili devono essere mantenuti fuori dal
repository, con permessi restrittivi e percorsi ben documentati.

## Vincolo di bootstrap

Un eventuale ritorno alla cifratura in-repo con sops-nix o agenix richiede un
**seed out-of-band**: la credenziale per clonare il repository e una chiave di
recovery devono essere disponibili fuori dal repository, e ogni segreto deve
essere cifrato anche verso la recovery key. Senza questo vincolo una
reinstallazione pulita non può né clonare né decifrare la configurazione.

Il vincolo nasce da un tentativo ritirato: agenix, adottato ad agosto 2025
(`cebbd49`), fu rimosso il 27 settembre 2025 (`a6c01bd`) perché la chiave per
clonare il repo privato era cifrata dentro il repo stesso. Il difetto era di
design, non dello strumento: mancava il seed esterno.

Il seed di casa è la cassaforte Bitwarden personale del custode (decisione
del 2026-11-06), distinta da quella dell'account di lavoro; riempita e
verificata col task di inventario chiuso il 2026-11-07 (storia in git).

**Niente cifratura in-repo per ora** (custode, 2026-11-07, a inventario
chiuso). I segreti statici adatti sono pochi (chiavi WireGuard, password di
aMule e FTP su `deck`, certificati Syncthing dei tre host): sops-nix o
agenix toglierebbero da tre a cinque file da rimettere a mano per host a
ogni reinstallazione, evento raro, al prezzo di un input in più, di una
chiave age per host e una di recovery da custodire comunque nel seed, della
ricifratura a ogni cambio di host e della separazione fra decryptor di
sistema e utente. Il rischio vero, perdere le identità, lo copre già il seed
verificato con ripristino provato. Pubblicare il repo non richiede la
migrazione: oggi i segreti non sono nel repo, e cifrarli dentro un repo
pubblico esporrebbe di più. Se servisse, agenix è l'ipotesi per uno scope
così piccolo (un file per segreto, nessun template), da confermare col
confronto in ambiente isolato. Si riapre per un quarto host, reinstallazioni
frequenti o nuovi segreti statici che rendano pesante il ripristino a mano;
la prova annuale del seed (sotto, § Prova annuale del seed) è il momento in
cui pesarlo.
Il task di migrazione chiuso resta nella storia di git.

L'accesso alla cassaforte da terminale è la CLI ufficiale `bw`
(`o3/modules/home/bitwarden-cli.nix`), installata solo su `deck`, dove
l'inventario si confronta con la cassaforte: le impronte degli altri host
si leggono via SSH. Su un host da ripristinare si usa
`nix shell nixpkgs#bitwarden-cli`. Lo sblocco (`bw unlock`) chiede sempre
la master password e la sessione vale solo nella shell che la riceve:
nessun accesso alla cassaforte senza il custode presente, perché una
master password o una sessione salvata su un host renderebbe il seed
dipendente da ciò che deve ripristinare. Gli agenti lavorano su nomi
delle voci e impronte, mai sui valori.

Il seed verificato dimostra la disponibilità del materiale di recupero e
le prove funzionali effettivamente eseguite, non ancora la ricostruzione
completa di tutti gli host. L'accesso alla cassaforte deve essere possibile
senza una sessione già autenticata sugli host da ripristinare. Per ogni
voce distinguere preservazione dell'identità, ripristino di una copia e
riautorizzazione; per OAuth la conformità di una copia non dimostra la
validità delle credenziali. Il client OAuth e i token di `gog` hanno
collocazioni distinte: copiare il JSON del client non ripristina il keyring.

## Inventario dei segreti

Rilevazione del 2026-11-06 sui tre host. Fonti: metadati filesystem
(`stat`, senza contenuti), nomi delle sezioni rclone, `gog auth status/list`,
stato dei servizi e configurazione versionata. I servizi attivi non sono
una prova di ripristino o di autenticazione applicativa.

Convenzioni comuni alle voci sotto:

- `~` è `/home/stele` sui tre host, proprietario `stele:users` salvo
  diversa indicazione. Su `game` dal 2026-11-07: prima l'utente era
  `utente-precedente` (`/home/utente-precedente`), rinominato sul posto con lo stesso UID 1000;
  residui della migrazione, backup `.bak-utente-precedente` compresi, rimossi dal
  custode.
- **Seed:** note sicure `casa/<host>/<voce>` nella cassaforte personale,
  create il 2026-11-06 e rilette byte per byte contro il file d'origine
  (`creata, conforme`), più le voci di login `amule` e
  `casa/deck/ftp-scansioni` (2026-11-07). Mancano i login fuori seed per
  scelta. Una copia conforme non è un ripristino provato. Provati il
  2026-11-07: accesso alla cassaforte da zero su `neve` (email, master
  password, codice via Gmail dal telefono), ripristino reale
  dell'identità Syncthing di `neve`, rinnovo OAuth dalle note rclone di
  `deck`, login FTP e WireGuard casa coerente col seed. Copertura residua:
  nessun host reinstallato da zero (ordine di avvio), nessun ripristino
  funzionale di chiavi SSH, WireGuard e note rclone di `game` e `neve`.
- **Rotazione e prova** (ratificate dal custode il 2026-11-07): una prova
  annuale del seed, cioè lettura e ripristino di almeno un'identità e
  confronto del seed con questo inventario (ricorrenza del plan, procedura
  in § Prova annuale del seed);
  rotazione per evento (compromissione, perdita di un dispositivo, un
  cambio d'assetto come un peer VPN che cambia host); rotazione periodica
  solo dove costa poco, con la cadenza scritta nella voce.
- Voci del seed: per `deck` `wireguard-casa`, `wireguard-lavoro`,
  `ssh-utente`, `ssh-host-ed25519`, `ssh-host-rsa`, `syncthing`, `rclone`,
  `rclone-familiare`; per `neve` e `game` `ssh-utente`, `ssh-familiare`,
  `ssh-host-ed25519`, `ssh-host-rsa`, `syncthing`, `rclone`,
  `rclone-familiare`; `casa/gog-client` una sola per i
  tre host. `syncthing` contiene `cert.pem` seguito da `key.pem`. Fuori da
  questa rilevazione, decise il 2026-11-11 e ancora da creare, le voci
  `casa/identity/…` (§ Identità separata dai segreti).
- Rotazioni e gestori candidati descrivono procedure da collaudare; oggi
  nessuna di queste voci è consegnata da sops-nix o agenix. Nessun valore,
  token o hash di password viene registrato qui.

### SSH utente e identità GitHub

- **Host/path/modo:** `~/.ssh/id_ed25519`, `0600`, sui tre host;
  `~/.ssh/id_ed25519_familiare`, `0600`, su `neve` e `game`, assente su `deck`.
- **Identità e consumer:** account del custode e, per le chiavi dedicate,
  account GitHub di familiare; SSH utente, GitHub e accessi tra host.
  `ssh-github-familiare.nix` seleziona la chiave dedicata.
- **Scrittura/consegna:** file statici creati manualmente; livello utente,
  disponibili prima del clone e delle connessioni SSH.
- **Recupero/seed:** preservare chiave e relativa passphrase se presente
  (presenza della passphrase non verificata). Etichette
  `casa/<host>/ssh-utente` e `casa/<host>/ssh-familiare`.
- **Prova:** corrispondenza della pubblica derivata, accesso al repository
  autorizzato e ai peer previsti. Le connessioni da `deck` a `neve` e `game`
  sono riuscite; non è una prova delle copie in cassaforte.
- **Rotazione:** nuova coppia, autorizzazione su GitHub e peer, prova del
  nuovo accesso, revoca della vecchia pubblica; coordinamento lavoro per
  gli accessi di `deck`. Costo medio. Gestore candidato: decisione esplicita
  nella migrazione; la credenziale di clone resta indipendente dal repo.

### WireGuard casa e ufficio

- **Casa:** `/etc/wireguard/casa-vpn.key` su `deck`, `root:root 0600`,
  directory `/etc/wireguard` `root:root 0700`, `casa-vpn.pub` `0644`
  (verificati con sudo il 2026-11-07, come prescrive il runbook). Public
  key derivata dalla chiave, del file `.pub`, dell'interfaccia `casa`
  attiva e derivata dalla nota del seed tutte uguali a
  `identity.home.vpn.serverPublicKey`, senza stampare la privata.
  Identità del server VPN; consumer `wireguard.nix`, sistema, prima del
  tunnel `casa`. Etichetta `casa/deck/wireguard-casa`.
- **Ufficio:** `/home/stele/.config/wireguard/work-office.key`,
  `stele:users 0600`, verificati. Identità del peer `deck`; consumer
  `wireguard-work-client.nix`, sistema, prima del tunnel `lavoro` anche se
  il file è nella home. Etichetta `casa/deck/wireguard-lavoro`.
- **Scrittura/recupero:** statiche, oggi file manuali; preservare le
  identità. Candidate alla consegna system-level cifrata nel repo.
- **Prova:** pubblica derivata conforme, handshake e traffico dopo restore.
  Le unità `wireguard-casa` e `wireguard-lavoro` risultavano attive; non
  sono stati letti handshake né provato il recovery.
- **Rotazione:** coordinare i peer e i riferimenti nel repo di lavoro per
  entrambe le identità, provare nuovo traffico e revocare le vecchie chiavi.
  Costo alto per il server casa, medio per il client ufficio.

### Syncthing

- **Host/path/modo:** `~/.local/state/syncthing/{cert,key}.pem` sui tre
  host; certificato `0644`, privata `0600`, proprietario utente verificato.
- **Identità/consumer:** identità distinta per host, Device ID dichiarati
  in `~/.config/nixos/identity/home.nix`; `syncthing-home-mesh.nix`, servizio utente.
- **Scrittura/consegna:** coppia generata dall'applicazione al bootstrap,
  da preservare; disponibile prima di Syncthing per evitare la generazione
  di un'altra identità. Gestore candidato: consegna cifrata della coppia,
  da collaudare con il servizio Home Manager.
- **Recupero/seed:** `casa/<host>/syncthing`, coppia coerente cert/key.
  Prova: Device ID atteso e sincronizzazione, senza duplicare un peer attivo.
  Ripristino reale dal seed provato su `neve` il 2026-11-07: copia
  identica, Device ID atteso, sincronizzazione con `deck` e `game`.
  Non ancora provato su un host reinstallato (ordine di avvio).
- **Rotazione:** sostituire la coppia e aggiornare il Device ID presso tutti
  i peer della mesh, ricondividere le cartelle e provare la sincronizzazione;
  costo medio/alto. Non ruotare come semplice effetto della migrazione.

### rclone e account Drive

- **Host/path/modo:** `~/.config/rclone/rclone.conf`, `0600` sui tre host.
  custode e familiare montati sui tre host. `gdrive-familiare` è privato: il
  suo remote sta in `~/.config/rclone-gdrive-familiare/rclone.conf` (`0600`),
  inaccessibile ai cicli autonomi; nel file condiviso resta solo
  `gdrive-personale`. Un'autorizzazione propria per host e account. I remote di Luca, Matteo e Davide sono usciti dal file di
  entrambi il 2026-11-07 (custode: i figli usano Windows).
- **Identità/consumer:** account personali distinti; servizi utente
  `rclone-mount-*`, file richiesto prima dell'avvio dei mount.
- **Scrittura/consegna:** configurazione locale modificata da rclone al
  rinnovo; fuori dalla consegna dichiarativa diretta. Nessun ciphertext
  deve rimpiazzare periodicamente lo stato aggiornato dei token.
- **Recupero/seed:** `casa/<host>/rclone` (file condiviso, solo
  `gdrive-personale`) e `casa/<host>/rclone-familiare` (file privato) sui tre
  host: un token proprio per host e account, quindi una voce per host.
  Allineate il 2026-11-07, rilettura conforme al file. Al ripristino si
  rimette la copia dell'host stesso, mai quella di un altro: due host con lo
  stesso token causavano i conflitti di rotazione del 2026-05-29
  (`rclone-gdrive`). In alternativa si riautorizza l'account.
- **Prova:** accesso Drive per ogni remote dopo restore/reconnect,
  distinguendo account configurato e mount attivo. Prova OAuth del
  2026-11-07 su `deck`: `casa/deck/rclone` e `casa/deck/rclone-familiare`
  scritte in una config temporanea in tmpfs, token d'accesso invalidato e
  scadenza nel passato, `rclone lsd` riuscito su entrambi i Drive con
  rinnovo dal refresh token del seed. I client sono in produzione, quindi
  il refresh token non scade a sette giorni: al ripristino basta la copia
  dell'host. Non provate le note di `game` e `neve`, stessa forma.
- **Rotazione:** reconnect o nuova autorizzazione per account/host;
  revoca del precedente grant con verifica degli altri consumer. Client
  OAuth potenzialmente condivisi con `gog`, da confrontare prima di ruotarli.
  Costo medio, con intervento del titolare dell'account.

### gog: client OAuth, token e keyring

- **Host:** solo `deck` dal 2026-11-07. Su `game` e `neve` `gog` è stato
  tolto (custode: lì non si usa), con `~/.config/gogcli` e la collezione
  `gogcli` del keyring.
- **Client statico:** `~/.config/gogcli/credentials.json`, `0600`,
  directory `0700`; `~/.config/gogcli/keyring/` vuota, il backend file di
  `gog` non è in uso.
- **Token e sblocco:** backend `auto`, GNOME Keyring nella sessione
  utente; collezione `gogcli` in `~/.local/share/keyrings/gogcli.keyring`,
  cifrata, aggiornata a ogni giro dal demone via D-Bus (`~/.config/gogcli`
  ferma da maggio, quindi in sola lettura per i cicli). La password del
  keyring è quella dell'utente `stele` (voce `casa/stele`): l'autologin di
  greetd non la dà a PAM, il custode la digita a ogni riavvio di `deck`
  (custode, 2026-11-07). Finché non la digita, i cicli che usano `gog`
  vanno in timeout D-Bus, come il 2026-10-15.
- **Identità/consumer:** account Google; CLI e cicli utente. Client e
  keyring accessibile devono precedere l'invocazione. L'applicazione
  aggiorna i token; il client OAuth cambia durante il setup/rotazione.
- **Recupero/seed:** etichetta `casa/gog-client`, una sola (client
  confrontato fra i tre host il 2026-11-06, dall'originale
  `oauth-client.json` che stava su `game`); riautorizzazione
  per-host già prevista da `google-workspace-cli`. Un backup dei token
  richiede anche backend e sblocco collaudati, non la sola copia del JSON.
  Non copiare l'intero keyring personale come se contenesse solo `gog`.
- **Prova:** autenticazione Google dopo riautorizzazione o restore;
  l'elenco degli account locali non verifica la validità remota dei token.
  Strategia ancora da collaudare. Client statico candidato alla cifratura,
  token fuori dalla consegna dichiarativa diretta.
- **Rotazione:** nuovo grant e revoca del vecchio; per il client OAuth
  coordinare ogni consumer che lo condivide, inclusi rclone e altri host.
  Costo medio/alto; il keyring ha un ciclo di recupero distinto dal client.

### aMule

- **Host/path/modo:** `/var/lib/amuled/password` su `deck`,
  `stele:users 0600`, verificati; `amuled.service` esegue come
  `stele:users` ed era attivo.
- **Altri file di stato** (classificati il 2026-11-07 leggendo lo script
  `amuled-pre-start`): `amule.conf` è creato da aMule al primo avvio e
  riscritto a ogni avvio con le impostazioni dell'host, con la password
  External Connect derivata (md5) da `password`; `amuleapi-passwords` lo
  riscrive `amuleapi --set-admin-pass` a ogni avvio dalla stessa
  `password`; `amuleapi-jwt-secret` firma le sessioni web, generato al
  primo avvio, perderlo scollega soltanto. Tutti e tre rigenerabili, fuori
  seed. `cryptkey.dat` (`0644`) è l'identità del client eD2k da cui gli
  altri client calcolano i crediti di coda: perderlo azzera i crediti
  accumulati, nessun dato perso. Fuori seed (custode, 2026-11-07).
- **Identità/consumer:** credenziale di servizio condivisa da
  `AmuleApiAdminPasswordFile` e `ExternalConnectPasswordFile`, dichiarati
  nell'host; consegna sistema, disponibile prima dell'avvio di aMule.
- **Scrittura/recupero:** file statico manuale; preservare la password e
  verificarla sui due accessi. **Seed:** la voce di login `amule` della
  cassaforte (URI della vecchia interfaccia web, `deck:8080`) contiene la
  stessa password del file, confronto locale del 2026-11-06 senza stampa.
  Non è stato provato il login né il ripristino.
- **Rotazione:** aggiornare file e client API/External Connect, riavviare e
  verificare entrambi. Costo basso/medio; candidato alla consegna cifrata.

### FTP scansioni

- **Host/posizione:** `deck`, utente di sistema `scansioni` presente;
  password impostata tramite `passwd`, hash nello shadow di sistema non
  letto, password anche nella multifunzione. Metadati dello shadow non
  letti per scelta (custode, 2026-11-07): la password è nel seed e una
  reinstallazione ne imposta una nuova.
- **Identità/consumer:** account della stampante, autenticazione PAM di
  vsftpd; gestione utenti di sistema prima del login FTP.
- **Scrittura/recupero:** credenziale statica amministrata a mano; voce di
  login `casa/deck/ftp-scansioni` (utente `scansioni`, URI
  `ftp://192.168.0.10`), creata il 2026-11-07. Distinguere password necessaria alla
  stampante e hash necessario a ricostruire l'utente: l'hash non recupera
  la password. Candidato `hashedPasswordFile` cifrato.
- **Prova/rotazione:** login e scansione reale; cambiare password su host e
  stampante in modo coordinato. Costo basso/medio con accesso alla
  multifunzione. Il 2026-11-07 il custode ha provato la password con un
  login FTP da `deck` (`lftp` su `127.0.0.1`, elenco delle scansioni) e
  poi l'ha salvata; lo stesso giorno un login FTP con la password letta
  dalla voce (`curl` con netrc in memoria, senza stamparla) è riuscito.
  Scansioni reali dalla multifunzione riuscite: ultima il 2026-11-07
  alle 12:37 (`OK LOGIN` e `OK UPLOAD` da `192.168.0.15` nel journal di
  vsftpd).

### Telefono `telefono`

Voce unica per le chiavi del telefono: WireGuard del tunnel `casa` e SSH
Sherpr verso `deck`. Accesso da Sherpr confermato dal custode il 2026-11-10,
dopo il rebuild, scrivendo nella sessione dal telefono. La chiave JuiceSSH
è rimossa dalla configurazione per decisione del custode; la revoca richiede
un nuovo rebuild di deck.

- **Host/path/modo:** private nelle app del telefono, fuori dalla rilevazione
  sui tre host. Pubblica WireGuard e indirizzo in
  `identity.home.vpn.hosts.telefono`, pubblica SSH in
  `identity.home.deckAuthorizedKeys.telefono-sherpr`.
- **Identità e consumer:** peer `10.20.0.3` del server VPN di `deck`
  (`o3/hosts/deck/default.nix`); login di `stele` su `deck` con la chiave
  dichiarata in `deckAuthorizedKeys` (`ssh-matrix`).
- **Recupero/seed:** fuori seed (custode, 2026-11-08), perché si rigenerano
  sul telefono e si riautorizzano: non c'è un'identità da preservare.
- **Prova:** accesso Sherpr confermato dal custode il 2026-11-10.
- **Rotazione:** per evento, nessuna cadenza periodica.

**Telefono perso o rubato.** Prima si revoca, poi si riautorizza; il rebuild
di `deck` è un atto del custode.

1. Togliere subito il peer dal tunnel attivo, con la public key vecchia letta
   da `identity`: `sudo wg set casa peer <public-key> remove`. Vale fino al
   riavvio del tunnel, quindi serve anche il passo 3.
2. Il login SSH si revoca solo col passo 3, perché sshd legge unicamente
   l'elenco generato dal repo (`ssh-matrix`). Fino a quel rebuild, tolto il
   peer, al telefono resta solo la strada dalla LAN di casa.
3. Rendere stabile la revoca: senza telefono sostitutivo togliere la voce
   `telefono-sherpr` da `identity.home.deckAuthorizedKeys`
   e il peer del telefono dall'elenco dei peer
   in `o3/hosts/deck/default.nix`, poi fare il rebuild di `deck`.
4. Sul telefono sostitutivo generare nelle app una coppia WireGuard e una
   Ed25519 nuove, senza riusare le vecchie; client secondo
   `wireguard-home § Template Config Client`.
5. Scrivere le due pubbliche nuove in `identity.home.vpn.hosts.telefono` e
   `identity.home.deckAuthorizedKeys.telefono-sherpr`, ripristinare il peer se
   tolto al passo 3 e fare il rebuild di `deck`.
6. Provare handshake e login da `10.20.0.3`; una chiave vecchia rifiutata
   appare in `journalctl -u sshd` come in `ssh-matrix`.

### Altre identità e confini dell'inventario

- **SSH host:** `/etc/ssh/ssh_host_{ed25519,rsa}_key`, `root:root 0600`
  rilevati sui tre host, non leggibili dall'utente. Identità del server
  SSH, generate dal sistema e disponibili prima di sshd. Si preservano nel
  seed (decisione del custode del 2026-11-06), `casa/<host>/ssh-host-ed25519`
  e `casa/<host>/ssh-host-rsa`, perché dopo una reinstallazione gli altri
  host riconoscano l'host come prima: ripristinarle prima del primo avvio
  di sshd. La rotazione (nuove chiavi, aggiornamento di `known_hosts` sui
  peer) resta per evento, costo medio. Nessuna scelta implicita di usarle
  come decryptor.
- **Login Claude Code:** `~/.claude/.credentials.json`, `0600` sui tre
  host, scritto dall'applicazione; consumer utente (anche cicli di `deck`).
  Fuori seed per decisione vigente: nuovo login, da verificare prima di
  riattivare il ciclo. Rotazione/revoca tramite account, nessuna consegna
  dichiarativa candidata.
- **Login di altri agenti e CLI:** su `deck` esistono
  `~/.config/gh/hosts.yml` (token GitHub di `gh`, usato dagli agenti),
  `~/.codex/auth.json` e `~/.pi/agent/auth.json`, scritti dalle
  applicazioni. Stessa categoria del login di Claude Code: fuori seed salvo
  decisione diversa, si rifà il login; rotazione e revoca dall'account.
  Presenti, `0600`, anche su `neve` e `game` (verificato il 2026-11-07).
  Fuori seed confermato dal custode il 2026-11-07.
- **Password dell'utente `stele`:** la stessa sui tre host, impostata con
  `passwd` (utenti mutabili); voce `casa/stele` in cassaforte (2026-11-07).
  Dopo una reinstallazione se ne imposta una nuova: in cassaforte serve
  come promemoria dell'host in uso, non per ricostruire.
- **Sblocco del keyring:** stessa password dell'utente, digitata dal
  custode a ogni riavvio (l'autologin non la passa a PAM); coperta da
  `casa/stele`. Dopo una reinstallazione il keyring non si ripristina: si
  rifanno i login che lo usano (`gog` su `deck`).
- **Wi-Fi di casa:** password scritta sul router e voce `casa/wifi` in
  cassaforte (2026-11-07); serve a rimettere in rete un host reinstallato
  senza cavo, `deck` per primo. Il profilo Wi-Fi imperativo di riserva su
  `deck` la usa. Nessun profilo NetworkManager o shadow è stato esportato.

I segreti della coppia server sono inventariati nel repo
`example-org/nixos-ufficio`.

## Identità separata dai segreti

Distinta dai segreti veri c'è l'**identità** dell'infrastruttura: domini, IP,
chiavi _pubbliche_ (WireGuard, Syncthing, SSH authorized), email, endpoint VPN.
Non è segreta — le chiavi pubbliche e i domini sono pubblici per natura — ma
identifica reti private e impedirebbe di pubblicare la configurazione di casa se
restasse inline negli host.

Questa identità vive in `~/.config/nixos/identity/`, fuori da Git e dal
checkout. Il flake pubblico usa i template `o3/identity/*.example.nix`;
`o3/scripts/con-identita.sh` passa esplicitamente i file reali alle
valutazioni e alle attivazioni, senza scriverli nel lock pubblico. Forma,
bootstrap e comandi sono in `o3/identity/README.md`.

La directory locale contiene i dati di casa e i soli dati d'ufficio letti
da deck. I moduli continuano a consumare `identity.home` e `identity.work`:
la struttura resta dichiarativa, cambia la fonte dei valori. Mount Drive,
identità SSH aggiuntive e nome Git sono dati locali; i nomi runtime attuali
rimangono quelli configurati sul singolo host.

Questi dati non sono segreti crittografici e finiscono nel Nix store durante
la valutazione. La loro copia privata è però necessaria al ripristino:
clonare il repo pubblico recupera i template, non le identità reali, e i
template non si attivano (`nixos-rebuild`).

La copia sta nel seed (custode, 2026-11-11), accanto ai segreti:

- **Host/path/modo:** `~/.config/nixos/identity/{default,home,work}.nix`,
  `0600` in directory `0700`, sui tre host; `~/.config/nixos/privacy.json`
  (letterali che il gate non deve lasciar pubblicare), usato dove si committa.
- **Consumer:** `o3/scripts/con-identita.sh`, quindi ogni valutazione, build
  e attivazione reale, di sistema e home. Serve prima del primo rebuild.
- **Seed:** note sicure `casa/identity/default.nix`, `casa/identity/home.nix`,
  `casa/identity/work.nix` e `casa/identity/privacy.json`, una sola serie
  presa da `deck`. Da creare: finché il custode non le ha scritte e rilette
  contro i file, l'unica copia è quella sugli host stessi. Che i file di
  `game` e `neve` coincidano con quelli di `deck` non è verificato.
- **Scrittura:** file modificati a mano a ogni cambio d'assetto (un peer, una
  chiave autorizzata, un indirizzo): la nota va aggiornata nello stesso
  momento, altrimenti il seed ripristina un assetto superato. La prova
  annuale confronta anche queste voci.
- **Prova:** con la copia ripristinata, il path dell'`activationPackage` e
  il toplevel valutati col wrapper coincidono con quelli attivi
  (`home-drift.sh`, `system-drift.sh`). Non ancora eseguita.
- **Senza seed:** copiare la directory da un altro host di casa; se sono
  persi tutti, si ricompilano i template a mano da router, peer e pannelli.

I segreti _crittografici_ veri (chiavi private, password, `rclone.conf`) restano
file locali gitignorati referenziati per path, mai importati come valori Nix.

## Pattern critici

### Dichiarativo vs locale

Il repository dichiara:

- quali chiavi pubbliche sono autorizzate;
- quali path devono essere usati dai servizi;
- quali peer WireGuard sono ammessi.

I file privati veri restano locali agli host e non entrano in Git.

## Backup e ripristino

File e directory critici da preservare:

- `~/.config/nixos/identity/` (non segreta, ma senza non si ricostruisce)
- `~/.ssh/id_ed25519`
- `~/.config/rclone/rclone.conf`
- `/etc/wireguard/casa-vpn.key`
- `/etc/wireguard/casa-vpn.pub`
- `/home/stele/.config/wireguard/work-office.key`
- `~/.ssh/id_ed25519_familiare` (`game`, `neve`)
- `~/.local/state/syncthing/{cert,key}.pem` (tre host)
- `/var/lib/amuled/password`
- `~/.config/gogcli/` (client OAuth); per i token serve anche il backend
  del keyring con sblocco verificato, oppure la riautorizzazione per-host

I path sotto `/etc/wireguard/` sono destinazioni runtime, non backup. Prima di
reinstallare l'ultimo host che conserva una chiave, verificarne la copia nella
cassaforte Bitwarden personale senza stamparla (per `casa-vpn.key` fatto il
2026-11-07: public key derivata dal seed coerente). Se la copia non è
disponibile, il recovery della
relativa identità VPN è bloccato e la chiave va ruotata con tutti i peer.

Lo stesso vincolo vale per la chiave del client VPN ufficio di deck: il
server non ne conserva la chiave privata, ma soltanto quella pubblica.
Ripristinarla dal seed oppure ruotare il peer, aggiornando la public key
nel repo `example-org/nixos-ufficio`, che dichiara i peer della VPN ufficio.

## Prova annuale del seed

Ricorrenza di `o1/plan.md`, criterio ratificato dal custode il 2026-11-07
(«Rotazione e prova», sopra). Un seed non riletto invecchia in silenzio: voci
non aggiornate dopo una rotazione, un prerequisito d'accesso che cambia, un
token non più valido.

1. Aprire la cassaforte da un ambiente senza sessione (`nix shell
nixpkgs#bitwarden-cli`, `bw login`), col prerequisito Gmail sul telefono
   (`kb/post-installation.md`, sezione 3).
2. Confrontare le voci `casa/…` con l'inventario: ogni voce marcata seed
   presente e conforme al file dell'host, nessuna voce orfana.
3. Ripristinare davvero almeno un'identità diversa da quella dell'anno
   prima (2026: Syncthing di `neve`), fermando prima l'istanza originale, e
   provarne il consumer; per OAuth ripetere il rinnovo da una nota rclone.
4. Registrare esito e copertura residua nella voce dell'inventario, senza
   valori, e avanzare `Prossima` in `o1/plan.md` nello stesso commit.

## Fonti di verità

- **identità infrastruttura** — `~/.config/nixos/identity/{home,work}.nix` (IP, chiavi pubbliche, email, endpoint VPN)
- **chiavi WireGuard** — host configs + path dichiarati nei moduli WireGuard
- **mount rclone** — `o3/modules/home/rclone.nix` + profili home
- **alias SSH** — moduli `o3/modules/home/ssh-*.nix`

## Dove fare cosa

- **reinstallare un host** — `post-installation`
- **configurare o gestire rclone** — `rclone-operations`
- **capire i mount Drive correnti** — `rclone-gdrive`
- **gestire VPN casa** — `wireguard-home`
- **client VPN ufficio di deck** — `network-architecture`
- **vedere accessi SSH tra host** — `ssh-matrix`

## Best practices

1. Non committare mai segreti.
2. Usare permessi restrittivi (`chmod 600`) per i file privati.
3. Conservare backup ridondanti delle identità VPN.
4. Documentare ogni nuovo segreto con percorso e consumatore tecnico.
5. Verificare sempre il ripristino dopo reinstallazione o rotazione credenziali.

Connessioni:

- [post-installation](post-installation.md)
- [rclone-gdrive](rclone-gdrive.md)
- [rclone-operations](rclone-operations.md)
- [wireguard-home](wireguard-home.md)
- [network-architecture](network-architecture.md)
- [ssh-matrix](ssh-matrix.md)
- [google-workspace-cli](google-workspace-cli.md)
