# Evidence Inventory

Date: 2026-06-22
Phase: 1 — evidence inventory without upgrading README support claims

This inventory records current repository claims and whether there is committed or freshly-run local evidence for each claim. It does **not** upgrade README claims; it identifies what is already proven and what still needs CI-backed or deeper audit evidence.

## Baseline Evidence From This Phase

| Command | Status | Evidence File |
|---------|--------|---------------|
| `pwd && git status --short && git branch --show-current && git remote -v && git log --oneline -5` | PASS | `/tmp/astralforge-phase1-baseline-env.log` |
| `node --version && npm --version` | PASS | `/tmp/astralforge-phase1-baseline-env.log` |
| `npm run typecheck` | PASS | `/tmp/astralforge-phase1-baseline-typecheck.log` |
| `npm run test:unit` | PASS, 8 tests | `/tmp/astralforge-phase1-baseline-test-unit.log` |
| `npm run verify:skills` | PASS, 83 source skills | `/tmp/astralforge-phase1-baseline-verify-skills.log` |
| `pre-commit run --all-files` | PASS | `/tmp/astralforge-phase1-baseline-precommit.log` |

> The `/tmp` logs are local working evidence and are not intended for commit. Future phases should add durable, redacted evidence under `reports/` and CI evidence via GitHub Actions.

## Tooling Claims

| Tool | README Status | Command Expected | Evidence Exists | Evidence File | Verdict |
|------|---------------|------------------|-----------------|---------------|---------|
| OMNI | Supported | `omni stats --detail` / terminal distillation | Partial | `AGENTS.md`, `scripts/ai-quality-checks.sh`, `scripts/ai-senior-checks.sh` | Configured locally; no committed execution evidence yet |
| Context7 Pi | Supported | `pi install npm:@upstash/context7-pi` / docs lookup | Partial | `README.md`, `AGENTS.md` | Configuration claim only; no committed run evidence |
| Serena MCP | Supported | Serena CLI/MCP setup commands | Partial | `README.md`, `AGENTS.md` | Configuration claim only; no committed run evidence |
| Semgrep CE | Supported | `semgrep scan --config p/default --metrics=off --json --json-output=semgrep-results.json` | Partial | `scripts/ai-quality-checks.sh`, `scripts/ai-senior-checks.sh`, local `semgrep-results.json` ignored by git | Local scan evidence exists, but no committed redacted evidence or CI yet |
| Repomix | Supported | `repomix --compress` | Partial | `repomix.config.json`, `scripts/ai-senior-checks.sh`, local `repomix-output.xml` ignored by git | Configured; output intentionally ignored due size |
| Vitest + Coverage | Supported | `npm run test:unit`, `npm run test:coverage` | Yes | `package.json`, `vitest.config.ts`, `tests/`, `/tmp/astralforge-phase1-baseline-test-unit.log` | Local unit test evidence exists; CI pending |
| TypeScript typecheck | Supported | `npm run typecheck` | Yes | `package.json`, `tsconfig.json`, `/tmp/astralforge-phase1-baseline-typecheck.log` | Local typecheck evidence exists; CI pending |
| pre-commit | Supported | `pre-commit run --all-files` | Yes | `.pre-commit-config.yaml`, `/tmp/astralforge-phase1-baseline-precommit.log` | Local hook evidence exists; CI pending |
| ADR | Supported | Review `docs/adr/` | Yes | `docs/adr/README.md`, `docs/adr/0000-template.md`, `docs/adr/0001-project-quality-gates.md` | Documentation exists |
| Playwright Test | Supported | `npx playwright test --project=chromium` | Partial | `playwright.config.ts`, `e2e/smoke.spec.ts` | Placeholder E2E only; no real app-flow evidence |
| OSV-Scanner | Supported | `osv-scanner scan source -r . --format json --output-file osv-results.json` | Partial | `scripts/ai-quality-checks.sh`, `scripts/ai-senior-checks.sh`, local `osv-results.json` ignored by git | Local scan evidence exists; no committed redacted evidence or CI yet |
| Gitleaks | Supported | `gitleaks dir --redact --report-format json --report-path gitleaks-dir-report.json .` | Partial | `.gitleaks.toml`, `.pre-commit-config.yaml`, local reports ignored by git | Local/pre-commit evidence exists; no committed redacted evidence or CI yet |
| Knip | Supported | `npx knip` | Partial | `package.json`, `knip.json`, `scripts/ai-senior-checks.sh` | Configured; no committed execution evidence yet |
| StrykerJS | Manual only | `npm run mutation` | Yes for setup; not executed | `package.json`, `stryker.config.json`, `AGENTS.md` | Manual-only setup exists; correctly not run |

## Skill Claims

| Claim | Current Value | Evidence Exists | Evidence File | Verdict |
|------|---------------|-----------------|---------------|---------|
| Source skill folders | 83 | Yes | `SKILLS_MANIFEST.md`, `/tmp/astralforge-skills.txt`, `scripts/verify-source-skills.sh` | Verified folder count and frontmatter locally |
| Skills with `SKILL.md` | 83 | Yes | `npm run verify:skills`, `/tmp/astralforge-phase1-baseline-verify-skills.log` | Verified locally |
| Unique frontmatter names | 83 | Yes | `scripts/verify-source-skills.sh`, `SKILLS_MANIFEST.md` | Verified locally |
| Folder name matches frontmatter `name` | 83 | Yes | `scripts/verify-source-skills.sh` | Verified locally |
| `description:` exists | 83 | Yes | `scripts/verify-source-skills.sh` | Verified locally |
| Substantive skill content, non-stub | Not yet audited | No | Planned `scripts/audit-skills.sh` / `reports/skill-audit-summary.md` | Evidence gap |
| `agents/openai.yaml` exists for all skills | Claimed by older completion report | Not fully audited in current verifier | `reports/skill-completion-report.md` | Evidence gap for source-only verifier |
| `references/sources.md` exists for all skills | Claimed by older completion report | Not fully audited in current verifier | `reports/skill-completion-report.md` | Evidence gap for source-only verifier |
| Source links reachable | Claimed broadly in older completion report | No current link-check evidence | None | Evidence gap |

## Installer Claims

| Claim | Evidence Exists | Evidence File | Verdict |
|------|-----------------|---------------|---------|
| Installer package includes 83 skills | Partial | `installer/README.md`, `installer/skills/` count is 83 | Count exists locally; no sandbox installer CI yet |
| Installer includes 26 extensions | Partial | `installer/README.md`, `installer/extensions/` count is 26 | Count exists locally; no installer CI yet |
| Installer includes 3 config files | Partial | `installer/config/` count is 3 | Count exists locally; no schema/behavior CI yet |
| Linux/macOS installer works | Partial | `installer/install-pi-linux.sh`, `install.sh` | Script exists; no sandbox install evidence in this phase |
| Windows installer works | Partial | `installer/install-pi-windows.ps1`, `install.ps1` | Script exists; no Windows CI evidence yet |
| Global install to Pi/OpenCode/Claude/Codex/Agents works | Partial | `install-global.sh`, `reports/global-installation-report.md` | Historical report exists; no current CI/sandbox evidence |
| `verify.sh` install verification works | Partial | `verify.sh` | Script exists; this phase used `npm run verify:skills`, not install verification |
| Dry-run safety | Partial | README documents `./install.sh --dry-run` | Needs installer audit and CI matrix |

## Gaps Found

- No GitHub Actions CI evidence exists yet for typecheck, tests, coverage, skill verification, Knip, or pre-commit.
- No dedicated security CI evidence exists yet for Semgrep, OSV-Scanner, or Gitleaks.
- Tooling claims are mostly `Supported`, but many only have local scripts/config and ignored local reports, not committed redacted evidence.
- Coverage currently verifies test command execution, but the repo has no meaningful source coverage threshold evidence yet.
- Playwright is configured with a skipped placeholder, so it should remain a tooling capability claim, not a real E2E verification claim.
- Skill verifier proves frontmatter integrity, but not substantive quality, source link health, non-stub status, or `agents/openai.yaml` / `references/sources.md` completeness for every skill.
- Installer claims have file/count evidence but no sandboxed install verification or CI matrix evidence.
- README currently uses broad `Supported` wording; later phases should distinguish `Verified`, `Supported`, `Manual only`, `Needs review`, and `Unverified` after CI and skill audit evidence exists.

## Phase 1 Verdict

Phase 1 evidence inventory is complete. No README support claims were upgraded in this phase.
