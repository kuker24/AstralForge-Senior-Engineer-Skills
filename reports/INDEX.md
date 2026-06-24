# Reports Index

Date: 2026-06-24

This index classifies every tracked file under `reports/`. `REAL` means the file is an actual tool output or evidence document. `FAILED` means the attempted tool run failed and the captured error is intentionally preserved. No file is classified as `STUB`.

| File | Tool | Generated | Status | Notes |
|------|------|-----------|--------|-------|
| `reports/INDEX.md` | Reports index | 2026-06-24 | REAL | Self-index entry so every tracked report file is classified. |
| `reports/akses-satu-api-provider.md` | Provider integration report | 2026-06-22 | REAL | Manual evidence report with commands and security results. |
| `reports/ci-first-run.md` | GitHub Actions | 2026-06-24 | REAL | Contains clickable green CI run URL. |
| `reports/ci-setup-evidence.md` | GitHub Actions setup | 2026-06-21 | REAL | Workflow setup evidence document. |
| `reports/commit-history-snapshot.txt` | Git history | 2026-06-24 | REAL | Point-in-time `git log --oneline` snapshot with live history link. |
| `reports/contribution-readiness.md` | Contribution docs validation | 2026-06-21 | REAL | Contributor-template evidence and validation logs. |
| `reports/evidence-inventory.md` | Evidence inventory | 2026-06-21 | REAL | Repository claim/evidence ledger. |
| `reports/global-installation-report.md` | Global installer | 2026-05-24 | REAL | Global installation evidence report. |
| `reports/installer-audit.md` | Installer audit | 2026-06-21 | REAL | Sandbox installer audit evidence. |
| `reports/pi-akses-satu-detection.md` | Pi provider detection | 2026-06-22 | REAL | Local Pi/Akses Satu detection report. |
| `reports/pi-core-tools-install.md` | Pi core tools installer | 2026-06-24 | REAL | Dry-run install evidence; no local write performed. |
| `reports/pi-core-tools-verify.md` | Pi core tools verifier | 2026-06-24 | REAL | Local Pi verify output; currently PARTIAL because profiles/marker were not written. |
| `reports/pi-local-cleanup.md` | Pi local cleanup | 2026-06-24 | REAL | Dry-run cleanup evidence; no local files quarantined or deleted. |
| `reports/push-ci-verification-readiness.md` | GitHub Actions verifier | 2026-06-21 | REAL | Runbook/script validation evidence. |
| `reports/python-audit.txt` | Python audit | 2026-06-24 | REAL | `find`/`wc -l` output plus TOOLING/LEGACY/CORE classification. |
| `reports/release-readiness-v3.1.0.md` | Release readiness | 2026-06-24 | REAL | Published v3.1.0 release readiness/evidence summary. |
| `reports/release-v3.1.0-notes.md` | Release notes | 2026-06-24 | REAL | Published v3.1.0 release notes evidence. |
| `reports/repo-cleanup-v3.1.0.md` | Repo cleanup | 2026-06-24 | REAL | Inventory and cleanup evidence for ignored/generated local outputs. |
| `reports/security-ci-setup-evidence.md` | Security CI setup | 2026-06-21 | REAL | Security workflow setup evidence. |
| `reports/skill-audit-results.csv` | scripts/audit-skills.sh | 2026-06-24 | REAL | CSV output from substantive skill audit. |
| `reports/skill-audit-summary.md` | scripts/audit-skills.sh | 2026-06-24 | REAL | Markdown summary output from substantive skill audit. |
| `reports/skill-security-audit.json` | Skill Security Auditor | 2026-06-24 | REAL | Redacted deterministic JSON semantic risk audit output. |
| `reports/skill-security-audit.md` | Skill Security Auditor | 2026-06-24 | REAL | Markdown semantic risk audit summary. |
| `reports/skill-completion-report.md` | Skill expansion report | 2026-06-21 | REAL | Skill expansion/completion report. |
| `reports/source-skill-index.md` | Source skill inventory | 2026-05-24 | REAL | Source skill index report. |
| `reports/tool-evidence/README.md` | Tool evidence index | 2026-06-24 | REAL | Index for compact local tool evidence. |
| `reports/tool-evidence/coverage-summary.md` | Vitest coverage | 2026-06-22 | REAL | Summary generated from coverage log. |
| `reports/tool-evidence/gitleaks-dir.json` | Gitleaks dir | 2026-06-21 | REAL | Valid JSON array output; empty array means zero findings. |
| `reports/tool-evidence/gitleaks-dir.log` | Gitleaks dir | 2026-06-21 | REAL | Raw redacted Gitleaks directory scan log. |
| `reports/tool-evidence/gitleaks-git.json` | Gitleaks git | 2026-06-22 | REAL | Valid JSON array output; empty array means zero findings. |
| `reports/tool-evidence/gitleaks-git.log` | Gitleaks git | 2026-06-22 | REAL | Raw redacted Gitleaks git-history scan log. |
| `reports/tool-evidence/knip.log` | Knip | 2026-06-24 | REAL | JSON reporter output from npx knip. |
| `reports/tool-evidence/osv-scanner.log` | OSV-Scanner | 2026-06-22 | FAILED | Latest local OSV run timed out against OSV API; failure is preserved honestly. |
| `reports/tool-evidence/osv.json` | OSV-Scanner | 2026-06-21 | REAL | Valid prior JSON output; latest rerun status is documented in osv-scanner.log. |
| `reports/tool-evidence/playwright-summary.md` | Playwright | 2026-06-21 | REAL | Summary generated from Playwright log. |
| `reports/tool-evidence/playwright.log` | Playwright | 2026-06-21 | REAL | Playwright run log showing skipped placeholder test. |
| `reports/tool-evidence/repomix-summary.md` | Repomix | 2026-06-21 | REAL | Summary generated from Repomix log. |
| `reports/tool-evidence/repomix-token-summary.md` | Repomix | 2026-06-24 | REAL | Compact token-count-tree summary from `npm run token:report`. |
| `reports/tool-evidence/repomix.log` | Repomix | 2026-06-21 | REAL | Repomix compressed-context generation log. |
| `reports/tool-evidence/semgrep.json` | Semgrep | 2026-06-22 | REAL | Valid Semgrep JSON output with findings/errors fields. |
| `reports/tool-evidence/semgrep.log` | Semgrep | 2026-06-22 | REAL | Raw Semgrep scan log. |
| `reports/tool-evidence/test-coverage.log` | Vitest coverage | 2026-06-22 | REAL | Raw npm run test:coverage log. |
| `reports/tool-evidence/test-unit.log` | Vitest unit tests | 2026-06-22 | REAL | Raw npm run test:unit log. |
| `reports/tool-evidence/typecheck.log` | TypeScript | 2026-06-22 | REAL | Raw npm run typecheck log. |
| `reports/tool-evidence/verify-skills.log` | Source skill verifier | 2026-06-22 | REAL | Raw npm run verify:skills log. |

## Format Validation

- CSV OK: `reports/skill-audit-results.csv` (83 rows)
- JSON OK: `reports/tool-evidence/gitleaks-dir.json`
- JSON OK: `reports/tool-evidence/gitleaks-git.json`
- JSON OK: `reports/tool-evidence/knip.log`
- JSON OK: `reports/skill-security-audit.json`
- JSON OK: `reports/tool-evidence/osv.json`
- JSON OK: `reports/tool-evidence/semgrep.json`

## Known Failed Tool Runs

- `reports/tool-evidence/osv-scanner.log`: OSV-Scanner reached local dependency extraction, then failed retrieving vulnerabilities because the OSV API request timed out. This is marked `FAILED`, not `REAL` success evidence.

## STUB Status

- STUB files found: 0
- Empty/template reports are not claimed as evidence.
