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
- Su tutti gli host, l'input `nixpkgs-codex` tiene Codex a 0.166.0 mentre
  `ai` avanza per gli altri agenti (`bac7d86`, 2026-11-10): codex 0.167.0
  non compila su `ai` (aws-lc-sys). NixOS/nixpkgs #585124 è chiusa dal
  2026-11-09, ma al 2026-11-11 la 0.167.0 resta senza cache; la chiusura
  da sola non basta (`.claude/skills/manutenzione/ia.md`). Esce quando
  Codex di `ai` ha cache o una build riuscita (`w4` in `o1/plan.md`).

Verdetto corrente: la deriva desktop è contenuta. Steam resta debito noto
con una condizione upstream e un task (`w3` in `o1/plan.md`, dettagli in
`o2/`); #9289 ancora aperta al 2026-10-27. L'overlay NAPS2 è uscito il
2026-11-01 col bump di `nixpkgs` a `1c89083`, che porta la 8.6.0 col
try/catch upstream (#784): la patch non si applicava più e la build su
`neve` lo ha rivelato. Quando il debito è di packaging e il servizio è
rimpiazzabile, cambiare servizio può costare meno che aspettare upstream.

## Chiusura

La ricorrenza quotidiana di `/manutenzione world` sorveglia la condizione
upstream. Ogni workaround esce quando la condizione è superata **e** la
rimozione è verificata sul relativo host (runtime, o build attiva per gli
overlay di packaging). Il filo si chiude con l'uscita del wrapper Steam e del pin Codex.
