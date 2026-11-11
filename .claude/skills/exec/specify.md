# specify — la qualità interna dei task

Confine netto verso `plan`: `plan` guarda la corrispondenza e l'ordine delle
righe (il piano come coda, generatore incluso), `specify` la qualità interna
dei file `o2/` — la corrispondenza non si verifica due volte. Con
`<task>`, applica i criteri al solo file identificato; senza oggetto, ai file
`o2/` vivi (o a quelli toccati di recente, se il giro è leggero):

- ogni task sostanziale ha il suo file: un task che vive solo come riga del
  plan e sta accumulando contesto è un file `o2/` mancante
- il frontmatter è completo: `sintesi` (la verifica dura la fa il generatore)
  e la facet `ciclo: dev|runtime`, letta dal Mondo su cui il task insiste —
  `dev` se insiste sull'artefatto (KB, viste, strumenti), `runtime` se insiste
  sul sistema in esecuzione
- i diari di sessione si potano a chiusura: il file porta lo stato corrente
  del lavoro, non il log delle sessioni
- le **quattro proprietà cardine** come criteri di qualità (cfr.
  `method/specify.md`): la specifica rende visibile ciò che il perform dovrà
  fare (visibilità), dichiara come si saprà che ha funzionato — in NixOS il
  criterio di verifica runtime: quale host, quale comando, quale esito atteso
  (feedback), mappa i concetti del task sui file reali di `o3/` (mapping), e
  scrive i vincoli che impediscono l'atto sbagliato — livello system vs home,
  ordine fra gli host, host su cui non si tocca nulla (constraint)

Nel ciclo autonomo `specify` porta nella specifica le notizie del giro
(informazioni corrette, risultato atteso, vincoli, verifica) e ne cura la
forma. Non esegue i passi del task (`method/tasks.md`, «Task e giro»).

Esito: quali file sono a posto, quali hanno un difetto e quale, o la chiusura
in una riga.

Minimo: i file `o2/` che le notizie del giro toccano, o i frontmatter di
`o2/` quando non ne toccano nessuno.
