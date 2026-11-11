---
stato: maturo
---

# Rclone Google Drive

Architettura corrente dei mount Google Drive nel progetto. Gli host personali di
casa montano direttamente i Drive via rclone FUSE: non esiste un hub centrale e
non viene mantenuta una copia locale completa dei contenuti remoti.

## Modello corrente

Il modulo `o3/modules/home/rclone.nix` fornisce:

- mount FUSE automatici con cache VFS;
- servizi `systemd --user` per i mount configurati;
- supporto multi-account;
- un template `rclone-mount@` per i mount occasionali.

Ogni host coinvolto monta direttamente Google Drive. Questa scelta elimina un
hub intermedio e mantiene separati:

- **Syncthing**, che sincronizza `~/sync/` tra i client di casa;
- **rclone mount**, che espone `~/Drive/` come filesystem remoto.

## Configurazione attuale per host

- **gdrive-personale** — game: si; deck: si; neve: si
- **gdrive-familiare** — game: si; deck: si; neve: si (privato)

I tre host montano gli stessi due Drive, dichiarati una volta sola in
`o3/home/default.nix` (custode, 2026-11-07). Quello di familiare è un mount
**privato** (`private = true` in `rclone.nix`): il suo remote vive in un file
proprio, `~/.config/rclone-gdrive-familiare/rclone.conf`, e il modulo dei cicli
rende quel file e `~/Drive/gdrive-familiare` inaccessibili a ogni ciclo
autonomo, così gli agenti di deck non lo vedono né dal mount né via API. Dal
2026-10-11 al 2026-11-07 deck aveva il solo account di custode per la stessa
ragione, tagliata alla radice invece che recintata. Ogni host ha la propria
autorizzazione per account: copiare un token fra host causava, il
2026-05-29, conflitti di rotazione che rendevano i mount inaccessibili.
Gli account di Luca, Matteo e Davide sono usciti dai mount di `neve` il
2026-10-18 e da `game` il 2026-11-07, insieme ai loro remote nel `rclone.conf`
di entrambi (custode: i figli usano Windows, i loro segreti non servono sui
PC NixOS).

Ogni host mantiene il proprio `rclone.conf` locale. Dopo una reinstallazione o
la copia iniziale della configurazione da un altro host, eseguire `rclone config
reconnect gdrive-NOME:` su ogni account per rendere autonoma l'autorizzazione
del nuovo host. Non attribuire automaticamente i 401 persistenti alla condivisione dei
refresh token: questa ipotesi è stata falsificata nelle verifiche precedenti.
La causa dei precedenti episodi non è stata dimostrata; in caso di ricorrenza
verificare orologio, stato OAuth e risposta API prima di ruotare credenziali.
L'indagine sui 401 persistenti è chiusa per decisione del custode: gli errori
non si sono più manifestati per un periodo prolungato; una ricorrenza la
riapre come segnale nuovo.

Su `game` anche l'orologio deve restare corretto durante il boot. L'RTC in ora
locale faceva partire il sistema circa due ore avanti prima della
sincronizzazione NTP e interferiva con la gestione temporale dei token. Per
questo `game` usa RTC UTC; Windows dual boot deve avere `RealTimeIsUniversal`.

All'avvio i mount attendono che `www.googleapis.com` risolva, fino a 60
secondi, prima di lanciare rclone. Il manager `systemd --user` non vede il
`network-online.target` di sistema, quindi un ordinamento su quel target non
ha effetto: senza l'attesa i mount partivano prima del DNS e fallivano una
volta (osservato su `neve` il 2026-10-18). Oltre i 60 secondi subentra
`Restart=on-failure`.

Per la durata dell'autorizzazione e lo stato del progetto OAuth seguire
`rclone-operations`. Distinguere errori di autorizzazione persistenti da quote
API temporanee prima di scegliere il rimedio.

## Layout filesystem

```text
~/Drive/
├── gdrive-personale/
└── gdrive-familiare/
```

I symlink relativi dentro `~/sync/*/Drive` puntano a questi mount point e restano
portabili tra i tre host.

## Fonti di verità

- **implementazione dei mount** — `o3/modules/home/rclone.nix`
- **mount attivati per profilo** — `o3/home/stele/deck.nix`, `o3/home/stele/neve.nix`, `o3/home/stele/game.nix`
- **helper utente** — `o3/modules/home/rimonta-drive.nix`
- **credenziali OAuth** — `~/.config/rclone/rclone.conf`

## Perché mount diretto

Il mount diretto rende ogni host autonomo rispetto a Google Drive e mantiene
chiara la separazione tra dati sincronizzati localmente e dati remoti montati a
richiesta. I file restano accessibili nello stesso percorso su tutti i client,
senza introdurre un server intermedio o una seconda pipeline di replica.

Connessioni:

- [syncthing-architecture](syncthing-architecture.md)
- [rclone-operations](rclone-operations.md)
- [secrets-management](secrets-management.md)
- [client-desktop-architecture](client-desktop-architecture.md)
