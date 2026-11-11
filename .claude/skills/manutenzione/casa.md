# Ramo casa

- **`casa`** — host: `deck`/`neve`/`game`. Input: `nixpkgs`, condiviso dai
  tre. Lock: diagnosi di gruppo cross-host, cadenza in `casa.cadenza_giorni`.
  Azione: diagnosi e bump overlay autonomi; attivazione di sistema sempre
  gated (`sudo nixos-rebuild switch`). Stato: `casa.nixpkgs_rev`,
  `casa.host_controllato`, `casa.applicato_su`. Porta anche la voce di
  gruppo **`casa.gogcli`** (overlay permanente, pin unico in `flake.nix`, solo
  `deck` dal 2026-11-07): data/ora proprie, cadenza **ereditata** da
  `casa.cadenza_giorni`, lock cross-host come `ia`; bump + `home-manager
switch` autonomi (home-level), stato `casa.gogcli.applicato_su`.

Esegui `o3/scripts/system-versions.sh` sull’host rappresentante.
Per la sola voce gogcli usa l’upstream `openclaw/gogcli`: lo script
system-versions non la include. I controlli specifici sono in sistema.

Leggi [sistema](sistema.md) per granularità, controlli per host e valutazione.
Restituisci diagnosi comune, voci host-specifiche trattate e attivazioni
pendenti alla [chiusura](chiusura.md). Il rebuild resta al custode.
