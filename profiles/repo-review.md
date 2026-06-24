# AstralForge Token Profile: repo-review

Profile for broad repository review, release readiness, and evidence audits.

## Purpose

Review repository health with semantic navigation, token budgeting, security checks, and compact evidence.

## Active Tools

- Serena for repository structure, symbols, references, and targeted review.
- Repomix token-count tree and compressed context when the review is broad enough to justify it.
- Skill Security Auditor for skills, profiles, installer config, and top-level policy files.
- Context7 on demand for dependency/API/framework documentation.

## Optional Tools

- Semgrep CE for static security checks when relevant.
- Gitleaks for secret scanning before commits/sharing.
- Knip for unused files/dependencies/exports review.

## Inactive Tools

- Context7 MCP remains off unless explicitly requested.
- Browser/GitHub/random marketplace MCP servers remain off by default.
- Mutation testing remains manual-only.

## Expand Context When

- A claim lacks evidence.
- A report references files that need direct inspection.
- A repo-wide audit requires token-budgeted context.

## Summarize When

- Using Repomix or security scanners.
- Reports contain many findings.
- Logs are long, flaky, or partially blocked.

## Context7 Rule

Use Context7 for library/framework/cloud/tool docs that affect review conclusions. If the library ID is known, query docs directly.

## Serena Rule

Use Serena for semantic review and targeted references before reading large files in full.

## Repomix Rule

Allowed commands:

```bash
npx repomix@latest --token-count-tree 1000
npx repomix@latest --compress
npx repomix@latest --token-budget <number>
```

Commit only compact summaries under `reports/tool-evidence/`; raw `repomix-output.*` remains ignored.

## Cleanup Behavior

- Inventory before cleanup.
- Do not delete final evidence reports.
- Quarantine uncertain local Pi files into backup.
- Do not remove source/provenance snapshots unless there is an approved replacement.

## Security Boundary

- Defensive review only.
- Do not print secrets or private configs.
- Do not force-push or rewrite releases/tags.

## Final Answer Discipline

List findings with evidence, severity, affected files, commands run, and remaining risks. Avoid dumping full logs.
