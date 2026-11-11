---
ciclo: runtime
---

# Plan

Lo stadio Plan del ciclo di sviluppo: i task aperti in ordine di esecuzione.
La conoscenza stabile vive in `kb/`; qui restano solo il lavoro futuro e le sue
dipendenze.

## Direzione

`nixos` è a regime sui tre host di casa: il peso prevalente sta nelle
ricorrenze, con il ciclo autonomo quotidiano che tiene aggiornati gli strumenti
e sorveglia il debito upstream. La pubblicazione e il passaggio dei tre host
all'unico repo pubblico sono completati. La tracciabilità con l'identità
locale è corretta e collaudata su game. La pulizia degli archivi è conclusa:
la vecchia storia resta solo nel bundle privato di deck. I cicli autonomi di
deck passano al lanciatore canonico, che registra il credito esaurito di
Claude: salute ed economia dal 2026-11-11, nixos è il prossimo. Dal
2026-11-11 l'host è pronto anche per Codex come secondo motore, che ogni
repo accende nel proprio profilo; gli altri task attendono upstream.

## Task

| Ciclo   | Ob. | Task                                                | Dip. |
| ------- | --- | --------------------------------------------------- | ---- |
| dev     | S   | Portare il ciclo nixos sul lanciatore canonico      |      |
| runtime | 1   | Rimuovere steam-pipewire-wrapper dopo fix upstream  | w3   |
| runtime | 1   | Rimuovere il pin Codex dopo build su ai             | w4   |
| dev     | S   | Accendere Codex come secondo motore del ciclo nixos | w5   |

Legenda delle attese (`w`) e delle pause (`p`), con risveglio e termine di
riesame (`method/plan.md`, «Risveglio»):

- `w3` — upstream: ValveSoftware/steam-for-linux #9289, aperta dal 2025
  senza fix. probe: github ValveSoftware/steam-for-linux#9289 closed;
  by: 2027-01
- `w4` — upstream: codex 0.167.0 su `ai` senza cache al 2026-11-11,
  NixOS/nixpkgs #585124 chiusa il 2026-11-09. arrival: cache binaria o build
  riuscita di Codex sull'input `ai` aggiornato, letta da
  `o3/scripts/home-versions.sh` nella diagnosi `ia` del giro; rimozione di
  input e override in sessione col custode (`kb/development-environment.md`);
  by: 2026-12
- `w5` — upstream: verifiche aperte del contratto dei motori in method
  (il giro completo con Codex è riuscito il 2026-11-11, method `6d3938f`;
  restano la forma reale di un errore di quota di Codex, il `git push` in
  rete dalla sandbox di Codex, un fallback fra motori veri). probe:
  sezione «Verified and still open» di method `o3/ciclo/fallback.md`;
  by: 2027-01

Dettagli in [o2/tasks.md](../o2/tasks.md).

## Ricorrenze

| Prossima | Cadenza    | Esecutore | Ob. | Ricorrenza                                                                   |
| -------- | ---------- | --------- | --- | ---------------------------------------------------------------------------- |
| config   | quotidiano | scheduler | S   | [Ciclo autonomo](../o3/ciclo/prompt.md)                                      |
| 2027-11  | annuale    | sessione  | 2   | [Prova annuale del seed](../kb/secrets-management.md#prova-annuale-del-seed) |
