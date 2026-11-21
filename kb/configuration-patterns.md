---
stato: maturo
---

# Configuration patterns

Reference sui pattern con cui questo repository distribuisce responsabilità tra
flake, host, profili Home Manager e moduli riutilizzabili. Non è un tutorial
generico di Nix: descrive le convenzioni oggi realmente incarnate nel codice.

## Livelli della configurazione

- **output** — `flake.nix`: catalogo di host NixOS e profili `user@host`
- **baseline sistema** — `o3/hosts/default.nix`: tutto ciò che i tre host condividono, compresi stack desktop, utente `stele` con auto-login e lingering, chi entra via SSH
- **host** — `o3/hosts/<host>/default.nix`: solo ciò che l'host ha in più (hardware, servizi, gruppi extra, rete propria)
- **baseline home** — `o3/home/default.nix`: l'ambiente utente comune ai tre profili: shell, editor, tooling di sviluppo, SSH, Syncthing, mount Drive, configurazione Niri
- **profilo home** — `o3/home/<user>/<host>.nix`: solo ciò che il profilo ha in più sul suo host
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

- **Privilegi o integrazione col sistema** → pacchetto a **system**: ciò che
  richiede setuid, capability, regole udev, polkit, D-Bus o unità di sistema,
  porte del firewall, moduli del kernel; ciò che serve prima del login o fuori
  dalla sessione utente (greeter, compositor e sessione, portali, servizi di
  montaggio `udisks2`/`gvfs`); driver e hardware. Un `programs.<x>.enable` di
  NixOS che fa più che installare è un indizio di questo livello. Esempi:
  niri e noctalia (binario in `modules/system/niri.nix`, unit e keybind home
  puntano a `/run/current-system/sw/bin`); il modulo home del compositor si
  chiama `programs.niriConfig` proprio per dichiarare "solo config".
- **Base di soccorso** → a **system**: terminale (foot), editor (nano e
  helix) e git disponibili da TTY e a root anche quando la home non si attiva.
- **App dell'utente**, grafiche o da terminale → pacchetto **e** config a
  **home** (dev-tools, helix, git, syncthing, claude-code, nemo). Il binario a
  home vuol dire update senza sudo, attivazione delegabile all'agente e
  rollback utente.

Il livello decide chi attiva e come si torna indietro, non la freschezza:
sistema e home leggono lo stesso pin `nixpkgs`, aggiornato insieme ogni
settimana. Un input separato si giustifica solo per una cadenza propria con
un motivo concreto: `ai` per gli agenti, quotidiano; `nixpkgs-whisper` per
la build CUDA su game (`nix-flakes.md § Input nixpkgs separati`).

Le app grafiche dell'utente stanno in `o3/modules/home/gui-apps.nix`; a
system, in `o3/modules/system/gui-apps.nix`, resta solo foot. Chi ha una
dipendenza di sistema la tiene separata dal pacchetto: seahorse usa il
keyring avviato da `niri.nix`, usbimager scrive tramite `udisks2`.

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
- **git** e **helix** — base di soccorso: `programs.git.enable` e il
  pacchetto `helix` in `o3/hosts/default.nix`, utilizzabili da TTY e da root
  quando la home non si attiva; a home restano pacchetto e configurazione
  (`modules/home/git.nix`, `modules/home/helix.nix`). Col pin comune i due
  livelli puntano allo stesso store path; nano resta l'editor di default.

**foot** resta a system come terminale della base di soccorso: pacchetto e
registrazione `xdg-terminal-exec` in `gui-apps.nix`, preferenze utente
(`foot.ini`) nel modulo home niri. Prassi legittima e fuori dal perimetro
del check: interpolare `${pkgs.X}` negli script home per utility di
plumbing (coreutils, gawk, …) — è autocontenimento Nix, non duplicazione
d'app; il check vigila solo sui riferimenti home al set GUI/desktop di
sistema.

## Configurazione a strati: dichiarato e GUI

Quando un'app separa la configurazione scritta a mano dagli override salvati
dalla propria GUI, il repo dichiara solo le scelte stabili e da riprodurre
su ogni host; ciò che si regola spesso o dipende dall'host resta alla GUI.

Il caso è **Noctalia v5**. Legge in ordine `~/.config/noctalia/*.toml`
(scritto da `o3/modules/home/niri.nix`, quindi in sola lettura) e poi
`~/.local/state/noctalia/settings.toml`, che la GUI scrive e che **vince**
sullo strato dichiarato. Lato repo: lancio delle app come servizi systemd e
formato dell'orologio (`[widget.clock]`, data in italiano). Lato GUI:
disposizione della barra, tema, sfondo, inattività e schermata di blocco.
Se un valore dichiarato non ha effetto, la causa è quasi sempre la stessa
chiave in `settings.toml`; cancellare quel file azzera solo gli override.
I nomi di giorno e mese seguono `LC_TIME`; il token `%~A` capitalizza.

Dichiarare poco è anche la risposta ai rilasci frequenti. Noctalia esce ogni
due settimane circa, da nixpkgs con i rebuild di sistema, e cambia lo schema
della configurazione: migra da solo il proprio `settings.toml`, mentre i file
in `~/.config` non li riscrive mai. Li converte in memoria e mostra un
avviso con file, riga e chiave da correggere. Ogni chiave dichiarata è
quindi una chiave che un aggiornamento può chiedere di sistemare a mano.
Il riferimento upstream è `docs/user/configuration/index.mdx` del repo
`noctalia-dev/noctalia-shell`.

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

Stack desktop, utente, firewall di base e accessi SSH arrivano dalla
baseline; l'host aggiunge solo differenze fisiche o funzionali, i gruppi
extra dell'utente e `system.stateVersion`. Le chiavi autorizzate si leggono
da `identity.home.<host>AuthorizedKeys`, scelte col nome dell'host.

Un profilo Home Manager è la baseline più i moduli che solo quell'host usa.
Il profilo di `game`, per intero:

```nix
imports = [
  ../default.nix
  ../../modules/home/ssh-github-familiare.nix
  ../../modules/home/steam-pipewire-wrapper.nix
  ../../modules/home/game-audio-rec.nix
];

home.stateVersion = "25.11";
```

La baseline ricava dal flake nome utente e host (`username`, `hostname` in
`extraSpecialArgs`), quindi il profilo non li ripete. Fino al 2026-11-11 la
baseline home era solo terminale e ogni profilo importava da sé desktop e
tooling: serviva ai server, che non avevano desktop. Con tre host tutti
desktop dello stesso utente quella distinzione non separava più nulla.

Gli import devono restare espliciti: la presenza nel repository non implica
attivazione, e un modulo importato è attivo senza un secondo interruttore
`enable` da accendere altrove. Questo rende visibile chi usa cosa e sostiene
il principio zero dead code.

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
- ogni pacchetto sta al livello che gli assegna § Pacchetti: un solo livello:
  a system privilegi, integrazione col sistema e base di soccorso, a home le
  app dell'utente con la loro configurazione;
- host e profili dichiarano differenze, non copie della configurazione
  comune: ciò che vale per tutti e tre sta nelle baseline;
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
