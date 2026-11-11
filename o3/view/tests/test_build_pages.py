"""Regressioni di fedeltà delle pagine 1:1: gerarchia, link, immagini, ancore.

Usa Pandoc come la build; eseguire con python3 -m unittest discover -s tests.
"""

import subprocess
import sys
import tempfile
import unittest
from html.parser import HTMLParser
from pathlib import Path

BUILDERS = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(BUILDERS))

import build_pages
import build_system_image

GOAL = """# Goal

Intro.

## Obiettivi runtime

### 1. Primo obiettivo

Testo.

## Goal di sviluppo

Testo.
"""

INDEXES = {
    "o1/plan.md": "# Plan\n\n| Ciclo | Ob. | Task | Dip. |\n| --- | --- | --- | --- |\n"
    "| dev | 1 | Primo task | — |\n",
    "o2/tasks.md": "# Task\n\n- [primo.md](primo.md) — dettaglio.\n",
    "o3/prescriptions.md": "# Prescriptions\n",
    "i1/perceptions.md": "# Perceptions\n",
    "i2/interpretations.md": "# Interpretazioni\n",
    "i3/verdicts.md": "# Verdicts\n",
}


class Elements(HTMLParser):
    def __init__(self, markup):
        super().__init__()
        self.stack = []
        self.text = []
        self.targets = []
        self.ids = []
        self.feed(markup)

    def handle_starttag(self, tag, attrs):
        self.targets.extend((tag, key, value) for key, value in attrs if key in {"href", "src"})
        self.ids.extend(value for key, value in attrs if key == "id")
        if tag not in {"img", "br", "hr", "link", "meta"}:
            self.stack.append(tag)

    def handle_endtag(self, tag):
        if self.stack and self.stack[-1] == tag:
            self.stack.pop()

    def handle_data(self, data):
        if data.strip():
            self.text.append((tuple(self.stack), data.strip()))


class PageTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        files = {
            "goal.md": GOAL,
            "world.md": "# World\n\nIntro.\n",
            "kb/node.md": "# Nodo\n",
            "i2/schema.png": "png",
            "o2/primo.md": '---\nsintesi: "s"\nciclo: dev\n---\n\n# Primo task\n',
            **INDEXES,
        }
        for relative, content in files.items():
            path = self.root / relative
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(content, encoding="utf-8")
        subprocess.run(["git", "init", "-q"], cwd=self.root, check=True)

    def tearDown(self):
        self.tmp.cleanup()

    def render(self, relative, text):
        path = self.root / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text, encoding="utf-8")
        pages = {
            source: build_pages.Page(source, build_pages.title_of(self.root, source))
            for source in build_pages.perimeter(self.root)
        }
        images = {}
        markup = build_pages.render_page(self.root, pages[relative], pages, images, [])
        return markup, images

    def test_perimeter_is_registers_and_collections(self):
        sources = build_pages.perimeter(self.root)
        self.assertIn("goal.md", sources)
        self.assertIn("o2/primo.md", sources)
        self.assertNotIn("kb/node.md", sources)

    def test_autonomy_register_is_a_page_when_present(self):
        self.assertNotIn("autonomy.md", build_pages.perimeter(self.root))
        (self.root / "autonomy.md").write_text("# Autonomia\n", encoding="utf-8")
        self.assertIn("autonomy.md", build_pages.perimeter(self.root))

    def test_home_lists_pending_proposals_and_delegation(self):
        self.assertIn(build_pages.label("no-pending"), build_system_image.proposals_html(self.root))
        (self.root / "o2/primo.md").write_text(
            '---\nsintesi: "s"\nciclo: dev\ndecidere: "dove stanno gli `arresti`"\n---\n\n# Primo task\n',
            encoding="utf-8",
        )
        (self.root / "autonomy.md").write_text("# Autonomia\n", encoding="utf-8")
        section = build_system_image.proposals_html(self.root)
        self.assertIn('<a href="o2/primo.html">Primo task</a>', section)
        self.assertIn("<code>arresti</code>", section)
        self.assertIn('href="autonomy.html"', section)

    def test_hierarchy_and_all_sections_survive(self):
        source = """# Indice

Intro.

## Nome locale

- Padre
    - Figlio

### Dettagli

1. Primo
2. Secondo

## Ultima sezione

Conclusione.
"""
        markup, _ = self.render("i2/lettura.md", source)
        rendered = Elements(markup)
        body = [(tags, text) for tags, text in rendered.text if "main" in tags]
        self.assertIn(("html", "body", "main", "ul", "li", "ul", "li"), [t for t, _ in body])
        self.assertIn((("html", "body", "main", "h1"), "Indice"), body)
        self.assertIn((("html", "body", "main", "h3"), "Dettagli"), body)
        self.assertEqual(body[-1], (("html", "body", "main", "p"), "Conclusione."))

    def test_links_follow_the_perimeter(self):
        source = """# Lettura

[Goal](../goal.md#forma) [Task](../o2/primo.md) [Collezione](../i3/)
[Nodo](../kb/node.md) [Fuori](../../altro.md) [Web](https://example.org/a?x=1&y=2)
[Ancora](#dettagli) [Mail](mailto:utente@example.org) [Disco](file:///etc/hosts)
[Win](C:\\dati\\goal.md)

```markdown
[Letterale](../kb/node.md)
```
"""
        markup, _ = self.render("i2/lettura.md", source)
        hrefs = {target for tag, _, target in Elements(markup).targets if tag == "a"}
        for target in [
            "../goal.html#forma",
            "../o2/primo.html",
            "../i3/verdicts.html",
            "https://example.org/a?x=1&y=2",
            "#dettagli",
            "mailto:utente@example.org",
        ]:
            self.assertIn(target, hrefs)
        # Ciò che non si rende resta etichetta: nessun link esce da `view/`.
        self.assertFalse(any(".md" in href or href.startswith("file:") for href in hrefs))
        self.assertNotIn("../../altro.html", hrefs)
        self.assertIn("](../kb/node.md)", markup)
        self.assertEqual(markup, self.render("i2/lettura.md", source)[0])

    def test_images_are_copied_beside_the_page(self):
        markup, images = self.render("i2/lettura.md", "# L\n\n![Schema](schema.png)\n")
        self.assertIn(("img", "src", "schema.png"), Elements(markup).targets)
        self.assertEqual(set(images), {"i2/schema.png"})

    def test_missing_or_outside_image_breaks(self):
        for target in ["assente.png", "../../fuori.png", "file:///tmp/f.png"]:
            with self.assertRaises(SystemExit):
                self.render("i2/lettura.md", f"# L\n\n![F]({target})\n")

    def test_goal_has_stable_anchors(self):
        markup, _ = self.render("goal.md", GOAL)
        ids = Elements(markup).ids
        self.assertIn("ob-1", ids)
        self.assertIn("ob-s", ids)

    def test_frontmatter_goal_links_to_its_anchor(self):
        source = "---\nciclo: dev\nobiettivo: 1\n---\n\n# Filo\n"
        markup, _ = self.render("i3/filo.md", source)
        self.assertIn(("a", "href", "../goal.html#ob-1"), Elements(markup).targets)


if __name__ == "__main__":
    unittest.main()
