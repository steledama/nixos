---
sintesi: "Accendere Codex come secondo motore del ciclo autonomo di nixos, quando il ciclo passa al lanciatore canonico, con un primo giro a mano col custode."
ciclo: dev
---

# Accendere Codex come secondo motore del ciclo nixos

## Stato

Dal 2026-11-11 (method `201a6eb`, prescrizione `motori-del-ciclo`) il motore
lo sceglie ciascun repo con `motori` nel proprio `o3/ciclo/lanciatore.toml`;
Codex passa dall'esecutore canonico di method. La parte dell'host su `deck`
è fatta per tutti i cicli col lanciatore (`kb/cicli.md`, «Quota e
fallback»): `--codex` nello script, `~/.codex` scrivibile nel recinto, e
nessuna politica degli altri repo nel registro. Accendere Codex per
`method`, `salute` ed `economia` spetta alle loro sessioni, nei loro
profili.

Qui resta `nixos` come adottante: il suo ciclo è ancora legacy e non
riceve né l'osservazione della quota né il secondo motore.

## Dipendenze

- `o2/ciclo-nixos-lanciatore.md`: il ciclo nixos passa al lanciatore.
- `w5`: le verifiche aperte del contratto in method. Il giro completo con
  Codex attraverso il lanciatore è riuscito il 2026-11-11 (method
  `6d3938f`); restano la forma reale di un errore di quota di Codex, il
  `git push` in rete dalla sandbox di Codex e un fallback fra motori veri.

## Atto quando arrivano

1. Creare `o3/ciclo/lanciatore.toml` con i soli valori diversi dai default,
   `motori = ["claude", "codex"]`, in sessione col custode: il profilo è
   protetto e il giro non lo cambia.
2. Verificare che `o3/ciclo/permessi.json` regga per Codex: in Codex gli
   strumenti senza regola di nome (`Skill(…)`) non esistono, e i comandi
   con sostituzioni `$(…)` l'esecutore li rifiuta.
3. Primo giro a mano col custode, poi il timer resta com'è.
