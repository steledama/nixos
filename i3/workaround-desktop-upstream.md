---
ciclo: runtime
obiettivo: 1
---

# Workaround e overlay dipendenti da upstream

Un workaround resta intenzionalmente locale e temporaneo, contro
l'obiettivo di un sistema snello. Il blocco di trasmissione dell'igc su
`game` non è più qui: è un difetto hardware accettato dal custode il
2026-10-26, documentato in `kb/hardware-inventory.md` senza mitigazioni
nella configurazione.

- Su `game`, il wrapper Home Manager riavvia PipeWire prima di Steam per
  evitare il crash nella `libaudio.so` bundlata; va rimosso dopo un fix
  upstream verificato.

Verdetto corrente: la deriva desktop è contenuta. Il pin Codex è uscito il
2026-11-12: la 0.167.0 dell'input `ai` è arrivata in cache, la rimozione è
verificata con lo switch su `deck`; `game` e `neve` la ricevono col
prossimo allineamento. Steam resta debito noto
con una condizione upstream e un task (`w3` in `o1/plan.md`, dettagli in
`o2/`); #9289 ancora aperta al 2026-11-12 (`gh issue view`, ultimo
aggiornamento 2025-02-19). L'overlay NAPS2 è uscito il
2026-11-01 col bump di `nixpkgs` a `1c89083`, che porta la 8.6.0 col
try/catch upstream (#784): la patch non si applicava più e la build su
`neve` lo ha rivelato. Quando il debito è di packaging e il servizio è
rimpiazzabile, cambiare servizio può costare meno che aspettare upstream.

## Chiusura

La ricorrenza quotidiana di `/manutenzione world` sorveglia la condizione
upstream. Ogni workaround esce quando la condizione è superata **e** la
rimozione è verificata sul relativo host (runtime, o build attiva per gli
overlay di packaging). Il filo si chiude con l'uscita del wrapper Steam.
