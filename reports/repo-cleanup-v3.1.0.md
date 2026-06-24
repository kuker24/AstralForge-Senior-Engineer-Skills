# Repo Cleanup v3.1.0 Evidence

Date: 2026-06-24

## Scope

Cleaned only ignored/generated local outputs. No tracked evidence reports were deleted. The v3.0.0 release/tag was not modified.

## Inventory Command

```bash
git ls-files | rg '^(repomix-output\.|semgrep-results\.json|osv-results\.json|gitleaks-report\.json|gitleaks-dir-report\.json|playwright-report/|test-results/|coverage/|\.stryker-tmp/|mutation-report/)' || true
```

Result: no tracked generated outputs matched.

## Cleaned Local Generated Outputs

- `repomix-output.xml`
- `semgrep-results.json`
- `osv-results.json`
- `gitleaks-report.json`
- `gitleaks-dir-report.json`
- `playwright-report/`
- `test-results/`
- `coverage/`

## Protected Evidence

The following were not deleted:

- `reports/INDEX.md`
- `reports/python-audit.txt`
- `reports/commit-history-snapshot.txt`
- `reports/tool-evidence/osv-scanner.log`
- all existing final v3.0.0 evidence reports classified in `reports/INDEX.md`

## Verification

`npm run pi:verify-core-tools` after cleanup initially reported generated outputs as `PASS_ABSENT`. Later required validation commands regenerated ignored local outputs (`coverage/`, `playwright-report/`, and `test-results/`); the final Pi verifier reports them as `PASS_IGNORED`. After user approval, local Pi core tools were installed with backup and final Pi verification reports `Overall: PASS`.
