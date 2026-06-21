# Contributing to AstralForge Senior Engineer Skills

Thank you for helping improve AstralForge Senior Engineer Skills. This repository is a local-first AI engineering skills package, not a hosted service. Contributions should improve evidence, portability, safety, documentation, or skill quality without hiding known gaps.

## Ground Rules

- Do not commit secrets, API keys, tokens, `.env` files, local credentials, generated reports with private data, or build artifacts.
- Do not force-push shared branches.
- Do not claim a skill is `Verified`, `Supported`, or `Done` without evidence in `reports/` or CI output.
- Do not hide stub, broken, duplicate, or incomplete skills. Report them and fix them transparently.
- Do not delete or move skills unless the PR explains the reason and migration impact.
- Do not run Stryker mutation testing unless explicitly requested by a maintainer.
- Keep changes small and reviewable.

## Repository Reality Check

Before proposing a change, read:

- [`README.md`](README.md) — current status and verification definitions.
- [`SKILLS_MANIFEST.md`](SKILLS_MANIFEST.md) — source skill list.
- [`reports/skill-audit-summary.md`](reports/skill-audit-summary.md) — substantive skill audit summary.
- [`reports/tool-evidence/README.md`](reports/tool-evidence/README.md) — latest local tool evidence.
- [`ARCHITECTURE.md`](ARCHITECTURE.md) — package architecture and stack boundaries.

Current source count is 83 skill folders. The substantive audit is intentionally stricter than folder existence and currently distinguishes PASS/STUB/BROKEN items.

## Local Setup

This repository uses npm because `package-lock.json` is present.

```bash
npm ci
```

If you are only editing Markdown, shell scripts, or skill files, you may not need to install all tooling, but PRs should still explain which checks were run.

## Required Checks Before a PR

Run the smallest relevant checks first, then expand as needed.

Fast baseline:

```bash
npm run typecheck
npm run test:unit
npm run verify:skills
pre-commit run --all-files
```

Coverage evidence:

```bash
npm run test:coverage
```

Security/dependency checks for security-sensitive or release changes:

```bash
semgrep scan --config p/default --metrics=off
osv-scanner scan source -r . --format json --output-file osv-results.json
gitleaks dir --redact --report-format json --report-path gitleaks-dir-report.json .
```

Installer changes should also run sandbox checks, never real-home CI installs:

```bash
bash install.sh --dry-run --target-dir "$(mktemp -d)/pi-skills"
bash install-global.sh --dry-run --home "$(mktemp -d)/home"
bash installer/install-pi-linux.sh --dry-run --pi-home "$(mktemp -d)/pi-home" --skip-pi-check
```

## Skill Contribution Checklist

When adding or improving a skill:

1. Create or update `skills/<skill-name>/SKILL.md`.
2. Include a clear YAML frontmatter `name` and `description`.
3. Add enough substantive instructions that the skill is not a stub.
4. Keep provider-specific guidance honest and cite local references when present.
5. Avoid hard-coded secrets, account IDs, personal paths, or private URLs.
6. Run `npm run verify:skills`.
7. If changing skill quality claims, update the relevant reports or explain why they remain unchanged.

## Documentation Contribution Checklist

When changing docs:

- Link to evidence files instead of making broad claims.
- Keep verification language precise: `Verified`, `Supported`, `Manual only`, `Needs review`, or `Unverified`.
- Update `CHANGELOG.md` under `Unreleased`.
- Add or update a report under `reports/` when the phase produces evidence.

## PR Expectations

A PR should include:

- What changed.
- Why it changed.
- Files changed.
- Commands run and results.
- Security implications, if any.
- Whether CI is expected to pass.
- Any follow-up work or known limitations.

Use [`.github/PULL_REQUEST_TEMPLATE.md`](.github/PULL_REQUEST_TEMPLATE.md) for the expected format.

## Reports and Generated Artifacts

Do not commit large generated outputs unless they are intentionally compact evidence. Keep these local/ignored:

- `coverage/`
- `playwright-report/`
- `test-results/`
- `repomix-output.*`
- `semgrep-results.json`
- `osv-results.json`
- `gitleaks-report.json`
- `gitleaks-dir-report.json`
- `mutation-report/`
- `.stryker-tmp/`

Compact evidence under `reports/` is acceptable when it is useful for review and contains no secrets.

## Commit Style

Use concise conventional-style messages where practical:

- `docs: update verification evidence`
- `test: add skill manifest regression coverage`
- `ci: add installer matrix checks`
- `fix: harden installer sandbox paths`

## Maintainer Review Notes

Maintainers should verify that:

- Claims match evidence.
- Generated/private outputs are not staged.
- Security-sensitive changes have local scan evidence.
- Installer tests use sandbox targets.
- Stryker was not run unless explicitly requested.
