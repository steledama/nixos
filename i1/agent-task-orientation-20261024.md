---
ciclo: dev
---

# Orientamento per la revisione di un task

Fonte: chiamate e risultati degli strumenti nella sessione interattiva
Codex su `deck` del 2026-10-24, avviata con la richiesta «vorrei rivedere
insieme a te il primo task del piano». Cattura selettiva del percorso,
conservata per confrontarlo con un nuovo ingresso; non è una trascrizione
integrale né una misura dei token consumati.

## Percorso osservato

1. Prima chiamata: lettura di `README.md`, `CLAUDE.md`, `autonomy.md`,
   `o1/plan.md` e wrapper `.codex/skills/exec/SKILL.md`.
2. Seconda chiamata: `hostname` (risposta `deck`), `git status --short`
   (pulito), lettura della skill canonica `.claude/skills/exec/SKILL.md`
   e di `o2/tasks.md`, ricerca `rg` del titolo in `o2/`, `i3/`, `kb/`.
   L'indice appena letto conteneva già il link al task.
3. Terza chiamata: lettura del task `o2/design-agent-as-user.md`, poi
   `kb/cicli.md` e `i3/allineamento-metodo.md` insieme. Quest'ultimo
   risultato riporta `Warning: truncated output` e 555 righe totali.
4. La risposta identifica il task e distingue correzioni da osservare,
   interventi da valutare e decisione sul confronto usato da `remoto`.
   Propone di chiarire l'ampiezza della revisione. Il custode conferma
   l'intento più ampio dell'esperienza d'uso, oltre i dinieghi.

## Riscontri e limiti

- Il primo comando `hostname` segue le letture iniziali. Nel testo letto,
  la sezione «Rilevamento host» seguiva «Bootstrap di sessione» ma
  prescriveva il rilevamento prima del primo atto. `AGENTS.md` iniziava
  la sequenza da `README.md`, senza nominare il comando.
- L'agente ha fatto una ricerca del titolo pur avendo già il puntatore
  esatto nell'indice. Il percorso `plan → tasks → dettaglio` era presente
  e ha permesso di trovare il task; non è osservata una mancanza del link.
- `README.md`, `CLAUDE.md` e `autonomy.md` contavano complessivamente
  488 righe; la skill `exec` 264. Sono dimensioni dei file, non prova che
  ogni riga sia stata usata o fosse superflua.
- La lettura cumulativa di KB e filo ha superato il budget di output della
  chiamata. Non è verificato qui quali sezioni omesse avrebbero cambiato
  la risposta. Il troncamento non dimostra che i due documenti vadano divisi.
- L'agente ha riconosciuto la propria omissione sul rilevamento e la
  ricerca superflua. Questo singolo caso non isola il peso dell'ordine
  dei documenti rispetto alle scelte dell'agente.

## Riscontro sull'ingresso di exec

Lettura statica successiva nella stessa sessione, senza simulare una nuova
esecuzione: `.claude/skills/exec/SKILL.md` ha 264 righe. La parte comune
precede `plan` (riga 67); `specify` occupa le righe 192-217, `perform`
inizia a 218 e le note comuni a 249. Il wrapper richiede la lettura del
file canonico intero; non offre ingressi distinti per stadio.

Due formulazioni richiedono riconciliazione con altre istruzioni:

- la riga 21 dice che un giro vuoto si chiude con un commit vuoto; le
  righe 53-60 affidano il commit a `/commit` e al momento concordato;
- il gate comune include fra gli atti fuori delega ogni atto su host
  diversi dal locale; `autonomy.md`, criterio `atti-remoti`, consente
  invece gli atti nominati tramite `remoto` sugli host non production.

Sono riscontri sul testo, non errori operativi osservati in questa prova.
Nel primo scambio il custode aveva già scelto il task da discutere: non
aveva chiesto di riesaminare la priorità dell'intera coda o di eseguirlo.

Connessioni:

- [agent-as-user](../method/agent-as-user.md)
