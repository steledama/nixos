# Ramo world

- **`world`** — host: agnostico per la verifica upstream; host specifico solo
  per eventuali verifiche runtime/build. Input: righe `Dip.: w<n>` di
  `o1/plan.md` con `probe:` in legenda. Lock: per titolo task, cadenza in
  `world.<titolo>.cadenza_giorni`. Azione: diagnostica; propone sblocchi,
  non rimuove codice.

Leggi le righe `w<n>` del plan, la legenda e i criteri di chiusura nei
file `o2/`. Lo script del [contesto](contesto.md) enumera solo le `w` con
`probe:` (canone `method/plan.md`, «Risveglio»), anche senza voce nel
registro; applica scope e lock individualmente. Una voce del registro senza
più la sua riga nel plan esce come `orfano.world.<titolo>` e si toglie
(contesto, «Orfane»). Le `w` ad `arrival:` le
riconosce `eval perceive`, non questo ramo. I `by:` passati di `w` e `p` li
dà `scadenze.py` in `exec plan`.

La sonda si scrive nel vocabolario chiuso di `o3/scripts/probe.sh`, che la
valuta senza il modello: `github <owner>/<repo>#<n> closed`, `nixpkgs
<attributo> >= <versione>` (su `nixos-unstable`), `registro <ramo> dopo
<data>`. Lancia `o3/scripts/probe.sh <indice>...` per le `w` dovute: esce
`vero`, `falso` o `errore` per indice. Un tipo sconosciuto è un rilievo da
correggere nella legenda, mai un comando da eseguire a mano.

L'esito della sonda è il segnale, non la chiusura:

- `vero`: leggi il criterio di chiusura nel file `o2/`. Per una issue
  verifica che il fix sia rilasciato e integrato (`gh issue view` con
  `--json` e i soli campi che servono, senza `--jq`; le graffe di un filtro
  sono un'ipotesi di diniego, giro del 2026-10-27). Per una versione il
  criterio di norma è già soddisfatto;
- `falso`: `invariato`, senza altre chiamate;
- `errore`: ritenta una volta in un altro giro; se persiste, `da_riverificare`
  con il dettaglio nella nota.

Comportamento da provare (es. build): di default segnala il tentativo
necessario, comando minimo e host, senza avviare prove pesanti. Se
`verifica_attiva_su_cadenza: true`, quando dovuto tenta davvero la build: è
un opt-in motivato nella nota del task, non generalizzabile.

Esito per voce: `invariato`, `chiudibile` (resta la verifica runtime del
criterio) o `da_riverificare` (segnale ambiguo, es. fix non rilasciato).
Se chiudibile, proponi di togliere solo dipendenza `w<n>` e legenda; il
task resta fino a verifica runtime e rimozione del codice. Non rimuovere
qui overlay, patch o wrapper: il [bump overlay](overlay.md) non autorizza la
rimozione del meccanismo.

Registra data/ora, esito e nota in `world.<titolo>` secondo la [registrazione](chiusura.md):
log autonomo, proposta di sblocco separata e soggetta a conferma.

Copre solo le dipendenze `w<n>` con `probe:` tracciate nel plan: altri
workaround restano fuori dalla sorveglianza. Un'attesa che nessun tipo del
vocabolario sa interrogare (una release senza issue, una nota nelle
[fonti upstream](references/upstream.md)) dichiara `arrival:` e la riconosce
`eval perceive`; se ricorre, il tipo nuovo si aggiunge allo script con i
suoi test. Il controllo non è un audit sistematico.
