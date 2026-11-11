---
stato: maturo
---

# Project extension

Runbook per aggiungere host, profili Home Manager o moduli riutilizzabili senza
rompere le convenzioni attuali del repository.

## Prima di iniziare

- leggere `configuration-patterns` per scegliere il livello corretto;
- verificare se una funzionalità simile esiste già;
- se la modifica introduce un nuovo file, fare `git add` prima del rebuild: Nix
  non vede i file non tracciati referenziati dal flake.

## Aggiungere un host NixOS

### 1. Creare la directory host

```bash
mkdir -p o3/hosts/new-hostname
cp /etc/nixos/hardware-configuration.nix o3/hosts/new-hostname/hardware.nix
```

### 2. Creare `o3/hosts/new-hostname/default.nix`

Usare come modello l'host reale più vicino al nuovo caso d'uso. La struttura
minima di un host deve includere:

```nix
{...}: {
  imports = [
    ./hardware.nix
    ../default.nix
    ../../modules/system/hardware/intel.nix
  ];

  networking.hostName = "new-hostname";

  users.users.username = {
    isNormalUser = true;
    description = "username";
    extraGroups = ["networkmanager" "wheel" "video"];
  };

  system.stateVersion = "<release-iniziale>";
}
```

Importare il modulo hardware che corrisponde alla macchina reale: oggi
esistono `intel.nix` e `nvidia.nix`, e un host AMD senza esigenze proprie non
ne importa nessuno (come `game` per la CPU). La baseline assegna già lo stack
desktop e i toggle di rete/firewall base; il file host dichiara invece i fatti
per-host — utente con i suoi gruppi (i base `networkmanager`, `wheel`, `video`
più gli extra specifici), `system.stateVersion`, porte, profili di rete o
servizi propri.

### 3. Registrare l'output nel flake

```nix
nixosConfigurations.new-hostname = mkHost "new-hostname";
```

### 4. Verificare

```bash
git add o3/hosts/new-hostname/default.nix o3/hosts/new-hostname/hardware.nix
o3/scripts/con-identita.sh nixos-rebuild build --flake .#new-hostname
```

## Aggiungere un profilo Home Manager

### 1. Creare il file profilo

```bash
mkdir -p o3/home/new-user
```

Creare `o3/home/new-user/hostname.nix` usando come modello il profilo reale più
simile:

```nix
{...}: {
  imports = [
    ../default.nix
    ../../modules/home/dev-tools.nix
    ../../modules/home/ssh-common.nix
  ];

  home.username = "new-user";
  home.homeDirectory = "/home/new-user";

  home.stateVersion = "<release-iniziale>";
}
```

Importare solo i moduli effettivamente necessari al profilo. Per un desktop,
seguire i profili client reali.
Per `stateVersion`, usare la release NixOS o Home Manager con cui il nuovo host
o profilo nasce realmente. Il valore registra l'epoca iniziale e non va
derivato dalla release corrente né alzato retroattivamente sui profili
esistenti. Sostituire sempre il segnaposto prima della build.

### 2. Registrare l'output nel flake

```nix
homeConfigurations."new-user@hostname" = mkHome {
  username = "new-user";
  hostname = "hostname";
};
```

### 3. Verificare e attivare

```bash
git add o3/home/new-user/hostname.nix flake.nix
nix build '.#homeConfigurations."new-user@hostname".activationPackage'
o3/scripts/con-identita.sh home-manager switch --flake .#new-user@hostname
```

## Aggiungere un modulo riutilizzabile

### 1. Scegliere il posto giusto

- **hardware** — `o3/modules/system/hardware/`
- **servizio sistema** — `o3/modules/system/services/`
- **policy o funzione sistema trasversale** — `o3/modules/system/`
- **configurazione utente riutilizzabile** — `o3/modules/home/`

### 2. Partire da un esempio reale

- **modulo piccolo con opzioni** — copiare il pattern da `o3/modules/system/services/docker.nix`
- **servizio articolato** — copiare il pattern da `o3/modules/system/services/wireguard.nix`
- **modulo Home Manager con servizi generati** — copiare il pattern da `o3/modules/home/rclone.nix`

### 3. Importare il modulo

Un modulo nuovo non deve restare dormiente nel repository. Importarlo subito nel
profilo o host che lo usa; se non esiste ancora un utilizzatore reale, non
aggiungerlo.

### 4. Verificare

```bash
# Aggiungi individualmente il nuovo modulo e il file che lo importa.
git add o3/modules/system/services/example.nix o3/hosts/example/default.nix
o3/scripts/con-identita.sh nixos-rebuild build --flake .#hostname
# oppure, per soli moduli home:
nix build '.#homeConfigurations."user@hostname".activationPackage'
```

## Checklist finale

- [ ] il nuovo file è stato aggiunto a Git;
- [ ] il posizionamento rispetta il livello corretto;
- [ ] gli import sono espliciti;
- [ ] nessun modulo è stato aggiunto “per il futuro”;
- [ ] eventuali moduli hardware corrispondono al dispositivo reale;
- [ ] il flake espone il nuovo output, se necessario;
- [ ] la documentazione viene aggiornata solo se cambia il modello del progetto.

Connessioni:

- [configuration-patterns](configuration-patterns.md)
- [nix-flakes](nix-flakes.md)
- [home-manager](home-manager.md)
- [design-principles](../method/design-principles.md)
- [development-workflow](development-workflow.md)
