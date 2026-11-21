---
sintesi: "Riportare l'identità locale di neve e game e le note del seed all'ultima versione di deck, con le regole private del gate di privacy."
ciclo: runtime
---

# Riallineare identità locale e seed

## Stato

Le impronte confrontate il 2026-11-21 mostrano `default.nix` uguale sui tre
host, `home.nix` e `privacy.json` di `neve` e `game` indietro rispetto a
`deck`, `work.nix` diverso su tutti e tre. Le note `casa/identity/…` del seed
non hanno l'ultima versione di `deck`, che include il progetto `gcloud` e le
regole private aggiunte al gate il 2026-11-21. Un ripristino dal seed oggi
rimetterebbe un assetto superato (`secrets-management`, «Identità separata
dai segreti»).

## Da fare

- Scegliere `deck` come riferimento, salvo differenze volute: confrontare
  prima, solo per chiave e senza stampare valori, cosa distingue le copie di
  `neve` e `game`.
- Copiare da `deck` a `neve` e `game` `home.nix`, `work.nix` e
  `privacy.json`, conservando le copie precedenti; poi verificare con
  `system-drift.sh` e `home-drift.sh` sui due host che sistema e home
  restino allineati.
- Con il custode, in un suo terminale con sessione `bw`: aggiornare le
  quattro note `casa/identity/…` dalla versione di `deck` e rileggerle byte
  per byte contro i file, senza stamparle.
- Aggiornare in `secrets-management` lo stato delle impronte.

## Chiusura

Impronte dei quattro file uguali sui tre host, note del seed conformi,
derive allineate. Un solo commit rimuove questa scheda, la sua voce in
`o2/tasks.md` e la riga in `o1/plan.md`.

## Connessioni

- [secrets-management](../kb/secrets-management.md)
- [secret-inventory](../kb/secret-inventory.md)
- [post-installation](../kb/post-installation.md)
- [plan](../o1/plan.md)
