---
sintesi: "Completare il collaudo Codex del ciclo nixos: accesso a Nix e bus riscontrato, switch e fallback fra motori veri ancora da verificare."
ciclo: dev
---

# Rendere utile Codex come riserva del ciclo nixos

## Stato

Dal 2026-11-11 il ciclo nixos gira col lanciatore canonico e il profilo
`o3/ciclo/lanciatore.toml` ha `motori = ["claude", "codex"]`. La parte
dell'host è pronta per tutti i cicli (`kb/cicli.md`, «Quota e fallback»).

Il giro a mano delle 18:23 con Codex primo (`i1/giri/giri/928bb91a….codex.jsonl`)
ha letto tutto, è passato per `/eval` ed `/exec` senza dinieghi, e si è
fermato senza commit: `o3/tools/check.sh --flake` fallisce perché Nix non
apre `~/.cache/nix/fetcher-cache-v4.sqlite`, e `systemctl --user` non
raggiunge il bus. L'esecutore canonico lancia Codex con `--sandbox
workspace-write` e come `writable_roots` solo la cartella git: il recinto di
systemd ha la home scrivibile, la sandbox di Codex no. Uno switch home di
`/manutenzione` fallirebbe allo stesso modo. Il lanciatore ha chiuso con
`esito: riuscito` e `commit_giro: []`.

Il contratto canonico aggiornato usa il recinto dell'host senza aggiungere
la sandbox propria di Codex (`--recinto-host`, recepimento citato nel profilo
locale `0eeb2db`). Nel giro delle 20:14:17 accesso a Nix e bus riusciti,
derive allineate e nessuna unità fallita: il limite delle 18:23 è superato
per questi controlli, non ancora per uno switch. Lettura in
`i2/codex-recinto-host.md`, verdetto in `i3/allineamento-metodo.md`.

## Dipendenza

`w5`: forma reale di un errore di quota Codex e fallback fra motori veri,
ancora aperti nel contratto canonico riletto il 2026-11-11. Il push in rete
da Codex è già verificato in method (`3b618dc` nella stessa fonte).

## Atto quando arriva

In sessione col custode completare il giro a mano con Codex primo fino a
commit e push; verificare uno switch home dovuto su deck con
`o3/scripts/con-identita.sh home-manager switch --flake .#stele@deck`,
seguito da `systemctl --user --failed` senza unità fallite. Nessun atto
sugli altri host né modifica system-level. Verificare il fallback reale
secondo il contratto canonico, senza ripetere atti parziali; infine riportare
il profilo a `["claude", "codex"]` in sessione autorizzata. Il giro autonomo
aggiorna la specifica ma non esegue questi passi di task.
