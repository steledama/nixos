---
ciclo: runtime
---

# Giro di salute non avviato il 2026-10-14

Cattura valenza-neutra del tentativo del timer `ciclo-salute` su `deck` del
2026-10-14, fallito prima dell'avvio e assente da
`~/.local/state/ciclo/salute/tentativi.jsonl`. Il journal utente ruota; qui
restano le righe che fondano la lettura.

## Sequenza misurata

Fonte: `journalctl --user -u ciclo-salute` e
`-u rclone-mount-gdrive-personale`, letti su `deck` il 2026-10-15.

1. Dalle 09:21:32 alle 14:46:58 rclone registra 1310 errori
   `lookup oauth2.googleapis.com: no such host`: `deck` non risolve i nomi
   per circa 5 ore e mezza. La causa non è osservata nei log; il custode
   riferisce (2026-10-15) che dal 2026-10-12 al 2026-10-14 `deck` era in un
   albergo, su un wifi scadente, e veniva spento e riacceso per gli
   spostamenti: fuori dalla sua rete e dalla sua routine.
2. 12:00:23, il timer avvia `ciclo-salute.service`.
3. 12:00:38, rclone risponde `IO error: couldn't list directory` e systemd
   non riesce a preparare il namespace:
   `Failed to set up mount namespacing: /home/stele/Drive/gdrive-personale/salute: Input/output error`,
   `ciclo-avvio` esce con `status=226/NAMESPACE`.
4. 12:00:48, anche `ExecStopPost` (`ciclo-chiusura`) fallisce nello stesso
   punto (`226/NAMESPACE`); l'unità termina con `result 'exit-code'`.
5. In `tentativi.jsonl` non c'è nessuna riga del 2026-10-14: l'ultima è la
   chiusura `riuscito` del 2026-10-13 alle 12:02:49. Il 2026-10-12 manca
   anch'esso, ma `deck` si è avviato alle 14:29, dopo l'orario (uno degli
   spegnimenti per il viaggio).
6. Al 2026-10-15 alle 08:00 il mount risponde, `ciclo-salute.timer` aspetta
   le 12:00, nessuna unità utente risulta fallita.

## Fatti rilevanti per il meccanismo

- `ReadWritePaths` su un mount FUSE fa dipendere l'avvio dell'unità dalla
  raggiungibilità del remoto: se il mount risponde I/O error, l'unità non
  parte.
- `ExecStopPost` gira nello stesso namespace, quindi non registra la
  chiusura: il tentativo resta solo nel journal, senza `partenza` né
  `chiusura`, e lo stato del ciclo non distingue un avvio fallito da una
  partenza mancata.
