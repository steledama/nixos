# Gestione dei Segreti con Agenix

Questa guida spiega come gestire i segreti (password, token, chiavi API) in questa configurazione NixOS utilizzando `agenix`. `agenix` permette di salvare i segreti in formato criptato all'interno del repository Git, garantendo sicurezza e riproducibilità.

## Prerequisiti

La configurazione di base di `agenix` è già stata integrata nel sistema tramite `flake.nix`. Questa guida si concentra sulla parte operativa: come aggiungere e aggiornare i segreti.

## Definire un Nuovo Segreto

Per usare un segreto, devi prima definirlo nella configurazione NixOS dell'host che lo utilizzerà. La definizione va inserita nel file `default.nix` dell'host (es. `hosts/pc-sviluppo/default.nix`).

L'opzione da usare è `age.secrets.<nome-del-segreto>.file`, dove specifichi il percorso del file criptato.

**Esempio:** Per definire il nostro segreto `smb-secrets`, abbiamo aggiunto questo codice ai file `default.nix` di `pc-sviluppo` e `srv-norvegia`:

```nix
age.secrets.smb-secrets.file = ../../secrets/smb-secrets.age;
```

Se in futuro dovessi aggiungere un nuovo segreto, per esempio per un token API, dovrai prima aggiugere una definizione simile nel file dell'host che ne ha bisogno.

## Procedura Operativa

Seguire questi passaggi per aggiungere un nuovo segreto o aggiornarne uno esistente.

### 1. Ottenere le Chiavi Pubbliche (Identità)

Per criptare un segreto, `agenix` ha bisogno di sapere per chi lo sta criptando. Le "identità" sono le chiavi pubbliche SSH delle macchine e degli utenti che devono poter leggere il segreto.

Il file che le contiene è `secrets.nix` nella root del progetto.

Per popolarlo correttamente, devi ottenere le seguenti chiavi:

*   **Chiave Pubblica dell'Utente** (permette a te di modificare i segreti):
    ```bash
    cat ~/.ssh/id_ed25519.pub
    ```
    *Se non esiste, creala con `ssh-keygen -t ed25519`.*

*   **Chiave Pubblica dell'Host** (permette alla macchina di usare il segreto):
    La chiave si trova in `/etc/ssh/ssh_host_ed25519_key.pub`. Devi recuperarla da ogni host che ha bisogno di accedere al segreto.

    Ad esempio, per `pc-sviluppo`:
    ```bash
    # Esegui questo comando su pc-sviluppo
    cat /etc/ssh/ssh_host_ed25519_key.pub
    ```

    Per `srv-norvegia`:
    ```bash
    # Esegui questo comando su srv-norvegia
    cat /etc/ssh/ssh_host_ed25519_key.pub
    ```

### 2. Aggiornare il file `secrets.nix`

Apri il file `secrets.nix` e incolla le chiavi pubbliche che hai raccolto, una per riga, sostituendo i segnaposto.

**Esempio:**
```nix
# secrets.nix
[
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM... tu@email.com"
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG... root@pc-sviluppo"
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH... root@srv-norvegia"
]
```

### 3. Creare e Criptare un Segreto

Supponiamo di voler creare il segreto per Samba (`smb-secrets`).

1.  **Crea un file temporaneo in chiaro** con le credenziali:
    ```bash
    # Non salvare questo file nel repository!
    echo "username=myuser" > /tmp/temp-credentials.txt
    echo "password=mypassword" >> /tmp/temp-credentials.txt
    ```

2.  **Cripta il file** usando il comando `agenix`:
    Il nostro segreto `smb-secrets` è definito nel modulo NixOS per essere letto da `secrets/smb-secrets.age`.

    ```bash
    agenix -e /tmp/temp-credentials.txt -o secrets/smb-secrets.age
    ```

3.  **Pulisci il file temporaneo**:
    ```bash
    rm /tmp/temp-credentials.txt
    ```

Il file `secrets/smb-secrets.age` è ora pronto e può essere aggiunto a Git in sicurezza.

### 4. Applicare la Configurazione

Dopo aver aggiunto o modificato un segreto, applica la configurazione NixOS sull'host desiderato:

```bash
sudo nixos-rebuild switch --flake .
```

NixOS si occuperà di decriptare il file e renderlo disponibile al servizio corretto nel percorso `/run/secrets/smb-secrets`.
