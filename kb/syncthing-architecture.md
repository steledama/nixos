---
stato: maturo
---

# Syncthing Architecture

Documentazione dell'architettura di sincronizzazione Syncthing dei tre host
di casa.

## Mesh (game + deck + neve)

I tre host casa sincronizzano `~/sync/` direttamente tra loro in mesh LAN,
senza hub.

I Device ID e gli indirizzi LAN dei client vivono una sola volta in
`~/.config/nixos/identity/home.nix`; il modulo deriva da quel registro peer e indirizzi.

## Syncthing e rclone

game, deck e neve usano due meccanismi indipendenti:

- **Syncthing**: sincronizza `~/sync/` tra i tre host (mesh LAN)
- **Rclone mount**: ogni host monta `~/Drive/` direttamente da Google Drive via FUSE (no copia locale completa)

```
deck (192.168.0.10)          game (192.168.0.9)           neve (192.168.0.8)
~/sync/                   <->    ~/sync/               <->    ~/sync/
├── custode/                     ├── custode/                 ├── custode/
│   ├── documenti/               │   ├── documenti/           │   ├── documenti/
│   └── Drive -> ../../Drive/    │   └── Drive -> ...         │   └── Drive -> ...
└── familiare/                     └── familiare/                 └── familiare/

~/Drive/                         ~/Drive/                     ~/Drive/
├── gdrive-personale/ (mount)      ├── gdrive-personale/ (mount)  ├── gdrive-personale/ (mount)
└── gdrive-familiare/ (mount)      └── gdrive-familiare/ (mount)  └── gdrive-familiare/ (mount)
```

**Scelta no-hub per rclone**: ogni host monta direttamente Google Drive, eliminando sia la sync a cascata (host -> hub -> gdrive) sia i falsi conflitti/cancellazioni causati da rename locali con `bisync`.

**Symlink relativi**: `~/sync/custode/Drive -> ../../Drive/gdrive-personale` — portabili su tutte le macchine (stesso percorso relativo).

## Moduli

- `o3/modules/home/syncthing-home-mesh.nix` — mesh dei client casa (deck, game, neve)
- `o3/modules/home/rclone.nix` — mount FUSE dichiarativi e template manuali rclone
- `o3/hosts/default.nix` — `users.users.stele.linger` mantiene Syncthing attivo senza login

## Porte (firewall)

- **22000**: protocollo sync Syncthing
- **8384**: Web GUI Syncthing (http://localhost:8384)

## Gestione Servizio

Syncthing è un user service (home-manager), non richiede sudo.

```bash
systemctl --user status syncthing
systemctl --user start syncthing
systemctl --user stop syncthing
systemctl --user restart syncthing
```

Log:

```bash
journalctl --user -u syncthing -f
journalctl --user -u syncthing --since "2 hours ago"
journalctl --user -u syncthing --since today
```

## Troubleshooting

### Device disconnesso

```bash
systemctl --user status syncthing
journalctl --user -u syncthing -f
# oppure apri http://localhost:8384
```

Cause comuni: firewall blocca porta 22000, Device ID non corrisponde, rete non disponibile.

1. Verifica il listener locale: `ss -tln | grep 22000`; questo non verifica il firewall.
2. Confronta Device ID e indirizzi nei due peer e leggi i journal.
3. Verifica routing e regole firewall sui due host; il ping prova soltanto ICMP,
   non la raggiungibilità della porta di sincronizzazione.

### File non sincronizzati

1. Controlla Web UI per item "Out of Sync"
2. Verifica che la cartella non sia in pausa
3. Controlla permessi sui file
4. Controlla `.stignore` per pattern che bloccano i file
5. `systemctl --user restart syncthing`

Connessioni:

- [secrets-management](secrets-management.md)
- [rclone-gdrive](rclone-gdrive.md)
- [rclone-operations](rclone-operations.md)
- [client-desktop-architecture](client-desktop-architecture.md)
