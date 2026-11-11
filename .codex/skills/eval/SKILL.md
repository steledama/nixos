---
name: eval
description: Project skill for the evaluation arc in nixos. Use when the user asks for /eval, eval perceive/interpret/compare, signal intake from the running system, i2 synthesis review, verdict review, i3 thread hygiene, goal-to-signal coverage, or plan cleanup from state narrative.
---

# eval

Use the Claude project skill as the canonical source of instructions:

`../../../.claude/skills/eval/SKILL.md`

When this skill triggers, read that file and follow it. Codex has no Skill tool, so reading that file is how this skill is invoked: where the canonical text asks to invoke a skill with the Skill tool (as `cycle` does for `eval` and `exec`), open that skill's wrapper and read its canonical file. This wrapper exists only so Codex can discover the project-level skill without duplicating the workflow.
