---
ciclo: dev
---

# Grafie dei permessi

Lettura degli esiti di `o3/scripts/sonda-grafie.sh` raccolti in
`i1/grafie-permessi.jsonl`: quali forme di comando Claude Code nega o concede
nel giro autonomo quando ogni comando della forma è già in allow. Vale per
la versione provata e si rifà a ogni tornata; strumento e criterio sono in
`kb/cicli.md`, «Grafie dei permessi».

Tornata del 2026-10-28, Claude Code 2.1.311:

- **negate**: graffe `ls {o1,o2}`, `cd o1 && ls`, la sostituzione
  `$(…)`, il ciclo `for`, e un heredoc seguito da `&&`
  (`git commit -F - <<'EOF' && git log -1`);
- **concesse**: `&&` e `;` fra comandi in allow, pipe, redirezioni
  (`2>/dev/null`), `cd` da solo, l'heredoc da solo (`cat`,
  `git commit -F -`, `-m "$(cat <<'EOF' …)"`), `-m` ripetuti, e graffe e
  pipe dentro le virgolette (`jq -n '{a: 1, b: 2}'`, `--jq`).

Le cause dei dinieghi dei giri sono quindi verificate:

- il commit negato del 2026-10-27 non cadeva per l'heredoc ma per
  l'heredoc unito a `&&`;
- `cd` cade quando apre un composto, non da solo, e questo spiega anche il
  diniego del 2026-10-24 (`…; cd /home/stele/nixos && jq …`);
- le graffe contano solo fuori dalle virgolette.
- il `git log` negato del 2026-11-02 aveva `%(trailers:…)` fuori dalle
  virgolette, cioè bash non valido: la sonda su 2.1.312 nega la forma nuda
  e concede quella fra apici, già coperta da `Bash(git log*)`.

Il `gh issue view … --jq '{state,updatedAt,n:(.comments|length)}'`, negato
il 2026-10-27 su 2.1.308, passa identico su 2.1.311. Su quella versione non
è più riproducibile, e la causa resta legata alla versione precedente.
