#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=0
FORCE=0
PI_HOME_ARG=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --force) FORCE=1 ;;
    --pi-home)
      shift
      PI_HOME_ARG="${1:-}"
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
  shift
done

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
PI_HOME="${PI_HOME_ARG:-${PI_HOME:-$HOME/.pi/agent}}"
TIMESTAMP=$(date -u +%Y%m%dT%H%M%SZ)
REPORT_PATH="$REPO_ROOT/reports/pi-local-cleanup.md"
BACKUP_PATH="$PI_HOME/.astralforge-backups/$TIMESTAMP-cleanup"
CANDIDATES=()
NOTES=()
ACTION_STATUS="DRY_RUN"

add_candidate() {
  CANDIDATES+=("$1")
}

if [ ! -d "$PI_HOME" ]; then
  NOTES+=("Pi home missing: $PI_HOME")
else
  if [ -d "$PI_HOME/skills" ]; then
    while IFS= read -r local_skill; do
      name=$(basename "$local_skill")
      if [ ! -d "$REPO_ROOT/skills/$name" ] && [ -f "$local_skill/SKILL.md" ] && grep -Eiq 'AstralForge|astralforge' "$local_skill/SKILL.md"; then
        add_candidate "$local_skill"
      fi
    done < <(find "$PI_HOME/skills" -mindepth 1 -maxdepth 1 -type d | sort)
  fi

  for rel in repomix-output.xml repomix-output.md repomix-output.txt semgrep-results.json osv-results.json gitleaks-report.json gitleaks-dir-report.json playwright-report test-results coverage .stryker-tmp mutation-report; do
    if [ -e "$PI_HOME/$rel" ]; then add_candidate "$PI_HOME/$rel"; fi
  done
fi

if [ "$DRY_RUN" -eq 0 ] && [ "$FORCE" -eq 1 ] && [ "${#CANDIDATES[@]}" -gt 0 ]; then
  mkdir -p "$BACKUP_PATH/quarantine"
  for candidate in "${CANDIDATES[@]}"; do
    base=$(basename "$candidate")
    target="$BACKUP_PATH/quarantine/$base"
    i=1
    while [ -e "$target" ]; do
      target="$BACKUP_PATH/quarantine/$base.$i"
      i=$((i + 1))
    done
    mv "$candidate" "$target"
  done
  ACTION_STATUS="QUARANTINED_TO:$BACKUP_PATH/quarantine"
elif [ "$DRY_RUN" -eq 0 ] && [ "$FORCE" -ne 1 ]; then
  ACTION_STATUS="BLOCKED_NEEDS_FORCE"
  NOTES+=("Run with --force after reviewing dry-run output to quarantine candidates.")
elif [ "$DRY_RUN" -eq 1 ]; then
  ACTION_STATUS="DRY_RUN_NO_CHANGES"
fi

{
  echo "# Pi Local Cleanup Report"
  echo
  echo "Generated: $TIMESTAMP"
  echo "Repo: $REPO_ROOT"
  echo "Pi home: $PI_HOME"
  echo "Mode: dry_run=$DRY_RUN force=$FORCE"
  echo "Action: $ACTION_STATUS"
  echo "Backup/quarantine path: $BACKUP_PATH"
  echo
  echo "## Cleanup Candidates"
  if [ "${#CANDIDATES[@]}" -eq 0 ]; then
    echo "- None."
  else
    for candidate in "${CANDIDATES[@]}"; do echo "- $candidate"; done
  fi
  echo
  echo "## Protected Paths"
  echo "- .env and .env.*"
  echo "- API keys, tokens, private keys, cookies, and Authorization headers"
  echo "- user custom skills"
  echo "- user notes and unknown manually-created files"
  echo
  echo "## Notes"
  if [ "${#NOTES[@]}" -eq 0 ]; then
    echo "- No additional notes."
  else
    for note in "${NOTES[@]}"; do echo "- $note"; done
  fi
} > "$REPORT_PATH"

echo "Pi local cleanup report: $REPORT_PATH"
echo "Action: $ACTION_STATUS"
echo "Candidates: ${#CANDIDATES[@]}"

if [ "$ACTION_STATUS" = "BLOCKED_NEEDS_FORCE" ]; then
  exit 1
fi
