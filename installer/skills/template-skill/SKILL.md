---
name: template-skill
description: Author reusable skill blueprints and review checklists for creating consistent AI engineering skills.
---

# Skill Template Authoring

Use this skill when the user wants to design a reusable blueprint for new skills, standardize the structure of skill instructions, create review checklists, or improve consistency across a skill collection. The purpose is to help maintainers produce skills that are specific, useful, safe, and auditable without copying one-off wording across many folders.

Do not use this skill as a generic answer-writing mode. Do not use it to inflate a skill catalogue with shallow entries. If a user asks for a concrete domain skill, first clarify that domain and then create a real skill with operational guidance, references, and validation expectations.

## Workflow

1. Identify the target skill family, expected users, trigger boundaries, and evidence requirements.
2. Define the required sections: frontmatter, when to use, when not to use, workflow, output contract, validation gates, and safety notes.
3. Provide adaptable section guidance rather than filler text.
4. Include review criteria for trigger precision, source quality, secret handling, and local verification.
5. Recommend examples only when they teach structure without becoming copied final content.
6. Run repository audit checks after generated skills are materialized.

## Output Expectations

Return a clean blueprint, a checklist, and any repository files that should be updated when new skills are added. The result should help future authors create substantive skills that pass audit because they are useful, not because they satisfy superficial formatting.

## Quality Notes

Keep folder names and frontmatter names synchronized. Require real references for factual or tool-specific guidance. Mark unsupported claims as future work instead of presenting them as complete.
