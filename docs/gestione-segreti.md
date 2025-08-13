# Gestione dei Segreti con Agenix

Questa guida spiega come gestire i segreti (credenziali SMB, token, chiavi API) in questa configurazione NixOS utilizzando `agenix`. `agenix` permette di salvare i segreti in formato criptato all'interno del repository Git, garantendo sicurezza e riproducibilità.

**IMPORTANTE:** Le chiavi SSH sono gestite manualmente per semplicità e affidabilità, non tramite agenix.

## Prerequisiti

La configurazione di base di `agenix` è già stata integrata nel sistema tramite `flake.nix`. Questa guida si concentra sulla parte operativa: come aggiungere e aggiornare i segreti.

## Configurazione negli Host

Per usare un segreto, ogni host che ne ha bisogno deve avere **due configurazioni necessarie** nel suo file `default.nix` (es. `hosts/pc-sviluppo/default.nix`):

### 1. Configurazione del Percorso della Chiave Privata
```nix
# Dice ad agenix dove trovare la chiave privata per decriptare i segreti
age.identityPaths = ["/etc/ssh/ssh_host_ed25519_key"];
```

### 2. Definizione del Segreto Specifico
```nix
# Dice al sistema quale segreto decriptare e dove metterlo
age.secrets.smb-secrets.file = ../../secrets/smb-secrets.age;
```

**Perché entrambe sono necessarie:**
- La prima dice: "Usa questa chiave per decriptare"
- La seconda dice: "Decripta questo file specifico"

**Esempio completo** per `pc-sviluppo` e `srv-norvegia`:
```nix
# Configurazione agenix per la gestione dei segreti
age.identityPaths = ["/etc/ssh/ssh_host_ed25519_key"];

# Definizione del segreto per Samba
age.secrets.smb-secrets.file = ../../secrets/smb-secrets.age;
```

Se in futuro dovessi aggiungere un nuovo segreto (es. token API), dovrai aggiungere una nuova definizione `age.secrets.<nome>.file` ma l'`identityPaths` rimarrà lo stesso.

## Procedura Operativa

Seguire questi passaggi per aggiungere un nuovo segreto o aggiornarne uno esistente.

### 1. Ottenere le Chiavi Pubbliche (Identità)

**IMPORTANTE: Distinzione tra `secrets.nix` e configurazione host**

- **`secrets.nix`**: Contiene le chiavi **pubbliche** usate da `age` per **criptare** i segreti quando li crei/modifichi
- **`age.identityPaths` negli host**: Specifica dove trovare la chiave **privata** per **decriptare** i segreti a runtime

Per criptare un segreto, `agenix` ha bisogno di sapere per chi lo sta criptando. Le "identità" sono le chiavi pubbliche SSH delle macchine che devono poter leggere il segreto.

Il file che le contiene è `secrets.nix` nella root del progetto.

Per popolarlo correttamente, devi ottenere le chiavi pubbliche degli host che necessitano di accesso ai segreti:

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

2.  **Cripta il file** usando il comando `age`:
    Il nostro segreto `smb-secrets` è definito nel modulo NixOS per essere letto da `secrets/smb-secrets.age`.

    **IMPORTANTE:** Se `agenix` non è disponibile nel sistema, usa `age` direttamente tramite nix-shell:
    ```bash
    nix-shell -p age --run "age -R secrets.nix -o secrets/smb-secrets.age /tmp/temp-credentials.txt"
    ```

    Oppure se hai già `agenix` installato nel sistema:
    ```bash
    agenix -e secrets/smb-secrets.age
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

NixOS si occuperà di decriptare il file e renderlo disponibile al servizio corretto nel percorso specificato dalla configurazione (attualmente punta direttamente ai file nella cartella `secrets/`).

## Risoluzione Problemi

### Problema di Bootstrap dei Segreti

Quando si introduce agenix per la prima volta in una configurazione esistente, potresti incontrare un problema circolare:
- Non puoi fare la rebuild perché manca la configurazione completa dei segreti
- Non puoi criptare i segreti perché `agenix` non è disponibile nel sistema

**Soluzione con `age`:**
1. Usa `nix-shell` per accedere temporaneamente ad `age`:
   ```bash
   nix-shell -p age
   ```

2. All'interno della shell, cripta i tuoi segreti usando le chiavi pubbliche definite in `secrets.nix`:
   ```bash
   age -R secrets.nix -o secrets/smb-secrets.age /tmp/temp-credentials.txt
   ```

3. Esci dalla shell e procedi con la rebuild:
   ```bash
   exit
   ```
   
   **IMPORTANTE:** Per la prima rebuild con i segreti, usa `boot` invece di `switch` per evitare errori:
   ```bash
   sudo nixos-rebuild boot --flake .
   ```
   
   Poi riavvia il sistema:
   ```bash
   sudo reboot
   ```

4. Dopo il riavvio, `agenix` sarà disponibile e potrai usare normalmente `switch` per future operazioni:
   ```bash
   sudo nixos-rebuild switch --flake .
   ```

### Verifica dei Segreti

Per verificare che un segreto sia configurato correttamente:
```bash
# Verifica che il file criptato esista nella repository
ls -la secrets/

# Dopo la rebuild, verifica che la configurazione lo riconosca
sudo nixos-rebuild switch --flake . --dry-run
```
