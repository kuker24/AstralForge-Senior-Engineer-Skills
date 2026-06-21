# Tool Evidence Index

Date: 2026-06-22

This folder stores compact dogfooding evidence for local tools. It intentionally avoids committing large generated artifacts such as full coverage HTML, Playwright HTML reports, or `repomix-output.xml`.

| Tool | Command | Status | Evidence File |
|------|---------|--------|---------------|
| TypeScript typecheck | `npm run typecheck` | PASS | [`typecheck.log`](typecheck.log) |
| Vitest unit tests | `npm run test:unit` | PASS | [`test-unit.log`](test-unit.log) |
| Vitest coverage | `npm run test:coverage` | PASS | [`coverage-summary.md`](coverage-summary.md) |
| Source skill verification | `npm run verify:skills` | PASS | [`verify-skills.log`](verify-skills.log) |
| Semgrep | `semgrep scan --config p/default --metrics=off --json --json-output=reports/tool-evidence/semgrep.json` | PASS, 0 findings | [`semgrep.json`](semgrep.json) |
| OSV-Scanner | `osv-scanner scan source -r . --format json --output-file reports/tool-evidence/osv.json` | PASS, 0 vulnerability matches | [`osv.json`](osv.json) |
| Gitleaks git | `gitleaks git --redact --report-format json --report-path reports/tool-evidence/gitleaks-git.json .` | PASS, 0 findings | [`gitleaks-git.json`](gitleaks-git.json) |
| Gitleaks dir | `gitleaks dir --redact --report-format json --report-path reports/tool-evidence/gitleaks-dir.json .` | PASS, 0 findings | [`gitleaks-dir.json`](gitleaks-dir.json) |
| Knip | `npx knip` | PASS, no output/findings | [`knip.log`](knip.log) |
| Playwright | `npx playwright test --project=chromium` | PASS | [`playwright-summary.md`](playwright-summary.md) |
| Repomix | `repomix --compress` | PASS | [`repomix-summary.md`](repomix-summary.md) |

## Large Outputs Not Committed

- `coverage/` is ignored; see `coverage-summary.md`.
- `playwright-report/` is ignored; see `playwright-summary.md`.
- `repomix-output.xml` is ignored; see `repomix-summary.md`.

## Safety Notes

- Gitleaks reports are redacted and contain zero findings for this run.
- No Stryker mutation testing was run.
- No cloud login or API key was used.
