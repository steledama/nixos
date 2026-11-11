---
stato: maturo
---

# Configuration patterns

Reference sui pattern con cui questo repository distribuisce responsabilità tra
flake, host, profili Home Manager e moduli riutilizzabili. Non è un tutorial
generico di Nix: descrive le convenzioni oggi realmente incarnate nel codice.

## Livelli della configurazione

- **output** — `flake.nix`: catalogo di host NixOS e profili `user@host`
- **baseline sistema** — `o3/hosts/default.nix`: configurazione comune a tutti gli host (`deck`, `game`, `neve`), stack desktop compreso
- **host** — `o3/hosts/<host>/default.nix`: differenze fisiche e funzionali del singolo host
- **baseline home** — `o3/home/default.nix`: configurazione CLI comune a tutti gli utenti
- **profilo home** — `o3/home/<user>/<host>.nix`: differenze del profilo utente su uno specifico host
- **moduli riutilizzabili** — `o3/modules/system/`, `o3/modules/home/`: policy e funzionalità condivise

La lettura corretta va dall'esterno verso l'interno: prima gli output del flake,
poi le baseline, poi le differenze host/profilo, infine i moduli che realizzano
le policy.

## Dove deve vivere una modifica

- **tutti gli host** — `o3/hosts/default.nix` oppure un modulo importato da lì
- **un solo host** — `o3/hosts/<host>/default.nix`
- **tutti i profili utente** — `o3/home/default.nix` oppure un modulo importato da lì
- **un solo profilo `user@host`** — `o3/home/<user>/<host>.nix`
- **una funzionalità riusabile** — un modulo in `o3/modules/system/` o `o3/modules/home/`
- **una policy trasversale** — un modulo dedicato, non duplicazione tra host

La regola centrale è: **logica comune nei moduli, differenze reali nei file
host/profilo**. Una configurazione condivisa da più host ma non da tutti si
importa come modulo dai file host che la usano; non serve un livello
intermedio. Se una funzionalità esiste su un solo host ma non è
riutilizzabile, può restare locale.

## Pacchetti: un solo livello

Ogni applicazione è dichiarata a **un solo livello**, scelto per policy; la
configurazione utente vive sempre a home. Due regole, non una:

- **App GUI** → pacchetto a **system** (`gui-apps.nix`), config a home. Esempi: zed (`gui-apps.nix` + `modules/home/zed.nix` che scrive solo
  settings.json), chromium, noctalia (binario in
  `modules/system/niri.nix`, unit e keybind home puntano a
  `/run/current-system/sw/bin`). Il modulo home del compositor si chiama
  `programs.niriConfig` proprio per dichiarare "solo config".
- **Strumenti dev/CLI dell'utente** → pacchetto **e** config a **home**
  (dev-tools, helix, git, syncthing, claude-code). Il binario a home è il
  razionale delle timeline disaccoppiate: update senza sudo, pin `ai`
  fresco, rollback utente (`nix-flakes.md § Input nixpkgs separati`).

**Eccezioni dichiarate** (inventario vincolante, enforcement in
`kb_tools.py facts` — check `package_level_uniqueness`,
`programs_level_uniqueness`, `home_refs_to_system_gui`; la lista è la
costante `DUAL_LEVEL_ALLOWED`):

- **fish** — doppia dichiarazione strutturale: system per disponibilità
  universale (/etc/shells, ponte bash PATH-aware, root), home per
  configurazione e iterazione. Due binari reali; il ponte fa vincere la
  fish home dove esiste.
- **ssh** — `programs.ssh` compare a entrambi i livelli ma è config-only in
  entrambi (system: toggle client in `o3/hosts/default.nix`; home:
  `~/.ssh/config`): nessun binario duplicato, il client viene dalla base
  NixOS.

Anche **foot** segue la regola GUI: pacchetto e registrazione
`xdg-terminal-exec` a system (`gui-apps.nix`), preferenze utente
(`foot.ini`) nel modulo home niri. Prassi legittima e fuori dal perimetro
del check: interpolare `${pkgs.X}` negli script home per utility di
plumbing (coreutils, gawk, …) — è autocontenimento Nix, non duplicazione
d'app; il check vigila solo sui riferimenti home al set GUI/desktop di
sistema.

## Famiglie di moduli presenti

- **hardware** — esempi: `hardware/intel.nix`, `hardware/nvidia.nix`, `hardware/scanner.nix`; ruolo: capacità legate al dispositivo reale
- **servizi sistema** — esempi: `services/docker.nix`, `services/wireguard.nix`, `services/llama-cpp.nix`; ruolo: demoni e infrastruttura di sistema
- **desktop sistema** — esempi: `niri.nix`, `gui-apps.nix`, `gaming.nix`; ruolo: stack grafico e funzioni desktop
- **home condivisi** — esempi: `shell.nix`, `dev-tools.nix`, `git.nix`; ruolo: strumenti utente riutilizzabili
- **home host-specifici** — esempi: `audio-manager.nix`, `display-manager.nix`, `game-audio-rec.nix`; ruolo: comportamento utente legato a un host

## Pattern osservati nei moduli

I moduli riutilizzabili espongono normalmente opzioni esplicite e attivano la
configurazione con `mkIf`. I moduli più articolati definiscono `cfg` per evitare
ripetizione e usano `mkMerge` quando coordinano più blocchi condizionali.

Esempi canonici nel codice:

- `o3/modules/system/services/docker.nix` — modulo compatto con opzioni e `mkIf`;
- `o3/modules/system/services/wireguard.nix` — servizio con opzioni strutturate;
- `o3/modules/home/rclone.nix` — modulo Home Manager con sotto-opzioni e servizi
  generati.

Per capire come scrivere un nuovo modulo, imitare prima il modulo reale più
vicino al caso d'uso invece di partire da uno schema astratto.

## Import pattern

Gli snippet seguenti sono campioni rappresentativi di pattern vivi, non template
astratti da copiare senza verifica. La forma comune di un host è: hardware
locale, baseline sistema e moduli espliciti necessari al caso reale.

```nix
imports = [
  ./hardware.nix
  ../default.nix
  ../../modules/system/hardware/intel.nix
];
```

Stack desktop e toggle di rete/firewall arrivano dalla baseline; l'host
aggiunge solo differenze fisiche o funzionali, e
mantiene i fatti per-host come i gruppi utente e `system.stateVersion`.

La forma comune di un profilo Home Manager è: baseline home e moduli espliciti
necessari a quel profilo:

```nix
imports = [
  ../default.nix
  ../../modules/home/dev-tools.nix
  ../../modules/home/ssh-common.nix
  ../../modules/home/rclone.nix
];
```

Gli import devono restare espliciti: la presenza nel repository non implica
attivazione. Questo rende visibile chi usa cosa e sostiene il principio zero
dead code.

## Vocabolario dei nomi

Il repository distingue due registri linguistici, e la distinzione non è
estetica: separa ciò che è codice da ciò che una persona digita.

- **identificatori di codice Nix in inglese** — input del flake, opzioni dei
  moduli, nomi di file: `wireguardWorkClient`, `~/.config/nixos/identity/work.nix`;
- **nomi runtime visibili all'utente e vocabolario di dominio in italiano** —
  interfacce di rete e unità systemd che si digitano (`wireguard-lavoro`,
  `wireguard-casa`), argomenti delle skill di dominio.

Il criterio è chi legge il nome. Un input del flake lo legge solo chi modifica
`flake.nix`; `systemctl start wireguard-lavoro` lo digita chi opera la
macchina, e deve dire quale mondo serve, non quale tecnologia lo implementa.
Senza questa regola l'incoerenza si sposta invece di sparire: è la ragione per
cui `nixpkgs-stable` era diventato `nixpkgs-work` (inglese, è codice; oggi
quell'input vive nel repo `example-org/nixos-ufficio`) mentre le
interfacce WireGuard sono diventate `lavoro`/`casa` (italiano, sono comandi).

## Invarianti da preservare

- ogni modulo esistente deve essere importato da almeno un host o profilo;
- i moduli hardware devono corrispondere all'hardware reale;
- la baseline home resta terminal-first; pacchetti e app GUI non vanno
  reintrodotti lì;
- gli host dichiarano differenze, non copie della configurazione comune;
- gli esempi documentali devono derivare da pattern vivi nel codice, non da
  schemi plausibili ma non adottati;
- i nomi nuovi seguono il vocabolario sopra: inglese per il codice, italiano
  per ciò che si digita.

## Se devi estendere il repository

Per aggiungere host, profili o moduli, usare il runbook operativo
`project-extension`.

Connessioni:

- [project-extension](project-extension.md)
- [design-principles](../method/design-principles.md)
- [nix-flakes](nix-flakes.md)
- [home-manager](home-manager.md)
