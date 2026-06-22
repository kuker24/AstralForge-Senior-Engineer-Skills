# Skill Audit Summary

Date: 2026-06-22

This report audits source skills for substance and support files. It does not move, delete, or rename any skill.

## Verdict Counts

| Verdict | Count |
|---------|------:|
| PASS | 83 |
| NEEDS_REVIEW | 0 |
| STUB | 0 |
| BROKEN | 0 |
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
| - | - | No non-PASS skills found. |

## README Recommendation

All audited skills passed these criteria; later README updates can truthfully report 83 audited skills.

## Output Files

- CSV: `reports/skill-audit-results.csv`
- Summary: `reports/skill-audit-summary.md`
