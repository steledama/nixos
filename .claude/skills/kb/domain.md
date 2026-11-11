# Profilo KB — nixos

La KB canonica è esposta da `method/`; il corpus locale è `kb/**/*.md`,
escluso `kb/kb.md`. Non includere i nodi del canone nel catalogo locale.

## Audit e perimetri

```bash
python3 o3/tools/kb_profile.py --root .
python3 o3/tools/kb_tools.py audit --format markdown
python3 o3/tools/kb_tools.py inventory
python3 o3/tools/kb_tools.py facts
python3 o3/tools/kb_tools.py coverage
python3 o3/tools/kb_tools.py fidelity
python3 method/../o3/skill_tools.py audit
python3 method/../o3/skill_tools.py classifica
```

Il profiler misura nodi, dimensioni, maturità e impronte. Il backend verifica
struttura e facet locali (oggi `ciclo` sugli item di collezione).
`inventory` censisce host, profili e moduli; `facts` confronta inventari e
alcune invarianti dichiarative; `coverage` cerca riferimenti a moduli e
macro-aree. `fidelity` aggrega controlli già eseguiti: non contarli due volte.
Il parsing del codice non equivale alla valutazione Nix né a una verifica
dei sistemi attivi. Non pretendere un nodo per ogni modulo interno.
`skill_tools.py` è il guardiano quantitativo delle skill, lanciato dal
checkout del canone senza copiarlo, finché la rinomina per atto non gli dà la
sua skill. Falso positivo noto: `.#user@host` in `exec` è un modello, non un
comando del giro.

## Review di dominio

Distingui configurazione dichiarata, generazione attivata e stato osservato.
`flake.nix`, host, profili e moduli sono fonti tecniche; `world.md` dichiara
l'assetto operativo di riferimento. Una specializzazione scelta al boot può
differire dal default versionato: non risolvere il confronto dal solo Git.

Alza la priorità di verifica per rete, segreti, recovery, ruoli e confini
system/Home Manager. Conserva gotcha e catene causali degli incidenti quando
spiegano vincoli ancora utili. Nei runbook verifica prerequisiti, writer,
ordine, esito atteso e rollback; la review non esegue switch, rebuild o restore.
Per fonti runtime non accessibili dichiara il limite senza certificare gli host.

Prove di navigazione da adattare al caso:

- capire quale fonte determina il ruolo e quale mostra quello attivo;
- trovare il percorso di recovery e le sue precondizioni;
- distinguere configurazione system e home prima di modificare una capability.

Modello e procedura possono avere nodi autonomi; conserva il confine locale
fra KB procedurale e prescrizioni di atti specifici, senza traslochi automatici.

## Dopo un intervento

Formatta i file toccati: Markdown con `prettier`, Python con `ruff format`,
Nix con `alejandra`. Riesegui l'audit sopra e `o3/tools/check.sh`.
Se cambiano sorgenti presentative rigenera le viste pertinenti con
`python3 o3/view/build.py`.
