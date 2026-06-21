# v3.1.0 Release Readiness Report

Date: 2026-06-22
Phase: 10 — v3.1.0 release draft and readiness checklist

## Readiness Summary

| Dimension | Status | Notes |
|-----------|--------|-------|
| Release notes | Drafted | `docs/releases/v3.1.0-draft.md` |
| Release process docs | Drafted | `docs/releases/README.md` |
| Local baseline checks | PASS | Phase 10 final validation passed locally. |
| Security evidence | Available from Phase 8 | Semgrep/OSV/Gitleaks had 0 findings in `reports/tool-evidence/`. |
| Installer evidence | Available from Phase 7 | Local Linux shell sandbox checks passed; Windows covered by CI workflow. |
| GitHub-hosted CI | Pending | Local commits have not been pushed in this phase. |
| GitHub-hosted security workflow | Pending | Requires push and Actions run. |
| GitHub-hosted installer workflow | Pending | Requires push and Actions run. |
| Version bump | Not performed | `package.json` remains `3.0.0`; v3.1.0 is draft-only. |
| Tag/release publish | Not performed | Requires explicit maintainer request. |

## Commits Planned for v3.1.0 Draft Scope

These local commits are currently ahead of `origin/main` and form the draft v3.1.0 hardening scope:

```txt
c907366 docs: add contribution and issue templates
2afa9db docs: add dogfooding evidence for local tools
3f598af ci: add installer verification workflow
9baa4c8 docs: document AstralForge architecture and stack boundaries
c9f4249 docs: make verification status evidence-based
de915f4 test: add substantive skill audit report
4a23317 ci: add security scanning workflow
38c0314 ci: add baseline quality workflow
0b05d7c docs: add evidence inventory for AstralForge claims
```

## Evidence Inventory for Release Review

| Evidence | File |
|----------|------|
| Claim/evidence inventory | `reports/evidence-inventory.md` |
| Baseline CI setup | `reports/ci-setup-evidence.md` |
| Security CI setup | `reports/security-ci-setup-evidence.md` |
| Installer audit | `reports/installer-audit.md` |
| Substantive skill audit summary | `reports/skill-audit-summary.md` |
| Substantive skill audit CSV | `reports/skill-audit-results.csv` |
| Local tool dogfooding evidence | `reports/tool-evidence/README.md` |
| Contribution readiness | `reports/contribution-readiness.md` |
| Architecture and stack boundaries | `ARCHITECTURE.md` |

## Validation Evidence

Final Phase 10 validation commands:

| Command | Status | Evidence |
|---------|--------|----------|
| `npm run typecheck` | PASS | `/tmp/astralforge-phase10-final-typecheck.log` |
| `npm run test:unit` | PASS | `/tmp/astralforge-phase10-final-test-unit.log` |
| `npm run test:coverage` | PASS | `/tmp/astralforge-phase10-final-test-coverage.log` |
| `npm run verify:skills` | PASS | `/tmp/astralforge-phase10-final-verify-skills.log` |
| Release docs presence/link checks | PASS | `/tmp/astralforge-phase10-release-doc-check.log` |
| `pre-commit run --all-files` | PASS | `/tmp/astralforge-phase10-final-precommit.log` |

## Release Blockers Before Publishing

- Maintainer has not requested push, tag, or GitHub release publication.
- Local commits are still unpushed relative to `origin/main`.
- GitHub-hosted CI/security/installer workflows have not run for the latest local commits.
- `package.json` still says `3.0.0`; a final version-bump decision is required before an actual `v3.1.0` tag.
- Known skill audit gaps remain visible: 25 PASS / 12 STUB / 46 BROKEN / 0 NEEDS_REVIEW.

## Non-Goals for This Phase

- No push to GitHub.
- No tag creation.
- No GitHub Release publication.
- No Stryker mutation run.
- No claim that all 83 skills are fully verified.

## Recommendation

Treat v3.1.0 as **Draft / local-ready**. It should become **CI-ready** only after the maintainer explicitly requests a push and all GitHub Actions workflows pass on the remote commit.
