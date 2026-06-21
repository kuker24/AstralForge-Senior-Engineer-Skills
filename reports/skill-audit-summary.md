# Skill Audit Summary

Date: 2026-06-22

This report audits source skills for substance and support files. It does not move, delete, or rename any skill.

## Verdict Counts

| Verdict | Count |
|---------|------:|
| PASS | 25 |
| NEEDS_REVIEW | 0 |
| STUB | 12 |
| BROKEN | 46 |
| **Total** | **83** |

## Audit Criteria

- `SKILL.md` exists.
- Frontmatter delimiters are present.
- `name:` and `description:` exist.
- Body has at least 150 substantive words.
- Placeholder/template-only content is flagged.
- `agents/openai.yaml` exists and is non-empty.
- `references/sources.md` exists and is non-empty.
- HTTP links in `references/sources.md` are checked with timeout; 4xx/5xx/timeouts are treated as broken.

## Top Issues (first 20 non-PASS rows)

| Skill | Verdict | Notes |
|-------|---------|-------|
| `algorithmic-art` | BROKEN | missing agents/openai.yaml; missing references/sources.md |
| `api-patterns` | BROKEN | missing agents/openai.yaml; missing references/sources.md |
| `autonomous-skill` | BROKEN | missing agents/openai.yaml; missing references/sources.md |
| `brand-guidelines` | BROKEN | missing agents/openai.yaml; missing references/sources.md |
| `canvas-design` | BROKEN | missing agents/openai.yaml; missing references/sources.md |
| `claude-api` | BROKEN | missing agents/openai.yaml; missing references/sources.md |
| `claude-frontend-design` | BROKEN | missing agents/openai.yaml; missing references/sources.md |
| `claude-skill` | BROKEN | missing agents/openai.yaml; missing references/sources.md |
| `database-design` | BROKEN | missing agents/openai.yaml; missing references/sources.md |
| `deep-research` | BROKEN | missing agents/openai.yaml; missing references/sources.md |
| `deployment-procedures` | BROKEN | missing agents/openai.yaml; missing references/sources.md |
| `docx` | BROKEN | missing agents/openai.yaml; missing references/sources.md |
| `frontend-design` | BROKEN | missing agents/openai.yaml; missing references/sources.md |
| `full-architecture-review` | BROKEN | broken links: https://github.com/architecture-decision-records/adr-tools (404) |
| `full-audit-keamanan` | BROKEN | missing agents/openai.yaml |
| `full-brainstorm` | BROKEN | missing agents/openai.yaml |
| `full-bug-hunter` | BROKEN | missing agents/openai.yaml |
| `full-debug` | BROKEN | missing agents/openai.yaml |
| `full-init` | BROKEN | missing agents/openai.yaml |
| `full-master-plan` | BROKEN | missing agents/openai.yaml |

## README Recommendation

Do not change the README skill count yet. The README can continue to state 83 source skill folders, but later phases should distinguish verified skills from skills needing review if any non-PASS rows remain.

## Output Files

- CSV: `reports/skill-audit-results.csv`
- Summary: `reports/skill-audit-summary.md`
