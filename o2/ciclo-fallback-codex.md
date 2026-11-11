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
Codex CLI 0.166.0 non espone un tetto in USD e i suoi hook non sono validati
come traduzione della politica di Claude: nessun adottante ha ancora un
esecutore, nemmeno `example-org/nixos-ufficio` («Codex escluso»).

## Dipendenza

`w5`: esecutore Codex equivalente, validato con agenti finti sui casi del
contratto (quota rifiutata, avviso consentito, autenticazione, eseguibile
mancante, tetto di tempo, atti parziali, percorsi e comandi negati,
concorrenza al commit, tetto monetario). Conviene una sola implementazione
condivisa, in method o con la sessione di lavoro, non una per repo.

## Atto quando arriva

Per ogni ciclo con `lanciatore = true`: passare `--codex-adapter` nello
script `lancia` di `o3/modules/home/cicli.nix`, dentro lo stesso
`--recinto`; sonda, poi un giro a mano con quota rifiutata simulata. Il
timer resta com'è: il fallback non è un'attivazione nuova.
