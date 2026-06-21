# Push and CI Verification Readiness Report

Date: 2026-06-22
Phase: 11 — push and GitHub Actions verification readiness

## Scope

This phase adds a read-only verification script and runbook for checking GitHub Actions after a future maintainer-approved push. It does not push, tag, publish, force-push, or run StrykerJS.

## Added/Updated Files

| File | Purpose |
|------|---------|
| `scripts/check-github-actions.sh` | Read-only `gh` CLI workflow verifier for required GitHub Actions workflows. |
| `docs/releases/push-ci-verification.md` | Step-by-step runbook for pre-push checks, push approval, CI verification, and publication gate. |
| `package.json` | Adds `npm run release:check-actions`. |
| `tests/project-config.test.ts` | Guards the release verification npm script and release docs presence. |
| `docs/releases/README.md` | Links the push/CI verification runbook. |
| `docs/releases/v3.1.0-draft.md` | Links the runbook as the next CI-readiness step. |
| `reports/release-readiness-v3.1.0.md` | Adds the new runbook/script evidence to release readiness. |

## Script Behavior

`scripts/check-github-actions.sh` is intentionally read-only:

- It uses `gh run list` to inspect workflow runs.
- It defaults to checking `ci.yml`, `security.yml`, and `installers.yml`.
- It matches runs by exact commit SHA.
- It supports `--watch` for polling until success/failure/timeout.
- It supports `--dry-run` for local validation without GitHub API calls.
- It exits nonzero when workflows are missing, pending, failed, or not queryable.

## Validation Evidence

| Command | Status | Evidence |
|---------|--------|----------|
| `bash -n scripts/check-github-actions.sh` | PASS | `/tmp/astralforge-phase11-script-check.log` |
| `npm run release:check-actions -- --dry-run` | PASS | `/tmp/astralforge-phase11-dry-run.log` |
| Release docs link/presence checks | PASS | `/tmp/astralforge-phase11-doc-check.log` |
| `npm run typecheck` | PASS | `/tmp/astralforge-phase11-typecheck.log` |
| `npm run test:unit` | PASS | `/tmp/astralforge-phase11-test-unit.log` |
| `npm run verify:skills` | PASS | `/tmp/astralforge-phase11-verify-skills.log` |
| `pre-commit run --all-files` | PASS | `/tmp/astralforge-phase11-precommit.log` |

## Current Remote Status

- Latest local commits remain unpushed.
- GitHub-hosted workflow status remains pending until push.
- This phase does not change package version or release publication status.

## Recommendation

Use this script and runbook only after the maintainer explicitly approves pushing the local hardening commits. Until then, v3.1.0 remains draft/local-ready, not CI-ready or publish-ready.
