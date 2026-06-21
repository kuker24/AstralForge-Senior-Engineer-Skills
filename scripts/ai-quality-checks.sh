#!/usr/bin/env bash
set -euo pipefail

echo "== AI Quality Checks =="

echo ""
echo "== Environment =="
pwd
node --version 2>/dev/null || true
npm --version 2>/dev/null || true

echo ""
echo "== OMNI =="
if command -v omni >/dev/null 2>&1; then
  omni stats --detail || true
else
  echo "OMNI not found"
fi

echo ""
echo "== Semgrep =="
if command -v semgrep >/dev/null 2>&1; then
  semgrep scan --config p/default --metrics=off --json --json-output=semgrep-results.json || true
else
  echo "Semgrep not found"
fi

echo ""
echo "== OSV-Scanner =="
if command -v osv-scanner >/dev/null 2>&1; then
  osv-scanner scan source -r . --format json --output-file osv-results.json || true
else
  echo "OSV-Scanner not found"
fi

echo ""
echo "== Gitleaks =="
if command -v gitleaks >/dev/null 2>&1; then
  gitleaks git --redact --report-format json --report-path gitleaks-report.json . || true
  gitleaks dir --redact --report-format json --report-path gitleaks-dir-report.json . || true
else
  echo "Gitleaks not found"
fi

echo ""
echo "== Knip =="
if [ -f package.json ]; then
  if command -v knip >/dev/null 2>&1; then
    knip || true
  else
    npx knip || true
  fi
else
  echo "No package.json, skipping Knip"
fi

echo ""
echo "== Playwright =="
if [ -f package.json ]; then
  npx playwright test --project=chromium || true
elif [ -f playwright.config.ts ] || [ -f playwright.config.js ] || [ -f playwright.config.mjs ] || [ -f playwright.config.cjs ]; then
  if command -v playwright >/dev/null 2>&1; then
    playwright test --project=chromium || true
  else
    echo "Playwright not installed"
  fi
else
  echo "No package.json or Playwright config, skipping Playwright"
fi

echo ""
echo "Done. Reports are local and should be ignored by git."
