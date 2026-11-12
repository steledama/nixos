# Perceptions

Indice della collezione `i1/`: lo **stadio i1** (Perceive) del ciclo — la cattura
versionata e valenza-neutra dei segnali. Il significato dello stadio vive
nell'atomo [perceive](../method/perceive.md).

Il Mondo runtime di NixOS è il sistema in esecuzione sui tre host, già
modellato dalla membrana `world -> /run/current-system` (gitignorata): atti e
segnali restano nel sistema reale e nei suoi log. Una cattura entra qui solo
quando serve precisione o durata — un log diagnostico, un errore riprodotto, un
referto `o3/scripts/hw-report.sh` che fonda una decisione. L'assenza si mostra, non
si nasconde: senza catture reali la collezione resta al solo indice.

## Contenuti

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
  (`i1/registro-perpetuo-vs-cattura-singola.md` di `method`).
