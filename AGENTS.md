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
- Generate compressed repo context: `repomix --compress`
- Run local security scan: `semgrep scan --config auto --metrics=off`

## Review Output
When finishing a task, report:
- Files changed
- Commands run
- Tests/checks passed or failed
- Security scan result if relevant
- Any manual follow-up needed
