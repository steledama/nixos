---
stato: maturo
---

# Post-installation

Runbook per completare la reinstallazione o il setup iniziale di `deck`,
`neve` e `game`. Per un sistema che non si avvia si parte invece da
`disaster-recovery`.

## 1. Clonare il repository

Prima del bootstrap deve esistere una credenziale di clone disponibile fuori
dal repository: accesso HTTPS già configurato, token recuperabile da un seed
sicuro oppure chiave SSH ripristinata. Verifica l'accesso senza esporre la
credenziale e usa il remote coerente con il metodo disponibile.

```bash
# Con accesso HTTPS già configurato
git clone https://github.com/steledama/nixos.git

# Oppure, dopo aver ripristinato una chiave SSH autorizzata
git clone git@github.com:steledama/nixos.git
cd nixos
```

Se nessuna delle due forme è disponibile, il recovery è bloccato: non salvare
token o chiavi private nel repository per aggirare il bootstrap.

## 2. Preparare l'hardware dell'host

Se si tratta di un nuovo host o l'hardware generato è cambiato, confronta
`/etc/nixos/hardware-configuration.nix` con il file host prima di sostituirlo.
Poi aggiungi individualmente gli eventuali file nuovi:

```bash
sudo cp /etc/nixos/hardware-configuration.nix o3/hosts/hostname/hardware.nix
sudo chown "$(id -u):$(id -g)" o3/hosts/hostname/hardware.nix
git add o3/hosts/hostname/hardware.nix
```

Sostituisci `hostname` col nome dell'output reale. Il `chown` evita che la copia
eseguita con `sudo` lasci nel repository un file posseduto da root. Clone e
confronto hardware si eseguono una sola volta.

## 3. Ripristinare i segreti e fare il primo boot

Il ripristino parte dalla cassaforte Bitwarden personale; l'inventario
di `secrets-management` dà per ogni voce path, proprietario, permessi e
prova. I segreti vanno al loro posto **prima** dei servizi che li usano:
quelli di sistema prima del boot della nuova generazione, quelli utente
prima di `home-manager switch` (sezione 4), altrimenti Syncthing genera
un'identità nuova e i mount Drive partono senza credenziali.

**Prerequisito**: Gmail aperta su un dispositivo indipendente dagli host
di casa, il telefono (decisione del custode, 2026-11-07). Su un dispositivo
nuovo `bw login` chiede email, master password e un codice mandato a quella
casella: senza, la cassaforte non si apre da zero. Provato su `neve` il
2026-11-07.

Il telefono non è l'unica via per il codice: il custode legge la stessa posta
anche da `norvegia`, `neve`, `game` e `deck`, e `norvegia` è anch'essa
indipendente dagli host di casa. Restare senza codice richiederebbe di perderli
tutti insieme, rischio che il custode giudica basso (2026-11-08). Conta che le
sessioni di posta siano ancora aperte al momento del bisogno; non è verificato
se un login Google da un dispositivo nuovo dipenda dal telefono.

### Aprire la cassaforte

```fish
nix shell nixpkgs#bitwarden-cli
bw login
set -x BW_SESSION (bw unlock --raw)
```

I comandi `bw` si lanciano in un terminale proprio, non dentro una
sessione con un agente: chiave di sessione e contenuti non devono finire in
una conversazione. `bw get notes <nome>` cerca per sottostringa
(`casa/deck/rclone` trova anche `casa/deck/rclone-familiare`): leggere le
note per nome esatto, scrivendole direttamente nel file di destinazione
senza stamparle:

```bash
nota() { # nome -> testo esatto della nota, su stdout
  local id
  id=$(bw list items --search "$1" | jq -r --arg n "$1" '.[] | select(.name == $n) | .id')
  [[ -n $id && $(wc -l <<<"$id") -eq 1 ]] || { echo "voce $1 non univoca" >&2; return 1; }
  bw get item "$id" | jq -j .notes
}
```

### Voci di sistema, prima del boot

- **Host key SSH** (`casa/<host>/ssh-host-ed25519`, `casa/<host>/ssh-host-rsa`):
  in `/etc/ssh/ssh_host_{ed25519,rsa}_key`, `root:root 0600`; la `.pub`
  si rigenera con `ssh-keygen -y -f`. Così gli altri host riconoscono
  l'host come prima.
- Su **deck**, entrambe le identità VPN prima di avviare i tunnel:
  - `casa/deck/wireguard-casa` in `/etc/wireguard/casa-vpn.key`: directory
    `root:root` `700`, chiave `600`, `.pub` derivata coerente con
    `identity.home.vpn.serverPublicKey`;
  - `casa/deck/wireguard-lavoro` in
    `/home/stele/.config/wireguard/work-office.key`: directory privata di
    `stele`, chiave `600`, public key derivata coerente con quella del peer
    `deck` dichiarata nel repo `example-org/nixos-ufficio`.

  Per confrontare la public key usare `wg pubkey` con la chiave privata in
  stdin, senza stamparla.

- Su **deck**, la password FTP: `sudo passwd scansioni` con la password
  della voce di login `casa/deck/ftp-scansioni` (provata il 2026-11-07); la
  password di aMule è nella voce di login `amule`.

### Voci utente, prima di Home Manager

- **Chiavi SSH utente** (`casa/<host>/ssh-utente`, e `casa/<host>/ssh-familiare`
  su `game` e `neve`): `~/.ssh/id_ed25519` e `~/.ssh/id_ed25519_familiare`,
  `0600`, `.pub` con `ssh-keygen -y`. Con la chiave ripristinata la
  sezione 5 non serve.
- **Syncthing** (`casa/<host>/syncthing`, `cert.pem` seguito da `key.pem`):
  divisa ai marcatori `BEGIN` in `~/.local/state/syncthing/cert.pem`
  (`0644`) e `key.pem` (`0600`), prima del primo avvio del servizio.
  Prova: Device ID uguale a quello di `~/.config/nixos/identity/home.nix`, poi un file
  di prova in `~/sync` che arriva sugli altri host. Ripristino reale
  provato su `neve` il 2026-11-07, sullo stesso host; su un host
  reinstallato l'ordine di avvio resta da collaudare.
- **rclone** (`casa/<host>/rclone` e `casa/<host>/rclone-familiare`):
  `~/.config/rclone/rclone.conf` e
  `~/.config/rclone-gdrive-familiare/rclone.conf`, `0600`, directory `0700`.
  Si rimette la copia **dello stesso host**, mai quella di un altro: due
  host con lo stesso token causavano i conflitti del 2026-05-29. I client
  OAuth sono in produzione e il refresh token del seed rinnova l'accesso
  (provato su `deck` il 2026-11-07): non serve un nuovo login.
- **gog**, solo su `deck`: `casa/gog-client` in
  `~/.config/gogcli/credentials.json` (`0600`), poi riautorizzazione per host secondo `google-workspace-cli`. I
  token vivono nel keyring e non sono nel seed: copiare la directory di
  configurazione non li ripristina.

Alla fine: `bw lock` e `bw logout` sull'host ripristinato, se non deve
tenere l'accesso alla cassaforte (oggi solo `deck` ha `bw` installato).
I dati locali seguono il loro backup distinto.

Preparare quindi la generazione e riavviare:

```bash
sudo nixos-rebuild boot --flake .#<host>
sudo reboot
```

## 4. Applicare Home Manager

```bash
o3/scripts/con-identita.sh home-manager switch --flake .#username@hostname
```

## 5. Configurare la chiave SSH utente

Se la chiave non è stata preservata né ripristinata dal seed (sezione 3):

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
cat ~/.ssh/id_ed25519.pub
```

Aggiungere la chiave pubblica al proprio account GitHub. Su `deck`, l'unico
host di casa che raggiunge l'ufficio, la chiave pubblica va autorizzata anche
nel repo `example-org/nixos-ufficio` per gli alias dei server.

## 6. Verificare i servizi utente

```bash
systemctl --user status syncthing
systemctl --user list-units 'rclone-mount-*' --all
```

## 7. Verificare le funzioni host-specifiche

- **`deck`** — controllare WireGuard casa, client VPN lavoro e aMule;
  il tunnel lavoro parte al boot (`network-architecture`): verificare con
  `sudo wg show lavoro` che il peer `office` sia caricato. Il Wi‑Fi
  è solo riserva del cavo e il suo profilo è imperativo (fuori dal repo):
  crearlo in DHCP, mai con l'IP statico `192.168.0.10` di `home0-static`,
  altrimenti il port-forward della VPN casa segue ora l'una ora l'altra
  interfaccia (`wireguard-home § IP di deck duplicato tra cavo e Wi‑Fi`).
  Verifica: `ip -4 -br addr` mostra `192.168.0.10` solo su `home0`
- **`neve`** — scanner, audio-manager, display-manager
- **`game`** — NVIDIA, llama.cpp, Docker NVIDIA e gaming stack; i pesi GGUF
  usati dai workflow esterni arrivano dal flake, quindi non serve alcun
  bootstrap manuale dei modelli LLM/OCR. Il modello Whisper è invece un file
  locale da ripristinare secondo `game-live-transcription`

## Ambienti dichiarativi dei progetti

Quando un repository contiene `flake.nix`, usare `nix develop` per ottenere
toolchain e dipendenze coerenti, invece di installarle nel profilo.

```bash
cd ~/repository-con-flake
nix develop
```

## Checklist

- [ ] cassaforte aperta da zero (Gmail sul telefono), segreti al loro posto prima dei servizi
- [ ] hostname corretto e rebuild completato, host key SSH come prima
- [ ] Home Manager applicato
- [ ] chiave SSH utente disponibile, GitHub accessibile via SSH
- [ ] Syncthing attivo col Device ID di `~/.config/nixos/identity/home.nix`
- [ ] mount rclone di custode e familiare attivi, senza nuovo login
- [ ] `bw lock` e `bw logout` sull'host, se non deve tenere la cassaforte
- [ ] identità WireGuard di `deck` ripristinata e verificata, se applicabile
- [ ] Wi‑Fi di `deck` in DHCP, `192.168.0.10` solo su `home0`, se applicabile
- [ ] catalogo `/models` di `game` raggiungibile, se applicabile
- [ ] funzioni specifiche dell'host verificate

Connessioni:

- [disaster-recovery](disaster-recovery.md)
- [client-desktop-architecture](client-desktop-architecture.md)
- [secrets-management](secrets-management.md)
- [google-workspace-cli](google-workspace-cli.md)
- [game-live-transcription](game-live-transcription.md)
- [network-architecture](network-architecture.md)
- [development-workflow](development-workflow.md)
- [common-commands](common-commands.md)
