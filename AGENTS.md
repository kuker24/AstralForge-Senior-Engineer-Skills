# AGENTS.md

## Project Rules
- Work carefully and make small, reviewable changes.
- Do not delete files unless explicitly requested.
- Do not commit secrets, tokens, API keys, `.env`, build artifacts, or private data.
- Prefer reading existing patterns before adding new architecture.
- Keep changes minimal and aligned with the current project structure.

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

## Review Output
When finishing a task, report:
- Files changed
- Commands run
- Tests/checks passed or failed
- Security scan result if relevant
- Any manual follow-up needed
