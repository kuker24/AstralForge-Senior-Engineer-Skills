---
name: plugin-creator
description: Create and organize local Codex plugin directories with metadata, optional structure, review checks, and marketplace entries.
---

# Plugin Creator

Use this skill when the user wants to create a new local plugin, scaffold a plugin directory, add required metadata, prepare optional folders, or update a repository-local plugin marketplace manifest. The skill focuses on safe structure, naming, metadata quality, and reviewable files that a maintainer can customize before publishing.

Do not use this skill for installing third-party plugins, running untrusted plugin code, or changing global agent configuration without approval. If the requested work is a reusable AI skill rather than a plugin, route to the skill creation workflow.

## Workflow

1. Clarify plugin name, purpose, host agent, expected commands, and target directory.
2. Create the required metadata file and minimal folder structure.
3. Add optional docs, examples, tests, or assets only when they support the plugin’s intended behavior.
4. Validate JSON metadata and repository paths.
5. Review for dangerous defaults, shell execution risks, and accidental secrets.
6. Summarize how to test locally without publishing.

## Output Expectations

Return created paths, metadata summary, validation commands, and manual next steps. If marketplace entries are updated, list ordering and compatibility assumptions.

## Safety Notes

Never execute unknown plugin code just to verify structure. Do not embed credentials in plugin metadata. Keep generated files small and reviewable.
