# Changelog

All notable changes to this project will be documented in this file.

---

## Unreleased

### Added
- Added Akses Satu Api OpenAI-compatible provider configuration.
- Added verified live model list (7 models) and requested configured model list (4 models) to the Akses Satu Api provider, with deduplicated full union of 11 models.
- Added Pi launcher fallback (`scripts/run-pi-akses-satu.sh`) for Akses Satu Api.
- Added Akses Satu Api Pi extension at `extensions/akses-satu-api-provider/` and a mirrored installer copy at `installer/extensions/akses-satu-api-provider/`, both using the native `pi.registerProvider()` API.
- Added Akses Satu Api manual API test script and documentation.
- Added local Pi detection report (`reports/pi-akses-satu-detection.md`) covering Pi version, native provider API availability, env var status, and config locations.
- Added missing `agents/openai.yaml` and `references/sources.md` support files across retained source skills so the substantive audit can validate every skill.

### Changed
- Set Akses Satu Api default model to `glm-4.6` because it is verified through `/v1/chat/completions`.
- Promoted all 4 previously-configured models (`gpt-5.5`, `minimax-m3`, `mimo-v2.5-pro`, `deepseek-v4-pro`) to `AKSES_SATU_VERIFIED_LIVE_MODELS` after live re-test on 2026-06-22 confirmed all 11 union models return HTTP 200 + `object=chat.completion` + valid `content` from `POST /v1/chat/completions`. `AKSES_SATU_CONFIGURED_MODELS` is now empty (kept as an export for forward compatibility).
- Rewrote `scripts/test-akses-satu-api.sh` so the chat-completions and responses sections actually call their respective endpoints and classify results honestly (no PASS for a model-list misroute on `/responses`).
- Updated `installer/config/models.json` to list the full 11-model union with `reasoning`/`contextWindow`/`maxTokens` metadata and `authHeader: true`.
- Updated `installer/config/settings.json` to include all 7 verified-live `akses-satu-api/*` model ids in `enabledModels`, plus the 4 configured-only models.
- Updated `docs/providers/akses-satu-api.md`, `README.md`, and `AGENTS.md` to document the verified live list, configured list, default model, and the three Pi integration paths.
- Extended `tests/akses-satu-api-provider.test.ts` and `tests/installer-scripts.test.ts` to cover the new model union, verified/configured lists, `.env.example` placeholder, executable launcher, fixed test script, and Pi extension.
- Rewrote all previously stub-classified skills with substantive workflows, output expectations, validation gates, and safety notes.
- Fixed broken reference URLs for ADR, microservices, Drizzle PostgreSQL, OpenXML, Kiro, and AI/ML documentation.
- Added `npm run audit:skills`, CI audit enforcement, and Vitest regression tests for support files, manifest counts, README audit counts, and unfinished marker phrases.

### Security
- Akses Satu Api credentials are loaded only from `AKSES_SATU_API_KEY`; no API keys are hardcoded.
- `.env.example` contains only the `sk-sa-REPLACE_ME` placeholder. `.env` and `.env.*` remain gitignored.
- The helper client, the test script, the launcher, and the extension never print `Authorization` headers or the value of the API key.
- Pi v0.79.9 does not honor `OPENAI_BASE_URL` for the built-in `openai` provider; the launcher falls back to the native `akses-satu-api` provider id and documents this limitation explicitly.

### Notes
- No README support claims were upgraded in phase 1.
- CI will be considered verified only after the workflow runs on GitHub Actions.
- Security CI will be considered verified only after the workflow runs on GitHub Actions.
- Current substantive skill audit reports 83 PASS / 0 NEEDS_REVIEW / 0 STUB / 0 BROKEN for the retained source skill set.

---

## 3.0.0 - AstralForge Senior Engineer Skills

### Added
- Rebranded package to AstralForge Senior Engineer Skills.
- Added source-only skill verification via `scripts/verify-source-skills.sh` and `npm run verify:skills`.
- Added meaningful Vitest coverage for skill manifests, project config, and installer scripts.

### Updated
- Updated package metadata to `astralforge-senior-engineer-skills` version `3.0.0`.
- Synchronized skill count documentation to the actual 83 source skills.
- Strengthened senior local quality-gate documentation and scripts for Pi Code / Pi Agent usage.

### Notes
- StrykerJS remains manual-only and must not run unless explicitly requested.
- Reports remain local and gitignored; no login, cloud upload, API key, push, or OMNI configuration change was performed.

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
