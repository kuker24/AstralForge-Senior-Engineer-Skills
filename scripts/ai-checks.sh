#!/usr/bin/env bash
set -euo pipefail

echo "== AI local checks =="

if command -v omni >/dev/null 2>&1; then
  echo "OMNI detected:"
  omni stats --detail || true
fi

echo ""
echo "== Semgrep CE =="
if command -v semgrep >/dev/null 2>&1; then
  if ! semgrep scan --config auto --metrics=off --json --json-output=semgrep-results.json; then
    echo "semgrep auto config failed with metrics disabled; retrying no-login/no-metrics with p/default rules"
    semgrep scan --config p/default --metrics=off --json --json-output=semgrep-results.json || true
  fi
else
  echo "semgrep not installed"
fi

echo ""
echo "== Repomix =="
if command -v repomix >/dev/null 2>&1; then
  repomix --compress || true
else
  npx repomix@latest --compress || true
fi

echo ""
echo "Done."
