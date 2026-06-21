# ADR-0001: Local Quality Gates for AI-Assisted Development

## Status
Accepted

## Context
This project uses AI-assisted coding. To reduce regressions, security mistakes, dependency risk, and accidental secret leaks, the project needs local quality gates that do not require login or cloud upload.

## Decision
Use local tools for quality checks:
- Vitest for unit tests and coverage
- TypeScript typecheck for type safety
- pre-commit for lightweight commit-time checks
- Semgrep for static security scanning
- OSV-Scanner for dependency vulnerabilities
- Gitleaks for secret scanning
- Playwright for browser/E2E testing
- Knip for unused files/dependencies/exports
- Repomix for review packaging

StrykerJS mutation testing is available only as a manual command and must not run automatically.

## Consequences
The project gets stronger safety checks before commit and review. Some checks may take time, so heavy scans remain manual or on-demand.

## Alternatives Considered
- Run all tools in pre-commit: rejected because heavy scans would slow normal development.
- Use cloud dashboards: rejected because this project requires local, no-login quality gates.
- Skip mutation testing: rejected because manual StrykerJS remains useful for advanced test-quality validation.
