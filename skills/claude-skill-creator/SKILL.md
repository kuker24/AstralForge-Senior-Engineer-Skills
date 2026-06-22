---
name: claude-skill-creator
description: Create, refine, package, and evaluate Claude skills with reliable trigger behavior and useful operational guidance.
---

# Claude Skill Creator

Use this skill when a user wants to create a new Claude skill, improve an existing skill, package skill assets, or evaluate whether a skill triggers at the right time. It is especially useful when the work includes `SKILL.md` frontmatter, trigger descriptions, bundled scripts, examples, references, or a release checklist for distributing the skill.

Do not use this skill for general feature implementation unless the deliverable is itself a reusable skill. Do not copy external documentation into the skill body. Summarize principles, cite sources in `references/sources.md`, and keep examples concise.

## Workflow

1. Clarify the target user, trigger conditions, inputs, outputs, and boundaries.
2. Draft frontmatter with `name` matching the folder and a description that is specific enough to trigger accurately.
3. Write the body around operational behavior: when to use it, when not to use it, exact steps, validation gates, failure handling, and final output contract.
4. Add optional scripts, references, and fixtures only when they reduce repeated manual work.
5. Review for over-triggering, missing safety notes, vague wording, and instructions that conflict with project rules.
6. Run the repository skill verifier and substantive audit before calling the skill ready.

## Output Expectations

Deliver a skill folder that can be read quickly by an agent and still contains enough detail to guide real work. Include clear examples of trigger phrases when useful, but keep the skill focused on decisions and execution rather than broad marketing language.

## Validation Gates

A finished skill must have valid frontmatter, more than minimal body content, an agent configuration, sources, and no unfinished marker text. If evaluation examples exist, include both positive and negative trigger cases. Never claim broad support unless tests or reports prove it.
