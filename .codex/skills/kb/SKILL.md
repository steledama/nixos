---
name: kb
description: Project skill for structural audits and deep semantic reviews of the nixos knowledge base. Use for /kb audit or review, KB health, pruning, freshness, atomicity, redundancy, source-of-truth checks, catalog quality, links, or frontmatter.
---

# kb

Use the Claude project skill as the canonical source of instructions:

`../../../.claude/skills/kb/SKILL.md`

When this skill triggers, read that file and follow it. Codex has no Skill tool, so reading that file is how this skill is invoked: where the canonical text asks to invoke a skill with the Skill tool (as `cycle` does for `eval` and `exec`), open that skill's wrapper and read its canonical file. This wrapper exists only so Codex can discover the project-level skill without duplicating the workflow.
