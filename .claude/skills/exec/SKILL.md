---
name: exec
description: Il braccio di esecuzione del ciclo — exec [plan|specify|perform|all] — coda e priorità del plan, qualità interna dei task o2, supervisione della collezione o3 e atti coperti da autorizzazione
user-invocable: true
---

# exec

Scegli lo scope dall'intento della richiesta. L'invocazione esplicita `/exec`
senza argomento equivale ad `all`; una richiesta in linguaggio naturale
mantiene il proprio perimetro:

- rivedere la qualità di un task già scelto → `specify <task>`;
- scegliere il prossimo task o rivedere priorità e dipendenze → `plan`;
- compiere un atto autorizzato o rivedere le prescrizioni → `perform`;
- `/exec all` → `plan` → `specify` → `perform`.

Leggi questo nucleo comune e il solo file relativo allo stadio richiesto:
[plan.md](plan.md), [specify.md](specify.md), [perform.md](perform.md).
Per `all`, leggili nell'ordine di esecuzione. Sono procedure della stessa
skill, non skill aggiuntive. Il file del task e i suoi rimandi danno il
contesto dell'oggetto; discutere il task non ne autorizza l'esecuzione.
Quando ricavi lo scope dal linguaggio naturale, dichiaralo insieme
all'oggetto prima di procedere. `specify` senza oggetto rivede la collezione;
`specify <task>` rivede il file identificato dal titolo o dal percorso.

Ogni stadio invocato restituisce un esito
esplicito e può **chiudere in una riga** quando non ha materia («coda
coerente, nessun intervento»): la chiusura vuota è esito legittimo, non un
passo saltato.

L'esito di ogni stadio invocato si registra nel commit che chiude il giro, con
un trailer contabile (`materia` se lo stadio ha prodotto o cambiato qualcosa,
`vuoto` se ha chiuso in una riga; gli stadi non invocati non compaiono):

```
Esiti: plan=materia specify=vuoto perform=vuoto
```

Come in `eval`, `vuoto` è lo stadio che ha girato col suo **minimo**, in
fondo al suo file, senza trovare materia; lo stadio saltato resta fuori
dal trailer.

Quando il commit del giro è richiesto, `/commit` conserva lo stesso
trailer anche senza file cambiati, con `git commit --allow-empty`. Il conteggio è
`git log --format='%(trailers:key=Esiti,valueonly)'` (`method/skill.md`).
`/manutenzione` non è uno stadio della tripartizione e non porta il trailer.

È la skill simmetrica di `eval`: questa tiene onesta l'esecuzione, quella la
valutazione; il register `goal.md` è la cerniera che entrambe controllano da
versanti opposti. Usala a inizio sessione quando bisogna scegliere cosa
affrontare, e a fine sessione quando modifiche tecniche, reboot, rebuild o
decisioni operative possono aver cambiato priorità, dipendenze o completezza
dei task. Dopo eventi del mondo gira per **ultima** nel protocollo post-evento
(`eval` → `exec`): le priorità si rivalutano su verdetti freschi, non stantii.

**Gate comune, autorità prima dell'atto**: leggere `autonomy.md` insieme
alle autorizzazioni operative di `CLAUDE.md` e alla richiesta corrente. Nel
ciclo delegato dal custode si applicano gli esiti ordinari senza conferme
intermedie, con fonti verificate e incertezza esplicita. Restano al custode
cambi di scopi, territorio o criteri di autonomia, atti fuori delega e
incertezze decisive non risolvibili dalle fonti. Sospendere il solo punto
che richiede una decisione e continuare il lavoro indipendente. In assenza
di delega applicabile si propone; il colore dell'impatto non concede autorità.
Per gli atti remoti vale `autonomy.md`, criterio `atti-remoti`; per sudo,
rebuild e reboot valgono le regole operative di `CLAUDE.md`.

Chiudere gli scope richiesti con i controlli, l'esito per stadio e la
proposta di commit. Questa skill è una base e non chiama altre skill
(`method/skill-composition.md`): commit e push del branch corrente, nei
limiti di `CLAUDE.md`, li compie `/commit` quando li chiede il custode o la
composta `/cycle`, e ne scrive i trailer dagli esiti ricevuti. Nella sessione interattiva il momento del commit si
concorda col custode (`autonomy.md`, `momento-del-commit`): un ciclo chiesto
fino al commit lo include, gli scambi successivi no. Nel ciclo congiunto
l'ordine è `eval → exec → commit`,
senza conferme obbligatorie fra gli archi; invocare un arco solo non estende
lo scope. Il resoconto finale distingue decisioni applicate in autonomia,
conferme richieste, punti sospesi e proposte pendenti, con i motivi. La
presenza del custode non equivale alla ratifica di ogni modifica; i trailer
seguono chi l'ha decisa.
