# Push and GitHub Actions Verification Runbook

Status: local-only runbook
Date: 2026-06-22

This runbook describes how to move a local-ready release draft toward CI-ready status **after** a maintainer explicitly approves pushing commits. It is read-only until the maintainer asks for a push.

## Safety Rules

- Do not push unless the maintainer explicitly requests it.
- Do not tag or publish a GitHub Release unless the maintainer explicitly requests it.
- Do not force-push.
- Do not run StrykerJS unless explicitly requested.
- Do not upload secrets, local scan reports, `.env` files, private config, or large generated outputs.
- Do not call the release CI-ready until GitHub Actions are green for the pushed commit.

## Pre-Push Local Checks

Run from repository root:

```bash
npm run typecheck
npm run test:unit
npm run test:coverage
npm run verify:skills
pre-commit run --all-files
```

Optional release/security checks before requesting publication:

```bash
semgrep scan --config p/default --metrics=off
osv-scanner scan source -r . --format json --output-file osv-results.json
gitleaks git --redact --report-format json --report-path gitleaks-report.json .
gitleaks dir --redact --report-format json --report-path gitleaks-dir-report.json .
npx knip
```

Keep generated report files local unless they are intentionally compact evidence under `reports/`.

## Push Step

Only after maintainer approval:

```bash
git status --short
git log --oneline origin/main..HEAD
git push origin main
```

Do not use `--force` or `--force-with-lease` for this release flow unless a maintainer explicitly requests a different branch strategy.

## CI Verification Step

After pushing, check the workflows for the exact pushed commit:

```bash
npm run release:check-actions -- \
  --repo kuker24/AstralForge-Senior-Engineer-Skills \
  --branch main \
  --sha "$(git rev-parse HEAD)" \
  --watch \
  --timeout 1800
```

The script is read-only and verifies these workflow files by default:

- `ci.yml`
- `security.yml`
- `installers.yml`

Dry-run the script without GitHub API calls:

```bash
npm run release:check-actions -- --dry-run
```

## Interpreting Results

| Result | Meaning | Next Step |
|--------|---------|-----------|
| Exit `0` | All required workflows passed for the target SHA. | Mark the release draft CI-ready. |
| Exit `1` | A workflow completed unsuccessfully. | Inspect logs, patch, rerun local checks, commit fix. |
| Exit `2` | Workflow run missing/pending or watch timeout. | Wait or inspect GitHub Actions manually. |
| Exit `3` | GitHub API/query/evaluation problem. | Check `gh` auth/network/repo permissions. |
| Exit `127` | `gh` CLI missing. | Install/configure `gh` or use GitHub web UI manually. |

## Manual GitHub CLI Fallback

```bash
gh run list --repo kuker24/AstralForge-Senior-Engineer-Skills --branch main --limit 20
gh run view --repo kuker24/AstralForge-Senior-Engineer-Skills <RUN_ID> --log-failed
```

Do not paste full logs into chat. Summarize counts, top severity, affected files, and next patches.

## Release Publication Gate

A release can move from CI-ready to publish-ready only when:

- Maintainer approves publication.
- Version bump/tag decision is explicit.
- `package.json` version is intentionally updated if publishing `v3.1.0`.
- GitHub CI, Security, and Installers workflows are green for the release commit.
- Release notes still disclose known limitations and skill audit gaps.

## Current v3.1.0 Draft Status

As of this runbook creation:

- Local-ready: yes.
- Pushed: no.
- GitHub-hosted CI status: pending.
- Tag/release: not created.
- Current skill audit is 83 PASS / 0 STUB / 0 BROKEN / 0 NEEDS_REVIEW.
