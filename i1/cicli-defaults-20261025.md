---
ciclo: runtime
---

# Verifica dei default del modulo cicli

## Precondizione osservata

Letti direttamente su deck i file `<repo>/i1/giri/tentativi.jsonl` il
2026-10-25. Per ogni repository di deck è presente una chiusura riuscita,
exit status 0, con trascritto nel nuovo percorso `i1/giri/giri/`:

- nixos: `e4852771891d415689f267b1f20dd016`, 04:43:25 +01:00,
  commit `067ecc2`;
- salute: `877cb03fc9fc43b0900cb9ef4f10e6f9`, 09:04:12 +01:00,
  commit `de4479c`;
- economia: `35b0e00569cb4537944827c28041717d`, 14:01:57 +01:00,
  commit `18194f2`;
- method: `2644afe897aa4880a3f40fb1ffdcc17a`, 15:03:17 +01:00,
  commit `efac58c`.

Questi giri precedono la semplificazione: provano l'uso dei percorsi,
non il comportamento del modulo modificato.

## Confronto delle configurazioni

Baseline: `72b969d`, prima di cambiare i moduli. Build senza attivazione di
`stele@deck`, `sviluppo@svezia` e `sviluppo@norvegia`; confronto con le
stesse home del candidato, a lock invariato. Si confrontano i file delle
unità ciclo, sonde, timer e presentazioni, e i JSON richiamati dagli
ExecStart dei cicli. Il registro `decisioni.json` perde deliberatamente
le ripetizioni: contiene le decisioni esplicite, non i default risolti.

Esito, osservato il 2026-10-25 in sessione su deck:

- `home-files` delle tre home, baseline contro candidato (`diff -rq`, che
  segue i symlink verso le unità e i JSON nello store): l'unico file
  diverso è `.local/state/ciclo/decisioni.json`, su tutti e tre gli host.
  Unità `ciclo-*`, sonde, timer e `presentazione-*` identiche, quindi
  identici anche `ExecStart`, `ReadOnlyPaths` e JSON richiamati.
- `decisioni.json` perde `settings`, `prompt`, `giri`, `vistaUnita` e le
  voci `<repo>/o3/ciclo` di `readOnlyPaths`. I lettori, `o3/view/ciclo.py`
  di nixos, method, salute ed economia, usano solo `state`, `cadence`,
  `time`, `maxRuntime` e `note`: nessun campo letto cambia.
- Switch home su deck riuscito, nessuna unità utente fallita. L'unità
  `presentazione-nixos` passa `--ciclo-state ~/nixos/i1/giri` e
  `--ciclo-unita ~/.local/state/ciclo/nixos`; `/_ciclo/ultimi.json` delle
  viste 8001–8004 risponde `stato: ok` con l'ultimo giro elencato sopra.

Limite: il confronto prova l'equivalenza della configurazione, non un
giro eseguito dal modulo nuovo; il primo sarà quello di `nixos` alle
04:30 del 26. Attivazione su norvegia e svezia nel resoconto del commit.

Connessioni:

- [cicli](../kb/cicli.md)
