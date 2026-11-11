---
stato: maturo
---

# Rclone operations

Runbook per creare, aggiungere e gestire mount Google Drive nel modello corrente
del progetto. Il nodo architetturale separato descrive come il sistema è
strutturato; questo nodo spiega come operarlo.

## Creare un Client ID personalizzato

È consigliato usare un Client ID Google dedicato invece di quello pubblico di
rclone, per evitare rate limiting condiviso.

Procedura sintetica su Google Cloud Console:

1. crea o seleziona un progetto;
2. abilita Google Drive API;
3. configura la schermata OAuth;
4. aggiungi gli scope:
   - `https://www.googleapis.com/auth/docs`
   - `https://www.googleapis.com/auth/drive`
   - `https://www.googleapis.com/auth/drive.metadata.readonly`
5. aggiungi l'utente come tester se richiesto;
6. crea credenziali OAuth per applicazione desktop;
7. conserva Client ID e Client Secret fuori da Git;
8. per l'uso persistente, portare il progetto OAuth External in `Production`.

In `Testing`, i refresh token con scope Drive scadono dopo sette giorni:
completare lo stato del progetto prima dell'autorizzazione definitiva. Le
quote API sono un problema distinto, normalmente segnalato con 403/429;
verificare il motivo restituito dall'API.

## Aggiungere un nuovo account Google Drive

### 1. Configurare il remote

```bash
rclone config
```

Scelte principali:

1. `n` — new remote
2. nome `gdrive-NOME`
3. storage `drive`
4. inserire Client ID e Client Secret
5. scope `1`
6. completare OAuth nel browser
7. confermare il remote

Verifica:

```bash
rclone listremotes
```

### 2. Aggiornare Home Manager

Nel profilo dell'host:

```nix
services.rcloneMount = {
  enable = true;
  mounts = {
    gdrive-familiare = {
      remote = "gdrive-familiare";
      mountPoint = "Drive/gdrive-familiare";
    };
  };
};
```

### 3. Applicare la configurazione

```bash
o3/scripts/con-identita.sh home-manager switch --flake .#USERNAME@HOSTNAME
```

### 4. Verificare il mount

```bash
systemctl --user status rclone-mount-gdrive-familiare.service
findmnt -T ~/Drive/gdrive-familiare
```

### 5. Creare un symlink comodo, se serve

```bash
mkdir -p ~/sync/familiare
ln -s ../../Drive/gdrive-familiare ~/sync/familiare/Drive
```

## Gestione quotidiana

### Servizi

```bash
systemctl --user list-units 'rclone-mount-gdrive-*' --all
systemctl --user restart rclone-mount-gdrive-familiare.service
journalctl --user -u rclone-mount-gdrive-familiare.service --since "1 hour ago"
```

### Helper `rimonta-drive`

Il comando `rimonta-drive` propone gli account montati dal profilo dell'host
(`services.rcloneMount.mounts`): custode e familiare sui tre host.

### Verifiche

```bash
rclone listremotes
rclone lsd gdrive-familiare:
test -f ~/.config/rclone/rclone.conf && stat -c '%a %n' ~/.config/rclone/rclone.conf
```

Non stampare `rclone.conf` nei log o in una sessione condivisa: contiene client
secret e refresh token. Per ispezionare un remote usa `rclone config redacted NOME`. Controlla
comunque il risultato prima di condividerlo: la redazione automatica non
garantisce di riconoscere ogni dato sensibile. `config show` stampa invece la
configurazione decifrata e non accetta un flag `--obscure`.

### Duplicati Google Drive

```bash
rclone dedupe --dedupe-mode list gdrive-NOME:
rclone dedupe --dedupe-mode largest --dry-run gdrive-NOME:
```

Esaminare il risultato e scegliere esplicitamente la politica prima di
rieseguire senza `--dry-run`: `largest`, `newest` e `oldest` possono eliminare
copie remote. Anche `rename` elimina prima i duplicati identici e rinomina
quelli restanti; la deduplica per nome può inoltre fondere directory omonime.
Conservare prima i file che potrebbero servire. Modalità disponibili:

- `largest`
- `newest`
- `oldest`
- `rename`

## Configurazioni avanzate

### Mount privato

Un mount con `private = true` legge il remote da
`~/.config/rclone-<nome>/rclone.conf` invece che dal file condiviso, ed è
invisibile ai cicli autonomi (`rclone-gdrive`). I comandi a mano vogliono
`--config`:

```bash
rclone --config ~/.config/rclone-gdrive-familiare/rclone.conf listremotes
rclone --config ~/.config/rclone-gdrive-familiare/rclone.conf lsd gdrive-familiare:
```

Per autorizzare l'account su un host nuovo, con un login proprio e non
copiando il token da un altro host:

```bash
mkdir -p -m 700 ~/.config/rclone-gdrive-familiare
rclone --config ~/.config/rclone-gdrive-familiare/rclone.conf config
```

### Montare una sottocartella remota

```nix
services.rcloneMount = {
  enable = true;
  mounts = {
    custode-documenti = {
      remote = "gdrive-personale";
      remotePath = "Documenti";
      mountPoint = "Drive/custode-documenti";
    };
  };
};
```

## Troubleshooting

### Mount non attivo

```bash
systemctl --user status rclone-mount-gdrive-NOME.service
journalctl --user -u rclone-mount-gdrive-NOME.service --since "30 minutes ago"
```

### Errore permessi su file condivisi

```text
googleapi: Error 403: insufficientFilePermissions
```

I file condivisi da altri utenti potrebbero dover essere gestiti da Google Drive
web.

Connessioni:

- [rclone-gdrive](rclone-gdrive.md)
- [secrets-management](secrets-management.md)
- [home-manager](home-manager.md)
- [home-cli-helpers](home-cli-helpers.md)
- [Rclone config redacted](https://rclone.org/commands/rclone_config_redacted/)
- [Rclone dedupe](https://rclone.org/commands/rclone_dedupe/)
- [Google OAuth token expiration](https://developers.google.com/identity/protocols/oauth2#expiration)
