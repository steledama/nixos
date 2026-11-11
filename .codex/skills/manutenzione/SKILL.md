---
name: manutenzione
description: Project skill for the nixos repository update review and upstream-debt watch. Use when the user asks for /manutenzione (optionally with a scope ia|home-manager|casa|world|all), a check of available updates, an upgrade risk assessment, or a check on tracked upstream-dependent workarounds/overlays.
---

# manutenzione

Use the Claude project skill as the canonical source of instructions:

`../../../.claude/skills/manutenzione/SKILL.md`

When this skill triggers, read that file and follow it. Codex has no Skill tool, so reading that file is how this skill is invoked: where the canonical text asks to invoke a skill with the Skill tool (as `cycle` does for `eval` and `exec`), open that skill's wrapper and read its canonical file. This wrapper exists only so Codex can discover the project-level skill without duplicating the workflow.
