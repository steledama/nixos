---
sintesi: "Portare il ciclo autonomo di nixos su deck dal percorso legacy al lanciatore canonico di method, come salute ed economia dal 2026-11-11."
ciclo: dev
---

# Portare il ciclo nixos sul lanciatore canonico

## Perché

Da method `fce8afe` (`o3/ciclo/fallback.md`) la chiusura del lanciatore
canonico registra motore, tentativi e osservazione del provider, e quindi
anche il rifiuto per quota esaurita. Il percorso legacy `ciclo-avvio` /
`ciclo-chiusura` non riceve questa osservazione. Su `deck` usano il
lanciatore `method`, dal 2026-11-08, e `salute` ed `economia`, dal
2026-11-11; `nixos` resta legacy.

## Cosa cambia per nixos

- `homeWritable = true`: il giro esegue `home-manager switch` dentro
  `/manutenzione`, e la home scrivibile resta l'unico recinto oltre ai
  permessi dell'harness. Verificare che il recinto del lanciatore la
  conservi (sonda `ciclo-nixos-sonda`) e che il `--recinto-ferma`
  verificato regga un agente che ha rilanciato servizi utente.
- Percorsi protetti del lanciatore (`CLAUDE.md`, `AGENTS.md`,
  `autonomy.md`, `.claude/*`, `.codex/*`, `o3/ciclo/*`): un commit del giro
  che li tocca ferma i giri successivi (23 e `fermo`). Prima di attivare,
  controllare nella storia se i giri autonomi di nixos li hanno toccati.
- Tetti annidati come gli altri: lanciatore 45, agente 47, unità esterna 50
  minuti. Il giro delle 04:30 finisce comunque prima delle 09:00.

## Stato

Registro aggiornato il 2026-11-11: `lanciatore = true`, nessun valore di
durata o budget nel registro, recinto con home scrivibile e percorsi
protetti del lanciatore. Manca il primo giro riuscito.

## Criterio di chiusura

`lanciatore = true` per `nixos` in `o3/cicli.nix`, sonda superata e un giro
riuscito dal timer, con chiusura in `i1/giri/tentativi.jsonl` che porta
`engine_attempts`.
