---
ciclo: runtime
---

# Plan

Lo stadio Plan del ciclo di sviluppo: i task aperti in ordine di esecuzione.
La conoscenza stabile vive in `kb/`; qui restano solo il lavoro futuro e le sue
dipendenze.

## Direzione

La cura ordinaria dei tre host resta centrata sulle ricorrenze. Documento e
valutazione di dominio dell'OCR restano custoditi da economia; l'infrastruttura
attiva è descritta in `kb/game-local-llm.md`.
Le altre attese riguardano Valve e la semplificazione upstream del packaging
Paddle CPU.

## Task

| Ciclo   | Ob. | Task                                                        | Dip. |
| ------- | --- | ----------------------------------------------------------- | ---- |
| runtime | 2   | Riallineare identità locale e seed                          |      |
| runtime | 1   | Rimuovere steam-pipewire-wrapper dopo la prova su game      | w1   |
| runtime | 1   | Semplificare il packaging OCR CPU dopo il supporto upstream | w3   |

Legenda delle attese (`w`) e delle pause (`p`), con risveglio e termine di
riesame (`method/plan.md`, «Risveglio»):

- `w1` — Valve: anche il client a 64 bit (`steamrt64/`, build
  `1794424036`) carica una sua `libaudio.so` e il riproduttore di #13174
  lo fa crashare su `game` (2026-11-12). Si riprova la stessa prova alla
  chiusura della issue o a un client che non carichi più `libaudio`;
  probe: github ValveSoftware/steam-for-linux#13174 closed; by: 2027-02
- `w3` — packaging Paddle CPU: riesaminare gli override e la patch degli
  import opzionali a un cambio di nixpkgs/PaddleX. arrival: nuovo pin letto
  in sessione con ricette CPU minime e import senza i downloader esclusi;
  by: 2027-02

Dettagli in [o2/tasks.md](../o2/tasks.md).

## Ricorrenze

| Prossima   | Cadenza    | Esecutore | Ob. | Ricorrenza                                                                                  |
| ---------- | ---------- | --------- | --- | ------------------------------------------------------------------------------------------- |
| 2026-11-21 | quotidiano | sessione  | 3   | [Manutenzione](../.claude/skills/manutenzione/SKILL.md) (cadenze in `i1/manutenzione.json`) |
| 2027-11    | annuale    | sessione  | 2   | [Prova annuale del seed](../kb/secrets-management.md#prova-annuale-del-seed)                |
