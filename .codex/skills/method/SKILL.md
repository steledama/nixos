---
name: method
description: Project skill for reviewing drift between nixos and the canonical method repository. Use for /method, method drift, adopter alignment, or propagation of method changes.
---

# method

Use the Claude project skill as the canonical source of instructions:

`../../../.claude/skills/method/SKILL.md`

When this skill triggers, read that file and follow it. Codex has no Skill tool, so reading that file is how this skill is invoked: where the canonical text asks to invoke a skill with the Skill tool (as `cycle` does for `eval` and `exec`), open that skill's wrapper and read its canonical file. This wrapper exists only
so Codex can discover the project-level skill without duplicating the workflow.
