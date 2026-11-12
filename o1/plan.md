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
Claude: tutti e quattro dal 2026-11-11. L'host è pronto anche per Codex
come secondo motore, che ogni repo accende nel proprio profilo; in nixos è
di riserva, collaudato con un giro completo fino al push. Il fallback reale
per credito esaurito si verificherà quando accade. Dal 2026-11-12 il pin
Codex è uscito e i tre host girano sulla configurazione ripulita. Il seed
contiene l'identità locale, uguale sui tre host. Il wrapper di Steam resta:
anche il client a 64 bit crasha su game, si aspetta Valve.

## Task

| Ciclo   | Ob. | Task                                                   | Dip. |
| ------- | --- | ------------------------------------------------------ | ---- |
| runtime | 1   | Rimuovere steam-pipewire-wrapper dopo la prova su game | w1   |

Legenda delle attese (`w`) e delle pause (`p`), con risveglio e termine di
riesame (`method/plan.md`, «Risveglio»):

- `w1` — Valve: anche il client a 64 bit (`steamrt64/`, build
  `1794424036`) carica una sua `libaudio.so` e il riproduttore di #13174
  lo fa crashare su `game` (2026-11-12). Si riprova la stessa prova alla
  chiusura della issue o a un client che non carichi più `libaudio`;
  probe: github ValveSoftware/steam-for-linux#13174 closed; by: 2027-02

Dettagli in [o2/tasks.md](../o2/tasks.md).

## Ricorrenze

| Prossima | Cadenza    | Esecutore | Ob. | Ricorrenza                                                                   |
| -------- | ---------- | --------- | --- | ---------------------------------------------------------------------------- |
| config   | quotidiano | scheduler | S   | [Ciclo autonomo](../o3/ciclo/prompt.md)                                      |
| 2027-11  | annuale    | sessione  | 2   | [Prova annuale del seed](../kb/secrets-management.md#prova-annuale-del-seed) |
