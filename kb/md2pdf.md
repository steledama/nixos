---
stato: maturo
---

# md2pdf

Tool CLI home-manager per convertire Markdown in PDF con supporto Mermaid,
indice, numerazione sezioni e template LaTeX personalizzato.

## Distribuzione

`md2pdf` vive in `o3/modules/home/md2pdf.nix` ed è importato da `o3/home/default.nix`.
Di conseguenza è disponibile in user space su tutti i profili Home Manager del
flake.

Il modulo installa in `home.packages`:

- `pandoc`
- `mermaid-filter`
- `texlive` combinato con `scheme-medium` e `framed`
- `mermaid-filter-hq`
- `md2pdf`

La scelta è intenzionalmente home-level: il tool serve all'utente e agli agenti,
non a servizi systemd. Le dipendenze sono installate insieme al wrapper per
rendere il comando autosufficiente su qualunque host, anche senza sessione grafica.

## Uso

```bash
md2pdf documento.md          # senza indice
md2pdf --toc documento.md    # con indice su pagina propria
```

Il PDF viene creato nella directory corrente con lo stesso basename:

```text
documento.pdf
```

Il comando accetta un solo file Markdown più l'opzione facoltativa `--toc`. Se
il file non esiste, o se si passa un'opzione sconosciuta, termina con errore.

L'indice (table of contents) non è più predefinito: va richiesto esplicitamente
con `--toc`. Senza il flag il PDF non contiene né indice né la pagina dedicata.

## Provenienza della copia

Ogni pagina riporta data e ora di generazione, commit del repository sorgente
e indicazione «modificato» se il file è dirty o non tracciato. Per sorgenti
fuori da Git resta la data. Il timbro identifica la provenienza della copia,
non certifica che i suoi contenuti siano aggiornati o corretti.

## Pipeline

La pipeline reale è:

```text
Markdown -> mermaid-filter-hq -> citeproc -> xelatex -> PDF
```

Il wrapper invoca `pandoc` con:

```text
--pdf-engine=xelatex
--template=o3/modules/home/md2pdf/pdf-mermaid.latex
--filter=mermaid-filter-hq
--citeproc
--number-sections
--shift-heading-level-by=-1
-V papersize=a4
```

Solo con `--toc` vengono aggiunti `--toc` e `-V toc-own-page=true`.

`--shift-heading-level-by=-1` promuove i titoli di un livello, utile per note e
nodi Markdown che partono da `#`.

## Mermaid

`mermaid-filter-hq` è un wrapper locale di `mermaid-filter` con risoluzione
hardcoded:

```text
MERMAID_FILTER_SCALE=4
MERMAID_FILTER_WIDTH=1200
```

Questo evita di dipendere da variabili d'ambiente della shell interattiva, che
non sempre vengono propagate ai processi avviati dal desktop. L'obiettivo è
ottenere diagrammi Mermaid leggibili in PDF A4.

Le immagini temporanee generate da `mermaid-filter` vengono scritte in una
directory temporanea sotto `/tmp`. Anche `XDG_CACHE_HOME` viene confinata nella
stessa directory: fontconfig può quindi costruire la propria cache senza
scrivere nella home e senza produrre warning negli ambienti isolati.

## Template LaTeX

Il template `o3/modules/home/md2pdf/pdf-mermaid.latex` deriva dal template Pandoc e
aggiunge il supporto a:

```text
-V toc-own-page=true
```

Quando attivo, `md2pdf` inserisce una nuova pagina dopo l'indice. Il template
imposta anche `DejaVu Sans Mono` come font monospaziato.

## Quando usarlo

Usare `md2pdf` per produrre PDF leggibili da documenti Markdown locali, report,
note operative e output con diagrammi Mermaid. Per conversioni di dominio
specifiche, il repo di dominio può documentare il proprio workflow, ma la
capability e la distribuzione del comando restano qui nel repo `nixos`.

Connessioni:

- [home-manager](home-manager.md)
- [development-environment](development-environment.md)
- [configuration-patterns](configuration-patterns.md)
