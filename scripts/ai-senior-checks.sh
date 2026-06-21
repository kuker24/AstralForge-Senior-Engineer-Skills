#!/usr/bin/env bash
set -euo pipefail

PKG_RUN="npm run"

has_script() {
  [ -f package.json ] && node -e "const p=require('./package.json'); process.exit(p.scripts && p.scripts[process.argv[1]] ? 0 : 1)" "$1"
}

echo "== Senior Quality Checks =="

echo ""
echo "== Git status =="
git status --short 2>/dev/null || true

echo ""
echo "== OMNI =="
if command -v omni >/dev/null 2>&1; then
  omni stats --detail || true
else
  echo "OMNI not found"
fi

echo ""
echo "== Typecheck =="
if [ -f package.json ]; then
  if has_script "typecheck"; then
    $PKG_RUN typecheck || true
  else
    echo "No typecheck script"
  fi
else
  echo "No package.json"
fi

echo ""
echo "== Unit tests =="
if [ -f package.json ]; then
  if has_script "test:unit"; then
    $PKG_RUN test:unit || true
  else
    echo "No test:unit script"
  fi
else
  echo "No package.json"
fi

echo ""
echo "== Coverage summary =="
if [ -f package.json ]; then
  if has_script "test:coverage"; then
    $PKG_RUN test:coverage || true
  else
    echo "No test:coverage script"
  fi
else
  echo "No package.json"
fi

echo ""
echo "== Secret scan =="
if command -v gitleaks >/dev/null 2>&1; then
  gitleaks dir --redact --report-format json --report-path gitleaks-dir-report.json . || true
else
  echo "Gitleaks not found"
fi

echo ""
echo "== Dependency vulnerability scan =="
if command -v osv-scanner >/dev/null 2>&1; then
  osv-scanner scan source -r . --format json --output-file osv-results.json || true
else
  echo "OSV-Scanner not found"
fi

echo ""
echo "== Static security scan =="
if command -v semgrep >/dev/null 2>&1; then
  semgrep scan --config p/default --metrics=off --json --json-output=semgrep-results.json || true
else
  echo "Semgrep not found"
fi

echo ""
echo "== Dead code / dependency check =="
if [ -f package.json ]; then
  npx knip || true
else
  echo "No package.json, skipping Knip"
fi

echo ""
echo "== Repomix review package =="
if command -v repomix >/dev/null 2>&1; then
  repomix --compress || true
else
  echo "Repomix not found"
fi

echo ""
echo "Done."
echo "Stryker mutation testing is manual-only. Do not run it unless explicitly requested."
