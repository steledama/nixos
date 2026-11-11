# Perceptions

Indice della collezione `i1/`: lo **stadio i1** (Perceive) del ciclo — la cattura
versionata e valenza-neutra dei segnali. Il significato dello stadio vive
nell'atomo [perceive](../method/perceive.md).

Il Mondo runtime di NixOS è il sistema in esecuzione sui tre host, già
modellato dalla membrana `world -> /run/current-system` (gitignorata): atti e
segnali restano nel sistema reale e nei suoi log. Una cattura entra qui solo
quando serve precisione o durata — un log diagnostico, un errore riprodotto, un
referto `o3/scripts/hw-report.sh` che fonda una decisione. L'assenza si mostra, non
si nasconde: la collezione è vuota finché una cattura reale non la popola.

## Contenuti

- [agent-experience-review-20261025.md](agent-experience-review-20261025.md) —
  evidenze del prototipo exec, dinieghi del 24 e del 26, giro del 25,
  allineamento della production del 26 ed esito del riesame congiunto che
  chiude la revisione; limiti del collaudo.

- [agent-task-orientation-20261024.md](agent-task-orientation-20261024.md) —
  percorso osservato nella revisione del primo task: rilevamento host
  tardivo, ricerca dopo un link già disponibile e output troncato;
  confronto con un nuovo ingresso ancora da fare.
- [ciclo-stadi-saltati-20261107.md](ciclo-stadi-saltati-20261107.md) —
  giri autonomi ridotti a `/manutenzione`: `eval` ed `exec` non aperti dal
  2026-11-05, trailer `Esiti:` con stadi non eseguiti, autovalutazione
  cieca; correzione nel prompt, acquisita da `method` (`1516fa8`).
- [ciclo-primo-giro-stadi-20261108.md](ciclo-primo-giro-stadi-20261108.md) —
  primo giro con gli stadi verificati: sei stadi eseguiti davvero, ma
  finestre troppo corte, visione d'insieme non letta e rischio senza fonte;
  correzione locale nel prompt e in `/manutenzione`, acquisita da `method`
  (`083a8e7`).
- [ciclo-salute-namespace-20261014.md](ciclo-salute-namespace-20261014.md) —
  giro autonomo di `salute` non avviato su `deck`: DNS assente per ore, mount
  Drive in I/O error, namespace dell'unità e chiusura falliti, nessuna
  traccia in `tentativi.jsonl`.
- [cicli-defaults-20261025.md](cicli-defaults-20261025.md) — giri riusciti
  sui percorsi canonici e confronto delle configurazioni prima/dopo i
  default condivisi del modulo cicli.
- [grafie-permessi.jsonl](grafie-permessi.jsonl) — esiti della sonda delle
  grafie dei permessi del giro (`o3/scripts/sonda-grafie.sh`), una tornata
  per versione di Claude Code; letti in `i2/grafie-permessi.md`.
- [manutenzione.json](manutenzione.json) — registro delle versioni/debito
  upstream confrontati dalla skill `/manutenzione` (versioni pacchetti,
  stato dei workaround `Dip.: w<n>` di `o1/plan.md`). **Eccezione al ciclo
  di vita standard di i1**: non è un segnale singolo consumato da un verdetto
  e poi eliminato — è un **registro perpetuo**, una voce corrente per ramo
  sovrascritta a ogni run. Non accumula: lo storico è il `git log -p` del
  file stesso, mai il contenuto del file. Versionato perché fa da **lock
  cross-host** per i rami globali (`ia`, `world`): se già eseguito oggi da
  un host, un altro non lo rilancia, legge l'esito registrato. Segnalato a
  `method` come possibile seconda specie di i1
  (`method/i1/registro-perpetuo-vs-cattura-singola.md`).
