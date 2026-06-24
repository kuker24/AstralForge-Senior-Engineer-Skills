# AstralForge Token Profile: coding

Profile for implementing or debugging code changes.

## Purpose

Make precise code edits with current library knowledge and minimal context waste.

## Active Tools

- Built-in read/edit/shell tools.
- Context7 CLI + Skills on demand for library/API/SDK/framework/version details.
- Serena for semantic symbol overview, reference search, and precise code navigation when broad file reads would waste tokens.

## Inactive Tools

- Context7 MCP remains off unless the user explicitly chooses MCP mode.
- Repomix is off unless a token report or compressed snapshot is needed.
- Non-core MCP servers are off.

## Expand Context When

- A symbol has multiple references.
- A failing test points to integration behavior.
- A change spans several files or package boundaries.

## Summarize When

- Reading more than three files.
- Command output exceeds a concise diagnostic summary.
- Capturing evidence for final review.

## Context7 Rule

Use Context7 for current APIs, migrations, SDK usage, framework conventions, and cloud/service docs. Do not use it for generic programming questions.

## Serena Rule

Use Serena when symbol/references/navigation are needed. Avoid overlapping Serena actions with simple built-in file reads when a target file is already known.

## Repomix Rule

Use Repomix only for token report or repository snapshot when local context is too large for targeted reads.

## Validation

Run the smallest relevant check first, then expand:

1. Targeted test or script.
2. `npm run typecheck` when TypeScript changed.
3. `npm run test:unit` when tests/code changed.
4. Repo-specific audit when skills/config changed.

## Cleanup Behavior

- Clean only generated outputs known to be safe.
- Do not delete user files.
- Prefer quarantine/backup for local Pi cleanup.

## Security Boundary

- No secrets in logs/tests/reports.
- No destructive command without approval and a rollback path.
- No tag/release rewrite or force-push.

## Final Answer Discipline

Summarize changed files, commands, pass/fail status, unresolved risks, and the safest next step.
