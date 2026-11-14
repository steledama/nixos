---
ciclo: runtime
---

# Plan

Lo stadio Plan del ciclo di sviluppo: i task aperti in ordine di esecuzione.
La conoscenza stabile vive in `kb/`; qui restano solo il lavoro futuro e le sue
dipendenze.

## Direzione

`nixos` è a regime sui tre host di casa: il peso prevalente sta nelle
ricorrenze, con il ciclo autonomo quotidiano che tiene aggiornati gli
strumenti e sorveglia il debito upstream. Nessun fronte di sviluppo è
aperto: i due task aspettano un fatto esterno, Valve per togliere il
wrapper di Steam su `game` e un cambio di `o3/view/` nel canone per vedere
il riavvio del server delle viste.

## Task

| Ciclo   | Ob. | Task                                                    | Dip. |
| ------- | --- | ------------------------------------------------------- | ---- |
| runtime | 1   | Rimuovere steam-pipewire-wrapper dopo la prova su game  | w1   |
| dev     | S   | Osservare il riavvio delle viste a un cambio del canone | w2   |

Legenda delle attese (`w`) e delle pause (`p`), con risveglio e termine di
riesame (`method/plan.md`, «Risveglio»):

- `w1` — Valve: anche il client a 64 bit (`steamrt64/`, build
  `1794424036`) carica una sua `libaudio.so` e il riproduttore di #13174
  lo fa crashare su `game` (2026-11-12). Si riprova la stessa prova alla
  chiusura della issue o a un client che non carichi più `libaudio`;
  probe: github ValveSoftware/steam-for-linux#13174 closed; by: 2027-02
- `w2` — method: dal suo avvio `presentazione-nixos` non ha visto cambiare
  `o3/view/` del canone, quindi il riavvio dopo la pubblicazione non è
  ancora stato osservato. arrival: un commit di `method` che tocca
  `o3/view/`, riconosciuto in sessione col custode (il giro non legge né
  `~/method` né lo stamp in `~/.local/state/`); by: 2027-01

Dettagli in [o2/tasks.md](../o2/tasks.md).

## Ricorrenze

| Prossima | Cadenza    | Esecutore | Ob. | Ricorrenza                                                                   |
| -------- | ---------- | --------- | --- | ---------------------------------------------------------------------------- |
| config   | quotidiano | scheduler | S   | [Ciclo autonomo](../o3/ciclo/prompt.md)                                      |
| 2027-11  | annuale    | sessione  | 2   | [Prova annuale del seed](../kb/secrets-management.md#prova-annuale-del-seed) |
