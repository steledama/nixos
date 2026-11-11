---
stato: maturo
---

# Google Workspace CLI

Il CLI Google Workspace `gogcli` (binario `gog`) fornisce accesso agente a
Gmail, Calendar, Drive, Docs e Sheets. È installato via Home Manager in
`o3/modules/home/google-workspace-cli.nix`,
importato dalla baseline `o3/home/default.nix` e quindi presente su tutti i
profili.
La versione corrente arriva da un overlay locale permanente in `flake.nix`, che
segue le release di `openclaw/gogcli` più velocemente di nixpkgs. Versione e
hash hanno lì la loro fonte unica; i bump li fa il ramo `casa` di
`/manutenzione`, il workflow di aggiornamento vive in `development-environment`.

## Perché CLI invece di MCP

Il CLI non richiede processi server di lunga durata, supporta output `--plain` e
`--json`, scarica allegati direttamente nel filesystem e usa la sintassi nativa
di Gmail (`from:`, `to:`, `newer_than:`, operatori booleani).

## Setup auth per-host

`gog` è installato solo su `deck`, dove lo usano i cicli `salute` ed
`economia`: da `game` e `neve` è stato tolto il 2026-11-07, pacchetto,
client e token compresi (custode: lì non si usa). L'autenticazione è
per-host, non sincronizzata. Il client OAuth sta in
`~/.config/gogcli/credentials.json` (`0600`); i token in GNOME Keyring
(backend `auto`), collezione `gogcli` in
`~/.local/share/keyrings/gogcli.keyring` (`0600`), cifrata con la password
dell'utente, che il custode digita a ogni riavvio di `deck`.

Copiare `~/.config/gogcli/` non basta a certificare il recupero dei token.
Il backup del keyring richiede il relativo materiale di sblocco e un
collaudo separato. Su host nuovi o reinstallati il percorso previsto
resta la riautorizzazione per-host.

### Prerequisito: OAuth client credentials

Serve un file JSON di OAuth client credentials di tipo "Desktop app" da Google Cloud Console (progetto GCP personale, già esistente). La copia di riferimento è la nota `casa/gog-client` della cassaforte (dall'originale `oauth-client.json` che stava su `game`); in alternativa si riscarica da Google Cloud Console.

Il nome della credenziale, per esempio `Desktop client 1`, è un'etichetta
interna visibile solo nella Google API Console. Il nome mostrato agli utenti
durante il consenso, per esempio `rclone`, appartiene invece al branding della
schermata OAuth del progetto e non è contenuto nel JSON delle credenziali.

### Flusso

```bash
# 1. Registra le credenziali OAuth client
gog auth credentials set ~/.config/gogcli/oauth-client.json

# 2. Autorizza un account (apre browser per consenso)
gog auth add user@example.com

# 3. Verifica
gog auth list
gog gmail search 'newer_than:1d' --max 3 --plain
```

Per host headless o accesso remoto, `gog auth add` accetta `--manual` (incolla URL di redirect) o `--remote --step 1`/`--step 2` (flusso a due fasi server-friendly).

### Account multipli

Gli account Google Drive personali (custode, familiare) usati da rclone per i mount Drive (`rclone-gdrive`) possono essere aggiunti separatamente con `gog auth add <email>` se serve operare su più mailbox o calendari.

## Fonti del progetto GCP

Il progetto di riferimento è registrato in `world.md § Fonti`. Usare il
`PROJECT_ID` canonico della Google Cloud Console per quote e operazioni API;
non ricavarlo dal display name o dal nome mostrato nella schermata di consenso.

La console IAM è la fonte dei ruoli effettivi: verificarli prima di modificare
API, quote o autorizzazioni. Il file locale OAuth identifica un client, ma non
prova né i permessi IAM correnti né lo stato `Production` del consenso.

`gog` e il remote `gdrive-personale` condividono il client OAuth (progetto
`371243294687`, verificato su `deck` il 2026-11-07); gli altri remote rclone usano progetti distinti.
Prima di ruotare le credenziali confrontare i soli client ID nelle
configurazioni locali, senza stampare client secret o token: una rotazione
può coinvolgere sia gog sia il mount Drive.

## Comandi quotidiani

La guida d'uso operativa (query Gmail, RFC3339 in Calendar, free/busy, ricerca eventi, gestione allegati) vive nel nodo `~/economia/kb/strumenti-google-workspace.md`, che è il progetto che usa i CLI in modo sistematico. Qui restano solo le preoccupazioni di setup di sistema.

## Segreti coinvolti

Client OAuth e materiale del keyring restano nei percorsi locali sopra,
fuori dal repository.
I pattern Git per export OAuth sono una protezione aggiuntiva, non coprono
qualunque nome possibile: `oauth-client.json` non va copiato nel checkout.
Inventario e vincoli di backup: `secrets-management`.

Connessioni:

- [development-environment](development-environment.md)
- [secrets-management](secrets-management.md)
- [rclone-gdrive](rclone-gdrive.md)
