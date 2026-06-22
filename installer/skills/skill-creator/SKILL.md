---
name: skill-creator
description: Create, modify, package, and evaluate reusable AI skills with precise triggers, useful workflows, and quality evidence.
---

# Skill Creator

Use this skill when the requested deliverable is a reusable AI skill: a `SKILL.md`, supporting references, scripts, examples, metadata, or an evaluation plan. It applies to creating a skill from scratch, improving trigger accuracy, rewriting vague instructions, packaging a skill for distribution, or measuring whether a skill helps the agent perform a task reliably.

Do not use this skill for ordinary coding tasks unless the result must be captured as a reusable skill. Do not include copied documentation as the main body; synthesize operational guidance and cite sources separately.

## Workflow

1. Define the skill’s job, intended user, trigger phrases, and non-goals.
2. Write frontmatter with exact folder-name matching and an action-oriented description.
3. Structure the body into when to use, when not to use, workflow, output contract, validation, and safety notes.
4. Add references and optional helper scripts when they are genuinely useful.
5. Evaluate trigger precision with examples that should and should not activate the skill.
6. Run local verification and audit scripts.

## Output Expectations

Return changed files, evidence commands, and any remaining limitations. A good skill should be easy to scan, hard to misuse, and specific enough to avoid activating for unrelated tasks.

## Quality Notes

Do not make unsupported capability claims. Keep examples safe and generic. Remove unfinished marker text before finalizing.
