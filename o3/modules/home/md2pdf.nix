# modules/home/md2pdf.nix
# Script CLI md2pdf: converte Markdown in PDF via pandoc + xelatex
#
# Uso: md2pdf [--toc] documento.md → crea documento.pdf nella directory corrente
#   --toc: aggiunge l'indice (table of contents) su pagina propria. Default: senza.
#
# Pipeline: Markdown → [mermaid-filter-hq] → [citeproc] → [xelatex] → PDF
#
# mermaid-filter-hq: wrapper di mermaid-filter con risoluzione hardcodata
#   MERMAID_FILTER_SCALE=4, MERMAID_FILTER_WIDTH=1200 → ~760 DPI su A4
#   Necessario perché mermaid-filter legge da env vars che non vengono
#   propagate ai processi avviati dal desktop (solo dalla shell interattiva).
#
# Template LaTeX personalizzato: aggiunge supporto toc-own-page (\newpage
# dopo \tableofcontents) assente nel template pandoc predefinito.
#
# Dipendenze: pandoc, mermaid-filter e texlive sono installati qui come home.packages
# in modo che md2pdf sia autosufficiente su qualunque host (server headless incluso).
{pkgs, ...}: let
  texliveFull = pkgs.texliveMedium.withPackages (ps: [ps.framed]);
  mermaidFilterHq = pkgs.writeShellScriptBin "mermaid-filter-hq" ''
    MERMAID_FILTER_SCALE=4 \
    MERMAID_FILTER_WIDTH=1200 \
      ${pkgs.mermaid-filter}/bin/mermaid-filter "$@"
  '';

  md2pdf = pkgs.writeShellScriptBin "md2pdf" ''
        set -euo pipefail

        WITH_TOC=0
        INPUT_ARG=""

        for arg in "$@"; do
          case "$arg" in
            --toc)
              WITH_TOC=1
              ;;
            -*)
              echo "Unknown option: $arg" >&2
              echo "Usage: md2pdf [--toc] <file.md>" >&2
              exit 1
              ;;
            *)
              if [[ -n "$INPUT_ARG" ]]; then
                echo "Usage: md2pdf [--toc] <file.md>" >&2
                exit 1
              fi
              INPUT_ARG="$arg"
              ;;
          esac
        done

        if [[ -z "$INPUT_ARG" ]]; then
          echo "Usage: md2pdf [--toc] <file.md>" >&2
          exit 1
        fi

        # Risolvi il percorso assoluto del file sorgente
        if [[ "$INPUT_ARG" = /* ]]; then
          INPUT_ABS="$INPUT_ARG"
        else
          INPUT_ABS="$(pwd)/$INPUT_ARG"
        fi

        if [[ ! -f "$INPUT_ABS" ]]; then
          echo "Error: file not found: $INPUT_ARG" >&2
          exit 1
        fi

        OUTDIR="$(pwd)"
        BASENAME="$(basename "$INPUT_ABS" .md)"
        OUTPUT="$OUTDIR/$BASENAME.pdf"

        # Indice (table of contents) solo se richiesto con --toc, su pagina propria.
        TOC_ARGS=()
        if [[ "$WITH_TOC" -eq 1 ]]; then
          TOC_ARGS=(--toc -V toc-own-page=true)
        fi

        # Cartella temporanea in /tmp: mermaid-filter salva le immagini lì.
        # Viene pulita automaticamente dal sistema al riavvio.
        TMPDIR="$(mktemp -d)"
        export XDG_CACHE_HOME="$TMPDIR/cache"
        mkdir -p "$XDG_CACHE_HOME/fontconfig"
        cd "$TMPDIR"

        # Timbro di versione nel piè di pagina: data/ora di generazione + riferimento
        # git del sorgente (+ "modificato" se ha modifiche non committate o non è
        # ancora tracciato). Serve a riconoscere se una copia stampata corrisponde
        # all'ultima bozza. Deriva tutto da git: niente da mantenere a mano nel
        # frontmatter. Se il sorgente è fuori da un repo git, resta la sola data/ora.
        STAMP="Generato $(date '+%Y-%m-%d %H:%M')"
        SRC_DIR="$(dirname "$INPUT_ABS")"
        if ${pkgs.git}/bin/git -C "$SRC_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
          GIT_HASH="$(${pkgs.git}/bin/git -C "$SRC_DIR" rev-parse --short HEAD 2>/dev/null || true)"
          if [[ -n "$GIT_HASH" ]]; then
            STAMP="$STAMP — git $GIT_HASH"
            if [[ -n "$(${pkgs.git}/bin/git -C "$SRC_DIR" status --porcelain -- "$INPUT_ABS" 2>/dev/null || true)" ]]; then
              STAMP="$STAMP — modificato"
            fi
          fi
        fi

        # fancyhdr via header-includes: footer su ogni pagina (title page compresa,
        # ridefinendo anche lo stile "plain"). Nessuna modifica al template.
        FOOTER_TEX="$TMPDIR/md2pdf-footer.tex"
        cat > "$FOOTER_TEX" <<EOF
    \usepackage{fancyhdr}
    \pagestyle{fancy}
    \fancyhf{}
    \renewcommand{\headrulewidth}{0pt}
    \fancyfoot[L]{\footnotesize\textcolor{gray}{$STAMP}}
    \fancyfoot[R]{\footnotesize\textcolor{gray}{\thepage}}
    \fancypagestyle{plain}{\fancyhf{}\renewcommand{\headrulewidth}{0pt}\fancyfoot[L]{\footnotesize\textcolor{gray}{$STAMP}}\fancyfoot[R]{\footnotesize\textcolor{gray}{\thepage}}}
    EOF

        exec ${pkgs.pandoc}/bin/pandoc \
          --pdf-engine=xelatex \
          --template=${./md2pdf/pdf-mermaid.latex} \
          --filter=mermaid-filter-hq \
          --citeproc \
          --number-sections \
          --shift-heading-level-by=-1 \
          -V papersize=a4 \
          -V fontsize=11pt \
          -V geometry:margin=2.5cm \
          --include-in-header="$FOOTER_TEX" \
          "''${TOC_ARGS[@]}" \
          --output="$OUTPUT" \
          "$INPUT_ABS"
  '';
in {
  home.packages = [
    pkgs.pandoc
    pkgs.mermaid-filter
    texliveFull
    mermaidFilterHq
    md2pdf
  ];
}
