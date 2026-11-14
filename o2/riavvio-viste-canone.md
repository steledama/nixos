---
sintesi: "L'impronta di serve.py comprende o3/view/ del canone e la pubblicazione da HEAD senza builder locale funziona; resta da vedere il riavvio a un cambio del canone."
ciclo: dev
---

# Osservare il riavvio delle viste a un cambio del canone

## Stato

Le viste di `nixos` su `deck` girano con il codice del canone: in
`o3/view/` del repo non c'è più `serve.py` né `build.py`, e il wrapper
`viewCommand` di `o3/modules/home/presentations.nix` ripiega su
`~/method/o3/view/`.

- **Pubblicazione senza builder:** verificata. L'unità
  `presentazione-nixos-pubblicazione` pubblica dal commit pulito con il
  canone esportato da `HEAD`, e il nome della versione porta entrambi i
  commit (`<ts>-<nixos>-m<method>`).
- **Impronta:** `hashServe` scrive due righe in
  `~/.local/state/presentazione/nixos.serve`, l'albero `HEAD:o3/view` del
  repo e quello del canone, e `afterPublish` riavvia il server quando non
  coincidono più. La versione è installata.

## Da osservare

Dal suo avvio il server non ha mai visto cambiare `o3/view/` del canone,
quindi il ramo di riavvio non è stato esercitato. Al primo commit di
`method` che tocca `o3/view/`, dopo una pubblicazione di `nixos`:

1. il journal di `presentazione-nixos-pubblicazione` riporta «codice di
   o3/view cambiato: riavvio presentazione-nixos»;
2. `ActiveEnterTimestamp` di `presentazione-nixos` è successivo al commit;
3. la seconda riga di `nixos.serve` è uguale a
   `git -C ~/method rev-parse HEAD:o3/view`.

Se tutti e tre tornano, il task si chiude. Se il riavvio manca, il difetto
sta in `afterPublish` o nel momento in cui viene letto lo stamp.

## Canale dell'attesa

`w2` è un `arrival:` perché `o3/scripts/probe.sh` non ha un tipo per
questa condizione e il giro non può leggerla: `git -C ~/method` e la
lettura di `~/.local/state/presentazione/nixos.serve` sono fuori dai suoi
permessi. Proposta per la sessione: un tipo nuovo di `probe.sh`, con test,
che confronti la seconda riga dello stamp con `HEAD:o3/view` del canone,
così il giro risveglia l'attesa da solo; in alternativa l'attesa resta al
custode fino al `by:`.

## Connessioni

- [`kb/deck-user-services.md`](../kb/deck-user-services.md) — presentazione
  sulla LAN
- [`o1/plan.md`](../o1/plan.md) — riga e attesa `w2`
