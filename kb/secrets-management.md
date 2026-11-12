---
stato: maturo
---

# Secrets management

Scelte architetturali che governano i segreti del progetto e procedure per
conservarli e ripristinarli; l'elenco voce per voce è nel nodo dell'inventario.
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
template non si costruiscono come sistema (`nixos-rebuild`).

La copia sta nel seed (custode, 2026-11-11), accanto ai segreti:

- **Host/path/modo:** `~/.config/nixos/identity/{default,home,work}.nix`,
  `0600` in directory `0700`, sui tre host; `~/.config/nixos/privacy.json`
  (letterali che il gate non deve lasciar pubblicare), usato dove si committa.
- **Consumer:** `o3/scripts/con-identita.sh`, quindi ogni valutazione, build
  e attivazione reale, di sistema e home. Serve prima del primo rebuild.
- **Seed:** note sicure `casa/identity/default.nix`, `casa/identity/home.nix`,
  `casa/identity/work.nix` e `casa/identity/privacy.json`, una sola serie
  presa da `deck`, create e rilette byte per byte contro i file il
  2026-11-12. Una serie basta perché `work.nix` serve solo a `deck` (VPN
  ufficio, `/etc/hosts`, `ssh-work-lan.nix`, `methodFetch` del ciclo
  `method`): sugli altri host deve solo valutarsi. Lo stesso giorno, con
  l'identità di `deck`, si valutano i toplevel e gli `activationPackage` di
  `neve` e `game`. `neve` e `game` avevano una `work.nix` diversa, senza
  effetto sul loro sistema, e sono state allineate a quella di `deck` (`game`
  il 2026-11-12, copia della vecchia in `work.nix.bak-2026-11-12`): le
  impronte dei quattro file coincidono sui tre host.
  Da riallineare: più tardi lo stesso giorno `home.nix` e `privacy.json` di
  `deck` hanno ricevuto il progetto Google Cloud (`gcloud`), tolto dai file
  pubblici; le due note del seed e le copie di `neve` e `game` sono ancora
  alla versione precedente.
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

## Dichiarativo vs locale

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
(`secret-inventory`, «Rotazione e prova»). Un seed non riletto invecchia in silenzio: voci
non aggiornate dopo una rotazione, un prerequisito d'accesso che cambia, un
token non più valido.

1. Aprire la cassaforte da un ambiente senza sessione (`nix shell
nixpkgs#bitwarden-cli`, `bw login`), col prerequisito Gmail sul telefono
   (`kb/post-installation.md`, sezione 3).
2. Confrontare le voci `casa/…` con `secret-inventory`: ogni voce marcata seed
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

- **trovare path, permessi, seed e rotazione di un segreto** — `secret-inventory`
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

- [secret-inventory](secret-inventory.md)
- [post-installation](post-installation.md)
- [rclone-gdrive](rclone-gdrive.md)
- [rclone-operations](rclone-operations.md)
- [wireguard-home](wireguard-home.md)
- [network-architecture](network-architecture.md)
- [ssh-matrix](ssh-matrix.md)
- [google-workspace-cli](google-workspace-cli.md)
