---
name: exec
description: Project skill for the execution arc in nixos. Use when the user asks for /exec, exec plan/specify/perform, task queue review, priorities and dependencies, o2 task quality, o3 prescriptions upkeep, or the next task to work on.
---

# exec

Use the Claude project skill as the canonical source of instructions:

`../../../.claude/skills/exec/SKILL.md`

When this skill triggers, read that file and follow it. Codex has no Skill tool, so reading that file is how this skill is invoked: where the canonical text asks to invoke a skill with the Skill tool (as `cycle` does for `eval` and `exec`), open that skill's wrapper and read its canonical file. This wrapper exists only so Codex can discover the project-level skill without duplicating the workflow.
