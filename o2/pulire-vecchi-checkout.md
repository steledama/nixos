---
sintesi: "Rimuovere nelle sessioni locali di game e neve i vecchi checkout privati e i worktree, dopo verifica che non contengano più lavoro unico o file da preservare."
ciclo: runtime
---

# Pulire i vecchi checkout di game e neve

## Materiale già preservato

Su deck un solo bundle privato conserva la vecchia storia e tutti i commit
raggiungibili da ref e reflog letti sui tre host il 2026-11-11. Sono 2316
commit, incluso `6fb3d265` di game; clone mirror e `git fsck --full`
verificati. Posizione e uso in `o3/identity/README.md`. I doppioni di deck
sono già eliminati. L'archivio GitHub resta privato e archiviato.

## Atti nelle sessioni locali

Per ogni host, lavorare dal clone pubblico `~/nixos`, mai da una directory
da rimuovere. Verificare che non ci siano sessioni attive nei vecchi
worktree. Inventariare `~/nixos-archivio-privato` e tutti i suoi worktree,
anche quelli esterni sotto `~/.herdr/worktrees/`.

Confrontare ref e reflog attuali col bundle consolidato, e controllare
stash, modifiche, file nuovi e ignorati: il bundle non copre file mai
committati né cambiamenti successivi al consolidamento. Se emerge
materiale unico, conservarlo privatamente prima della rimozione, senza
metterlo nel repo pubblico o stamparne i valori. Non aggiornare l'archivio
GitHub statico per fare pulizia.

Quando è tutto preservato, rimuovere i worktree tramite Git, senza forzare
worktree sporchi o bloccati; poi rimuovere il vecchio checkout. Non toccare
il clone pubblico, `~/.config/nixos/`, directory globali degli agenti o
worktree appartenenti ad altri repository. Non serve sudo o rebuild.

## Chiusura

I due host confermano vecchi checkout e relativi worktree rimossi, nessun
lavoro unico perso, clone pubblico pulito e identità locali ancora presenti.
Il coordinamento di task e commit resta alla sessione su deck.
