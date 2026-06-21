# Contribution Readiness Report

Date: 2026-06-22
Phase: 9 — transparency and contribution docs

## Scope

This phase adds contributor-facing process documents and GitHub templates so future changes can be reviewed against the same evidence-based standards used by the hardening roadmap.

## Added Files

| File | Purpose |
|------|---------|
| `CONTRIBUTING.md` | Contribution rules, local setup, checks, skill checklist, documentation checklist, artifact policy, and review expectations. |
| `SECURITY.md` | Security policy, supported scope, reporting guidance, local security checks, and secrets handling. |
| `CODE_OF_CONDUCT.md` | Minimal conduct expectations and reporting guidance. |
| `.github/PULL_REQUEST_TEMPLATE.md` | PR checklist for evidence, claim changes, skill changes, and security/privacy checks. |
| `.github/ISSUE_TEMPLATE/config.yml` | Disables blank issues and points users to security advisory/evidence docs. |
| `.github/ISSUE_TEMPLATE/bug_report.yml` | Structured bug report form with safety confirmation. |
| `.github/ISSUE_TEMPLATE/skill_audit.yml` | Structured form for stub/broken/needs-review skill findings. |
| `.github/ISSUE_TEMPLATE/feature_request.yml` | Structured feature request form with evidence and risk fields. |

## Transparency Rules Captured

- Do not claim `Verified`, `Supported`, or `Done` without evidence.
- Do not hide stub, broken, duplicate, or incomplete skills.
- Do not delete or move skills without explicit explanation and migration impact.
- Keep generated reports and large artifacts out of commits unless compact and intentional.
- Keep StrykerJS manual-only.
- Keep installer CI checks sandboxed instead of writing to real home directories.
- Do not commit secrets, credentials, `.env` values, or private data.

## Evidence Links

The contributor docs point reviewers to:

- `README.md`
- `SKILLS_MANIFEST.md`
- `ARCHITECTURE.md`
- `reports/evidence-inventory.md`
- `reports/skill-audit-summary.md`
- `reports/tool-evidence/README.md`
- `reports/security-ci-setup-evidence.md`

## Validation Evidence

Commands run for this phase:

| Command | Status | Evidence |
|---------|--------|----------|
| Markdown/template presence checks | PASS | `/tmp/astralforge-phase9-template-validation.log` |
| `node` YAML parse for `.github/ISSUE_TEMPLATE/*.yml` using the local `yaml` module | PASS | `/tmp/astralforge-phase9-yaml-node.log` |
| Conservative issue-form structure check | PASS | `/tmp/astralforge-phase9-issue-form-structure.log` |
| `npm run typecheck` | PASS | `/tmp/astralforge-phase9-typecheck.log` |
| `npm run test:unit` | PASS | `/tmp/astralforge-phase9-test-unit.log` |
| `npm run verify:skills` | PASS | `/tmp/astralforge-phase9-verify-skills.log` |
| `pre-commit run --all-files` | PASS | `/tmp/astralforge-phase9-precommit.log` |

Notes:

- Ruby and PyYAML were unavailable locally, so YAML validation used the Node `yaml` module already available in the dependency tree.
- The issue templates are intentionally simple GitHub Issue Forms YAML with no anchors or complex syntax.

## Known Limitations

- These templates improve review discipline but cannot enforce reviewer behavior by themselves.
- Security reporting uses GitHub private advisories when available; repository settings must enable/allow advisories on GitHub.
- The project still has known non-PASS skill audit items. These docs make those gaps visible rather than claiming they are solved.
