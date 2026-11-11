---
ciclo: dev
---

# Codex nel recinto dell'host

Il limite osservato nel tentativo `928bb91a` del 2026-11-11 alle 18:23
era l'accesso alla cache Nix e al bus utente dalla sandbox propria di Codex
(`o2/ciclo-fallback-codex.md`). Il contratto canonico riletto in
`method/../o3/ciclo/fallback.md` dichiara ora `--recinto-host`: in presenza
del recinto dell'host l'esecutore usa quello, senza aggiungere la sandbox
`workspace-write`. Il profilo locale cita il recepimento `0eeb2db`.

Nel giro manuale del 2026-11-11, partenza alle 20:14:17 CET, le misure
locali sono: `system-drift.sh` e `home-drift.sh` allineati, accesso al bus
utente riuscito, nessuna unità fallita di sistema o utente. Questi riscontri
smentiscono il blocco generalizzato su cache e bus nel recinto corrente;
non dimostrano uno switch eseguito da Codex né il fallback fra motori veri.
La verifica flake del giro resta un controllo distinto, riportato nel commit.

La quota reale e il fallback restano aperti nel contratto canonico. Il push
Codex in rete è già documentato lì per method (`3b618dc`, fonte del
2026-11-11). L'attesa locale va riconosciuta come `arrival:`, non come una
`probe:` su testo libero che `probe.sh` non sa interrogare.
