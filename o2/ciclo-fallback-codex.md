---
sintesi: "Rendere Codex una riserva completa del ciclo nixos: oggi la sua sandbox scrive solo nel checkout e il giro non può verificare il flake né fare lo switch."
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

## Dipendenza

`w5`: in method, una via dichiarata nel profilo del repo per aprire alla
sandbox di Codex altre radici scrivibili e i socket necessari (cache Nix,
demone Nix, bus utente), o per un giro Codex che scelga la sandbox del
recinto di systemd al posto della propria. Richiesta inoltrata a method il
2026-11-11.

## Atto quando arriva

Dichiarare nel profilo di nixos ciò che serve, poi un giro a mano con
Codex primo, col custode, fino a commit e push riusciti; infine di nuovo
`["claude", "codex"]`.
