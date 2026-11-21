"""Identità del progetto sulle superfici di `view/`.

È l'unico file che il fork parametrizza: sigla e lingua, colore d'accento,
sorgente del deck, esclusioni dal perimetro. Stile, struttura delle pagine e
contratti restano canone, uguali in ogni repo (`kb/view.md`,
`kb/presentation.md`).
"""

# Sigla del repo nei titoli delle pagine e nella navigazione.
SIGLA = "NixOS"

# Lingua delle poche etichette che la build scrive di suo: "en" oppure "it".
LINGUA = "en"

# Colore d'accento, unico per progetto: è ciò che distingue le viste.
ACCENTO = "#c2410c"

# Sorgente del deck, relativa alla root, oppure None se il repo non ha un
# deck. Le tavole si citano come `assets/<nome>` e la loro fonte vive accanto
# al deck, in `presentation/`.
DECK: str | None = "presentation/presentation.md"

# In alternativa a DECK: il nome di un modulo di dominio in questa cartella
# che genera il deck, con `render(root, reveal_url, folder) -> str` (la pagina
# completa). Chi parte da Markdown usa `sources.reveal_page`.
DECK_BUILDER: str | None = None

# CSS di dominio del deck (diagrammi, componenti), in `presentation/`, copiati
# in `view/assets/` e caricati dopo deck.css e theme.css. Vuoto se il deck usa
# solo il canone.
CSS_LOCALI: list[str] = ["nixos.css"]

# Fonti del perimetro (register e collezioni) da non rendere, come pattern
# glob relativi alla root: «i2/diario-*.md». Le viste possono essere servite
# sulle reti private: ciò che il repo non vuole esporre resta qui.
ESCLUSE: list[str] = []

# Descrizione locale dello stadio Perform sulla home.
DESCRIZIONI = {"o3": "Dichiarazione runtime e strumenti deterministici del Perform."}
