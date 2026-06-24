# Changelog

All notable changes to this project will be documented in this file.

---

## Unreleased

- No unreleased changes.

---

## [3.0.0] - 2026-06-24

### Added
- Rebranded package to **AstralForge Senior Engineer Skills**.
- Added 83 retained source skill folders with `SKILL.md`, `agents/openai.yaml`, and `references/sources.md` support files.
- Added source-only skill verification via `scripts/verify-source-skills.sh` and `npm run verify:skills`.
- Added substantive skill audit via `scripts/audit-skills.sh` and `npm run audit:skills`.
- Added GitHub Actions CI pipeline with jobs for typecheck, coverage, Playwright E2E, security scans, dead-code report, skill audit, and pre-commit.
- Added local QA/security tooling: TypeScript, Vitest, Playwright, Knip, Semgrep CE, OSV-Scanner, Gitleaks, pre-commit, and Repomix evidence.
- Added installer and global verification scripts for Pi/OpenCode/Claude/Codex/Agents skill locations.
- Added Akses Satu Api OpenAI-compatible provider configuration, Pi extension, launcher fallback, documentation, and safe manual smoke-test script.
- Added contribution, security, conduct, issue/PR templates, reports index, release runbooks, and architecture/release readiness docs.

### Changed
- Updated package metadata to `astralforge-senior-engineer-skills` version `3.0.0`.
- Updated README claims to distinguish evidence-backed local verification from external certification.
- Updated `installer/config/models.json` and `installer/config/settings.json` for Akses Satu Api model availability.
- Updated all previously stub-classified skills with substantive workflows, output expectations, validation gates, and safety notes.
- Updated `template-skill` into a real skill-template authoring skill while keeping the retained source count at 83.
- Synchronized `skills/` into `installer/skills/` so installer payload matches the source skill set.

### Fixed
- Fixed missing `agents/openai.yaml` files across retained source skills.
- Fixed missing `references/sources.md` files across retained source skills.
- Fixed broken reference URLs for ADR tooling, microservices references, Drizzle PostgreSQL, OpenXML docs, Kiro docs, MCP docs, database migration docs, and AI/ML docs.
- Fixed CI workflow issues around OSV Scanner action resolution and Gitleaks history depth.
- Fixed the GitHub Actions verification watcher so pending workflows poll instead of exiting immediately.

### Security
- Custom provider credentials are read from environment variables only; no provider API keys are hardcoded.
- `.env` and `.env.*` remain ignored; `.env.example` contains placeholders only.
- Gitleaks reports show zero findings for committed evidence.
- Latest CI security job passed on GitHub Actions.

### Verification
- Retained source skills: 83.
- Verified by substantive audit: 83 PASS / 0 NEEDS_REVIEW / 0 STUB / 0 BROKEN.
- In progress skill count: 0.
- Latest green CI run for this release preparation: https://github.com/kuker24/AstralForge-Senior-Engineer-Skills/actions/runs/28117522977
- Evidence files: `reports/skill-audit-summary.md`, `reports/INDEX.md`, and `reports/ci-first-run.md`.

### Known Limitations
- Local OSV-Scanner evidence previously timed out against the OSV API; the GitHub Actions security job passed.
- Playwright E2E remains a skipped package smoke test because this repository is not a runnable web application.
- StrykerJS mutation testing is manual-only and was not run for this release.
- The release verifies the local audit criteria; it is not an external certification of every referenced third-party source.

---

## [2.4.0] - 2026-06-21

### Added
- Added senior local quality gates for AI-assisted development:
  - Vitest unit test runner and V8 coverage.
  - Strict TypeScript checking via `tsconfig.json` and `npm run typecheck`.
  - Lightweight local pre-commit hooks for Gitleaks, typecheck, and unit tests.
  - ADR documentation folder with template and local quality-gates ADR.
  - StrykerJS mutation testing setup as manual-only.
  - `scripts/ai-senior-checks.sh` for local on-demand senior quality checks.

### Updated
- Updated `AGENTS.md` with when to use fast checks, security checks, browser/E2E, ADRs, and manual-only mutation testing.
- Updated `.gitignore` for coverage and mutation outputs.
- Updated package scripts for unit tests, coverage, typecheck, senior quality checks, and manual mutation testing.

### Notes
- StrykerJS is installed but not run automatically and was not executed during setup.
- No login, account creation, API key, cloud upload, or OMNI configuration changes were used.
- Existing Context7 Pi, Serena, Semgrep, Repomix, Playwright, OSV-Scanner, Gitleaks, and Knip setup remains intact.

---

## [2.3.0] - 2026-06-21

### Added
- Added local/no-login QA and security tooling support:
  - Playwright Test for browser/E2E testing.
  - OSV-Scanner for local dependency vulnerability scanning.
  - Gitleaks for local secret scanning.
  - Knip for JS/TS unused files/dependencies/exports checks.
- Added `package.json`/`package-lock.json` with local dev tooling scripts and dependencies for portable Playwright/Knip usage.
- Added `playwright.config.ts` and skipped placeholder smoke test in `e2e/smoke.spec.ts` because this repository is not a runnable web app.
- Added `knip.json` repository-aware configuration.
- Added `.gitleaks.toml` to keep default Gitleaks rules while excluding local ignored reference/output paths.
- Added `scripts/ai-quality-checks.sh` to run OMNI stats, Semgrep, OSV-Scanner, Gitleaks, Knip, and Playwright checks locally.

### Updated
- Updated `.gitignore` to ignore local reports and tool output:
  - `osv-results.json`
  - `gitleaks-report.json`
  - `gitleaks-dir-report.json`
  - `playwright-report/`
  - `test-results/`
  - `.knip-cache/`
- Updated `AGENTS.md` and `README.md` with local QA/security tool usage.

### Notes
- No login, account creation, API key, TestSprite, or cloud upload was used.
- OMNI, Context7 Pi, Serena, Semgrep, and Repomix existing integrations remain unchanged.

---

## [2.2.0] - 2026-06-21

### Added
- Added `AGENTS.md` with AI agent project rules, setup guidance, Context7/Serena/Semgrep/Repomix usage notes, and review-output expectations.
- Added `scripts/ai-checks.sh` helper for local OMNI stats, Semgrep CE scan, and Repomix context generation.
- Added `repomix.config.json` with safe ignore patterns and compressed XML output configuration.

### Updated
- Updated `.gitignore` to ignore local AI-tool outputs:
  - `semgrep-results.json`
  - `repomix-output.*`
- Documented AI agent tooling in `README.md`.

### Notes
- Context7 Pi is intended to run without API key/login using Pi package install.
- Serena MCP setup is supported for Claude Code and Codex via Serena's official setup commands.
- Semgrep CE is local/no-login only; use `p/default` with `--metrics=off` if `--config auto` rejects metrics-off mode.
- OMNI remains active and unchanged.

---

## [2.1.0] - 2026-05-29

### Updated
- **Pi Installer v1.3.0**
  - Restored `plan-mode` extension
  - Updated extensions count to 26
  - Updated `settings.json` to version 0.77.0
  - Added new models: `gitlawb-opengateway/mimo-v2.5`, `opencode-go/mimo-v2.5-pro`, `xiaomi-token-plan-sgp/mimo-v2.5`
  - Updated `models.json` with environment variable format for API key (`$OPENGATEWAY_API_KEY`)
  - Updated `README.md` with changelog

### Added
- Complete Pi installer package (`installer/`)
  - `install-pi-linux.sh` - Linux/macOS installer
  - `install-pi-windows.ps1` - Windows installer
  - Configuration files (settings, models, presets)
  - 26 extensions (including plan-mode)
  - 4 custom prompts
  - 4 agent definitions
  - 83 skills

### Documentation
- Updated main `README.md` with installer section
- Added `installer/README.md` with detailed documentation
- Added `reports/global-installation-report.md`

---

## [2.0.0] - 2026-05-24

### Added
- **20 new skills (P1+P2+P3)**
  - P1 (8): nodejs-express, docker-kubernetes, typescript, tailwind-css, nextjs, prisma-drizzle, authentication, aws-cloud
  - P2 (7): mongodb, redis, websocket, graphql-impl, message-queue, cicd-pipeline, monitoring-logging
  - P3 (5): vuejs-svelte, react-native-flutter, microservices, ai-ml-integration, web3-blockchain

- **8 new full-* skills**
  - full-api-design, full-database-migration, full-performance-audit
  - full-dependency-audit, full-architecture-review, full-data-pipeline
  - full-infrastructure-as-code, full-api-testing

### Updated
- **13 existing full-* skills**
  - Added `references/sources.md` to all
  - Updated content and documentation

### Documentation
- `SKILLS_MANIFEST.md` - Complete skill listing
- `MISSING_SKILLS_CHECKLIST.md` - Skill tracking
- `reports/skill-completion-report.md` - Completion report
- `reports/source-skill-index.md` - Source index

---

## [1.0.0] - 2026-05-24

### Added
- Initial release with 55 skills
- Installation scripts (Linux/Windows)
- Verification scripts
- Basic documentation

---

## Version Numbering

This project uses [Semantic Versioning](https://semver.org/):
- **MAJOR**: Incompatible API changes
- **MINOR**: New functionality in a backwards compatible manner
- **PATCH**: Backwards compatible bug fixes

---

## Release Process

1. Update version in `README.md`
2. Update `CHANGELOG.md` with changes
3. Run `./verify.sh` to ensure all skills are valid
4. Run `./install-global.sh` to test installation
5. Create git tag with version number
6. Push to repository
