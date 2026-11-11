"""L'uscita dal deck: frammento comune, resa e controllo della build."""

import shutil
import sys
import tempfile
import unittest
from pathlib import Path

BUILDERS = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(BUILDERS))

import project  # noqa: E402
import sources  # noqa: E402

URL = "https://cdn.jsdelivr.net/npm/reveal.js@5.1.0"


class FrammentoTests(unittest.TestCase):
    def test_link_relativo_ad_alt_lasciato_al_browser(self):
        frammento = sources.deck_exit()
        self.assertIn('href="index.html"', frammento)
        self.assertIn("keyboardCondition: (event) => !event.altKey", frammento)

    def test_etichetta_nella_lingua_del_repo(self):
        lingua = project.LINGUA
        self.addCleanup(setattr, project, "LINGUA", lingua)
        project.LINGUA = "it"
        self.assertIn("← viste", sources.deck_exit())
        project.LINGUA = "en"
        self.assertIn("← views", sources.deck_exit())

    def test_la_build_rompe_senza_il_frammento(self):
        with self.assertRaises(SystemExit):
            sources.check_deck_exit("<html><body>builder di dominio</body></html>")
        sources.check_deck_exit(f"<html><body>{sources.deck_exit()}</body></html>")


@unittest.skipUnless(shutil.which("pandoc"), "pandoc assente")
class RevealPageTests(unittest.TestCase):
    def test_il_frammento_segue_l_inizializzazione(self):
        with tempfile.TemporaryDirectory() as cartella:
            pagina = sources.reveal_page(
                "# Titolo\n\n## Slide\n\nTesto.\n", "deck.md", "Deck", URL, Path(cartella)
            )
        sources.check_deck_exit(pagina)
        self.assertLess(pagina.index("Reveal.initialize"), pagina.index(sources.deck_exit()))


if __name__ == "__main__":
    unittest.main()
