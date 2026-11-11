---
sintesi: "Configurare --codex-adapter sui cicli di deck quando esiste un esecutore Codex con limiti equivalenti a quelli di Claude, secondo il contratto di method."
ciclo: dev
---

# Abilitare il fallback Codex dei cicli di deck

## Stato

Il lanciatore canonico (method `fce8afe`, `accb3b5`) riconosce il rifiuto
per quota di Claude e ammette **un** tentativo Codex solo tramite
`--codex-adapter`, un esecutore dell'host che imponga la stessa politica:
comandi ammessi, percorsi protetti, hook di concorrenza al commit, tetto in
USD, recinto e arresto. Il contratto è in `method/../o3/ciclo/fallback.md`.
Dal 2026-11-11 (method `4341ff0`) il tetto in USD è preferibile ma non
bloccante, per decisione del custode (account a tariffa flat): l'host lo
sceglie con `--codex-senza-tetto-usd` e la chiusura dichiara
`budget_usd_imposto: false`. L'esecutore Codex starà nel canone, in Python
accanto al lanciatore, per valere anche su Windows (danea-auto); agli host
restano recinto, arresto e percorso del binario Codex.

## Dipendenza

`w5`: esecutore Codex canonico in method (`o2/lanciatore-ciclo-nel-metodo.md`
di method), validato con agenti finti sui casi del contratto: quota
rifiutata, avviso consentito, autenticazione, eseguibile mancante, tetto di
tempo, atti parziali, percorsi e comandi negati, concorrenza al commit.

## Atto quando arriva

Per ogni ciclo con `lanciatore = true`: passare nello script `lancia` di
`o3/modules/home/cicli.nix` l'esecutore canonico e il binario Codex, con
`--codex-senza-tetto-usd`, dentro lo stesso `--recinto`; sonda, poi un giro a mano con quota rifiutata simulata. Il
timer resta com'è: il fallback non è un'attivazione nuova.
