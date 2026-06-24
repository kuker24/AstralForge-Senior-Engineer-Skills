#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
REPORT_PATH="$REPO_ROOT/reports/tool-evidence/repomix-token-summary.md"
TMP_DIR=$(mktemp -d)
TOKEN_TREE_LOG="$TMP_DIR/repomix-token-tree.log"
CLEAN_TOKEN_TREE_LOG="$TMP_DIR/repomix-token-tree-clean.log"
VERSION_LOG="$TMP_DIR/repomix-version.log"
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
STATUS="UNVERIFIED"
VERSION="UNVERIFIED"
NOTES=()
TOKEN_BUDGET="${ASTRALFORGE_TOKEN_BUDGET:-}"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

if ! command -v npm >/dev/null 2>&1; then
  STATUS="BLOCKED_BY_MISSING_NPM"
  NOTES+=("npm is required for npx repomix@latest")
else
  if npx repomix@latest --version >"$VERSION_LOG" 2>&1; then
    VERSION=$(tr -d '\r' < "$VERSION_LOG" | tail -1)
  else
    STATUS="BLOCKED_BY_REPOMIX_VERSION"
    NOTES+=("npx repomix@latest --version failed")
  fi

  if [ "$STATUS" = "UNVERIFIED" ]; then
    if NO_COLOR=1 CI=1 npx repomix@latest --token-count-tree 1000 >"$TOKEN_TREE_LOG" 2>&1; then
      python3 - "$TOKEN_TREE_LOG" "$CLEAN_TOKEN_TREE_LOG" <<'PY'
import re
import sys
source, target = sys.argv[1:3]
text = open(source, 'r', encoding='utf-8', errors='replace').read()
text = re.sub(r'\x1b\[[0-?]*[ -/]*[@-~]', '', text)
text = re.sub(r'[\r\x00-\x08\x0b\x0c\x0e-\x1f\x7f]', '\n', text)
lines = [line.rstrip() for line in text.splitlines()]
lines = [line for line in lines if line and not line.lstrip().startswith(('⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'))]
open(target, 'w', encoding='utf-8').write('\n'.join(lines) + ('\n' if lines else ''))
PY
      STATUS="VERIFIED"
    else
      STATUS="BLOCKED_BY_REPOMIX_TOKEN_TREE"
      NOTES+=("npx repomix@latest --token-count-tree 1000 failed")
    fi
  fi
fi

mkdir -p "$(dirname "$REPORT_PATH")"
{
  echo "# Repomix Token Summary"
  echo
  echo "Generated: $TIMESTAMP"
  echo "Status: $STATUS"
  echo "Repomix version: $VERSION"
  echo "Command: \`npx repomix@latest --token-count-tree 1000\`"
  echo
  echo "## Token Tree Preview"
  echo
  if [ -s "$CLEAN_TOKEN_TREE_LOG" ]; then
    echo '```txt'
    tail -120 "$CLEAN_TOKEN_TREE_LOG"
    echo '```'
  else
    echo "No token tree output captured."
  fi
  echo
  echo "## Optional Compress/Token Budget"
  if [ -n "$TOKEN_BUDGET" ]; then
    echo "Token budget requested via ASTRALFORGE_TOKEN_BUDGET=$TOKEN_BUDGET. Raw compressed output remains ignored."
  else
    echo "No compression run. Set ASTRALFORGE_TOKEN_BUDGET before running if a compressed budgeted snapshot is needed."
  fi
  echo
  echo "## Notes"
  if [ "${#NOTES[@]}" -eq 0 ]; then
    echo "- No blockers."
  else
    for note in "${NOTES[@]}"; do echo "- $note"; done
  fi
} > "$REPORT_PATH"

rm -f "$REPO_ROOT"/repomix-output.xml "$REPO_ROOT"/repomix-output.md "$REPO_ROOT"/repomix-output.txt

echo "Repomix token report status: $STATUS"
echo "Report: $REPORT_PATH"

if [[ "$STATUS" == BLOCKED_* ]]; then
  exit 0
fi
