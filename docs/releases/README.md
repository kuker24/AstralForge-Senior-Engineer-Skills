# Release Documentation

This directory stores release drafts, readiness checklists, and release-process notes for AstralForge Senior Engineer Skills.

## Release Principles

- Do not publish, tag, or push a release unless explicitly requested by the maintainer.
- Do not claim a release is ready until local checks pass and GitHub-hosted CI/security/installer workflows are green.
- Do not hide known STUB/BROKEN/NEEDS_REVIEW skill audit results.
- Do not include secrets, tokens, private config, large local reports, or build artifacts in release commits.
- Keep StrykerJS mutation testing manual-only.
- Keep release notes evidence-linked rather than claim-based.

## Release Readiness States

| State | Meaning |
|-------|---------|
| Draft | Release notes/checklist exist, but release is not ready to publish. |
| Local-ready | Required local checks pass, but remote CI may still be pending. |
| CI-ready | GitHub-hosted CI/security/installer workflows are green for the release commit. |
| Publish-ready | CI-ready plus maintainer approval, final version confirmation, and tag/release plan. |
| Published | Tag and GitHub release are created by explicit maintainer request. |

## Standard Local Checks

```bash
npm run typecheck
npm run test:unit
npm run test:coverage
npm run verify:skills
pre-commit run --all-files
```

Security/release checks:

```bash
semgrep scan --config p/default --metrics=off
osv-scanner scan source -r . --format json --output-file osv-results.json
gitleaks git --redact --report-format json --report-path gitleaks-report.json .
gitleaks dir --redact --report-format json --report-path gitleaks-dir-report.json .
npx knip
```

Installer release checks should use sandbox paths only:

```bash
bash install.sh --dry-run --target-dir "$(mktemp -d)/pi-skills"
bash install-global.sh --dry-run --home "$(mktemp -d)/home"
bash installer/install-pi-linux.sh --dry-run --pi-home "$(mktemp -d)/pi-home" --skip-pi-check
```

## Drafts

- [`v3.1.0-draft.md`](v3.1.0-draft.md) — current v3.1.0 release draft.
