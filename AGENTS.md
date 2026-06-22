# AGENTS.md

AstralForge Senior Engineer Skills is a local-first AI engineering skills package with senior-grade QA, security, review, and architecture-decision gates.

## Project Rules
- Work carefully and make small, reviewable changes.
- Do not delete files unless explicitly requested.
- Do not push to GitHub unless the user explicitly asks for it.
- Do not force push.
- Do not commit secrets, tokens, API keys, `.env`, build artifacts, or private data.
- Custom provider credentials must use environment variables; never hardcode provider keys.
- Never print Authorization headers or API key values in logs, tests, snapshots, docs, or reports.
- Prefer reading existing patterns before adding new architecture.
- Keep changes minimal and aligned with the current project structure.

## Akses Satu Api Custom Provider
- Provider id: `akses-satu-api`. Base URL: `https://api.satuakses.top/v1`. Auth: `Authorization: Bearer $AKSES_SATU_API_KEY`.
- Default model: `glm-4.6` (the only model verified through `POST /v1/chat/completions` in this environment).
- Verified live models (all 11 union models, tested 2026-06-22 with `GET /v1/models` + `POST /v1/chat/completions`): `glm-4.6`, `claude-sonnet-4.6`, `cipher`, `idsa-v1.0`, `google-gemma-2-9b-it`, `mimo-v2.5`, `claude-opus-4.8`, `gpt-5.5`, `minimax-m3`, `mimo-v2.5-pro`, `deepseek-v4-pro`.
- Configured (requested, not yet verified) models: none. The `AKSES_SATU_CONFIGURED_MODELS` export is reserved for future user-requested models that are not yet live.
- Use `bash scripts/test-akses-satu-api.sh` for manual smoke test; the script must never print the API key and must classify `/responses` results honestly (no PASS for a model-list misroute).
- Three Pi integration paths: native `pi --provider akses-satu-api` (after installer), `pi -e ./extensions/akses-satu-api-provider`, and `bash scripts/run-pi-akses-satu.sh` (launcher fallback).
- Pi v0.79.9 does NOT honor `OPENAI_BASE_URL` for the built-in `openai` provider; the launcher therefore uses the native `akses-satu-api` provider id.

## Setup Commands
- Detect the package manager from lockfiles before installing dependencies.
- If `package-lock.json` exists, use `npm`.
- If `pnpm-lock.yaml` exists, use `pnpm`.
- If `yarn.lock` exists, use `yarn`.
- If Python project files exist, use the project’s existing virtual environment or create one only when needed.

## Build and Test
- Run the smallest relevant check first.
- Before final answer, run available lint/build/test commands when safe.
- If a command is long/noisy, rely on OMNI output and retrieve full logs only when needed.

## Context and Docs
- Use Context7 for library, SDK, framework, API, CLI, and cloud-service documentation.
- Mention exact library versions when relevant.
- Do not rely on outdated API examples when Context7 can verify current docs.

## Code Navigation
- Use Serena MCP for symbol search, references, function/class overview, and precise edits when available.
- Prefer symbol-aware edits over broad search-and-replace.

## Security Checks
- Use Semgrep CE for local security scanning.
- Do not run cloud login commands.
- Do not upload code, secrets, or scan reports to external dashboards unless explicitly requested.

## Useful Local Commands
- Run AI helper checks: `bash scripts/ai-checks.sh`
- Run full local QA/security checks: `bash scripts/ai-quality-checks.sh`
- Run senior quality gate: `bash scripts/ai-senior-checks.sh`
- Verify source skills: `npm run verify:skills`
- Generate compressed repo context: `repomix --compress`
- Run local security scan: `semgrep scan --config p/default --metrics=off`

## Local QA / Security Tools

Use these local no-login tools when relevant:

- Playwright Test: browser/E2E testing.
  - Run: `npx playwright test`
  - Report: `npx playwright show-report`
  - Prefer Chromium first for speed.

- OSV-Scanner: dependency vulnerability scanning.
  - Run: `osv-scanner scan source -r . --format json --output-file osv-results.json`
  - Keep output local and ignored by git.

- Gitleaks: secret scanning.
  - Run git history scan: `gitleaks git --redact --report-format json --report-path gitleaks-report.json .`
  - Run directory scan: `gitleaks dir --redact --report-format json --report-path gitleaks-dir-report.json .`
  - Never commit secrets or report files.

- Knip: unused files/dependencies/exports for JS/TS projects.
  - Run: `npx knip`
  - Do not delete reported items automatically. Review first.

When finishing coding tasks:
1. Run the smallest relevant build/test first.
2. Use OMNI for long terminal output.
3. Use Context7 for current docs/API.
4. Use Semgrep for static security scan when relevant.
5. Use Playwright for user-flow/browser checks when the app has UI.
6. Use OSV-Scanner for dependency vulnerability checks.
7. Use Gitleaks before commits or sharing code.
8. Use Knip before cleanup/refactor.

## Senior Engineering Quality Gates

Use local no-login quality gates before major commits or reviews.

### Fast checks
- Typecheck: `npm run typecheck`
- Unit test: `npm run test:unit`
- Coverage: `npm run test:coverage`
- Skill manifest verification: `npm run verify:skills`
- Pre-commit: `pre-commit run --all-files`

### Security and dependency checks
- Semgrep: `semgrep scan --config p/default --metrics=off`
- OSV-Scanner: `osv-scanner scan source -r . --format json --output-file osv-results.json`
- Gitleaks: `gitleaks dir --redact --report-format json --report-path gitleaks-dir-report.json .`

### Review and cleanup
- Knip: `npx knip`
- Repomix: `repomix --compress`

### Browser/E2E
- Playwright: `npx playwright test --project=chromium`

### Architecture decisions
Use `docs/adr/` for major architecture/security/database/API/deployment decisions.
Create an ADR before or during large refactors and important design changes.

### Mutation testing
StrykerJS is installed for advanced test-quality validation, but it is manual-only.
Do not run:
- `npm run mutation`
- `npx stryker run`

Run mutation testing only when the user explicitly asks for it.

### Token discipline
- Do not paste full logs into chat.
- Use OMNI for long terminal output.
- Store reports locally.
- Summarize only:
  - count of issues
  - top severity
  - affected files
  - next recommended patches

## Review Output
When finishing a task, report:
- Files changed
- Commands run
- Tests/checks passed or failed
- Security scan result if relevant
- Any manual follow-up needed
