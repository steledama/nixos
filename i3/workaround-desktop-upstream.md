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
  evitare il crash nella `libaudio.so` bundlata; va rimosso quando una
  prova su `game` lo dimostra inutile.

Verdetto corrente: la deriva desktop è contenuta. Il pin Codex è uscito
(`43cde0d`): Codex segue di nuovo l'input `ai`. Steam resta debito noto e
ora dipende solo da Valve: la prova su `game` del 2026-11-12 ha mostrato che
anche il client a 64 bit (`steamrt64/`) carica una sua `libaudio.so` e il
riproduttore di #13174 lo fa crashare (`w1` in `o1/plan.md`, dettagli in
`o2/`). PipeWire 1.6.11 non tocca il crash. L'issue viva è #13174, aperta
al 2026-11-13 (`probe.sh`); #9289, ferma dal 2025-02-19, era la
sorveglianza sbagliata. L'overlay NAPS2 è uscito il
2026-11-01 col bump di `nixpkgs` a `1c89083`, che porta la 8.6.0 col
try/catch upstream (#784): la patch non si applicava più e la build su
`neve` lo ha rivelato. Quando il debito è di packaging e il servizio è
rimpiazzabile, cambiare servizio può costare meno che aspettare upstream.

## Chiusura

La ricorrenza quotidiana di `/manutenzione world` sorveglia le condizioni
upstream delle attese `w`; per Steam si riprova su `game` alla chiusura di
#13174 o a un client che non carichi più `libaudio`. Ogni workaround esce quando la condizione è superata **e** la
rimozione è verificata sul relativo host (runtime, o build attiva per gli
overlay di packaging). Il filo si chiude con l'uscita del wrapper Steam.
