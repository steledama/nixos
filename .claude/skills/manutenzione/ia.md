# Ramo ia

- **`ia`** — host: tutti. Input: `ai`. Lock: globale cross-host, cadenza in
  `ia.cadenza_giorni`. Azione: update + `home-manager switch` autonomi.
  Stato: `ia.rev_ai`, `ia.applicato_su`; semantica di allineamento nel [contesto](contesto.md).

Esegui `o3/scripts/home-versions.sh` per le sole voci selezionate e leggi
[valutazione](valutazione.md), con la regola specifica sui changelog sotto.

**Ramo `ia`: per regola, nessun changelog su patch e minor.** I bump patch
e minor dello stack di `pkgs-ai` (claude-code, codex, pi, Herdr) non si
leggono: il rischio è basso, l'attivazione è home-level e il rollback è la
generazione home precedente. Non è un'incertezza da dichiarare, è la
procedura: nel resoconto basta «patch/minor `ia`, changelog non letto per
regola». Si leggono le note solo per un major, o se lo switch o la
valutazione segnalano un problema concreto. Quando invece leggi le
note, valuta: breaking changes tra le due versioni, migrazioni di config
richieste (rinomina opzioni, formati dati, variabili d'ambiente), CVE o fix di
sicurezza. Usa il giudizio, non inventare un parser per i changelog.

**Ramo `ia`: versioni agenti nel resoconto.** Ogni run del ramo, in
sessione o nel giro, riporta la voce «Versioni agenti» con una riga per
claude-code, codex, pi e Herdr: `da → a` se cambia, la versione e
«invariato» altrimenti (fonte: `o3/scripts/home-versions.sh`). La voce c'è
anche quando nulla cambia: dice che il controllo è stato fatto.

**`ia`, fase atti**: se la diagnosi ha trovato delta `↑` su `pkgs-ai`, lancia
`nix flake update ai` + `home-manager switch` senza chiedere conferma e riporta l'esito (versioni
installate, cache o compilazione). A switch riuscito, passa alla chiusura
`flake.lock` e `i1/manutenzione.json` (non i temporanei di `.claude/`),
con messaggio `chore(home): aggiorna agenti AI (<pacchetti e versioni>)`
e nuovo rev dell'input `ai` nel corpo. Commit e push del bump sono autonomi,
dopo gli allineamenti previsti dal nucleo. `applicato_su` segue il
[contesto](contesto.md). Se lo switch fallisce nella build, ripristina il lock
(`o3/scripts/ripristina-lock.sh`) e non committare il bump (nemmeno il log: un
tentativo fallito non è un esito da registrare come riferimento di freschezza):
il tree torna pulito e il resto si può committare. Il giro autonomo segue
`o3/ciclo/prompt.md`.

Restituisci delta, valutazione, esito dello switch e host verificati alla
[chiusura comune](chiusura.md). Su deck segui [remoto](remoto.md) prima del commit.
