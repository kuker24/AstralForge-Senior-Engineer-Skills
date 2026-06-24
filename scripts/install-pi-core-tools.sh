#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=0
FORCE=0
VERIFY_ONLY=0
SKIP_NETWORK=0
PI_HOME_ARG=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --force) FORCE=1 ;;
    --verify-only) VERIFY_ONLY=1 ;;
    --skip-network) SKIP_NETWORK=1 ;;
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
REPORT_PATH="$REPO_ROOT/reports/pi-core-tools-install.md"
PI_HOME="${PI_HOME_ARG:-${PI_HOME:-$HOME/.pi/agent}}"
TIMESTAMP=$(date -u +%Y%m%dT%H%M%SZ)
BACKUP_PATH="$PI_HOME/.astralforge-backups/$TIMESTAMP"
SKILL_COUNT=$(find "$REPO_ROOT/skills" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')
PROFILE_COUNT=$(find "$REPO_ROOT/profiles" -mindepth 1 -maxdepth 1 -type f -name '*.md' | wc -l | tr -d ' ')
GIT_COMMIT=$(git -C "$REPO_ROOT" rev-parse HEAD 2>/dev/null || echo unknown)
OS_NAME=$(uname -s 2>/dev/null || echo unknown)
NODE_STATUS="BLOCKED_BY_MISSING_DEPENDENCY"
NPM_STATUS="BLOCKED_BY_MISSING_DEPENDENCY"
UV_STATUS="BLOCKED_BY_MISSING_DEPENDENCY"
CTX7_STATUS="UNVERIFIED"
SERENA_STATUS="UNVERIFIED"
REPOMIX_STATUS="UNVERIFIED"
WRITE_STATUS="DRY_RUN"
BACKUP_STATUS="NOT_CREATED_DRY_RUN"
SYNC_STATUS="NOT_RUN"
MARKER_STATUS="NOT_WRITTEN"
NOTES=()

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

run_or_echo() {
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "DRY-RUN: $*"
  else
    "$@"
  fi
}

record_note() {
  NOTES+=("$1")
}

if command_exists node; then NODE_STATUS="$(node --version 2>/dev/null || echo AVAILABLE)"; fi
if command_exists npm; then NPM_STATUS="$(npm --version 2>/dev/null || echo AVAILABLE)"; fi
if command_exists uv; then UV_STATUS="$(uv --version 2>/dev/null || echo AVAILABLE)"; fi

if [ "$VERIFY_ONLY" -eq 1 ]; then
  WRITE_STATUS="VERIFY_ONLY"
fi

if [ ! -d "$PI_HOME" ]; then
  if [ "$VERIFY_ONLY" -eq 1 ]; then
    record_note "Pi home missing in verify-only mode: $PI_HOME"
  elif [ "$DRY_RUN" -eq 1 ]; then
    record_note "Would create Pi home: $PI_HOME"
  else
    mkdir -p "$PI_HOME"
    record_note "Created Pi home: $PI_HOME"
  fi
fi

if [ "$VERIFY_ONLY" -eq 0 ] && [ "$DRY_RUN" -eq 0 ]; then
  mkdir -p "$BACKUP_PATH"
  BACKUP_STATUS="CREATED:$BACKUP_PATH"
  for item in skills extensions settings.json models.json presets.json AGENTS.md profiles prompts; do
    if [ -e "$PI_HOME/$item" ]; then
      parent=$(dirname "$BACKUP_PATH/$item")
      mkdir -p "$parent"
      cp -a "$PI_HOME/$item" "$BACKUP_PATH/$item"
    else
      record_note "Backup skipped missing item: $item"
    fi
  done
fi

if [ "$VERIFY_ONLY" -eq 0 ]; then
  if [ "$DRY_RUN" -eq 1 ]; then
    SYNC_STATUS="DRY_RUN_WOULD_SYNC_SKILLS_AND_PROFILES"
    echo "DRY-RUN: would sync $SKILL_COUNT skills into $PI_HOME/skills"
    echo "DRY-RUN: would sync $PROFILE_COUNT profiles into $PI_HOME/profiles/astralforge"
  else
    mkdir -p "$PI_HOME/skills" "$PI_HOME/profiles"
    while IFS= read -r skill_dir; do
      name=$(basename "$skill_dir")
      rm -rf "$PI_HOME/skills/$name"
      cp -a "$skill_dir" "$PI_HOME/skills/$name"
    done < <(find "$REPO_ROOT/skills" -mindepth 1 -maxdepth 1 -type d | sort)
    rm -rf "$PI_HOME/profiles/astralforge"
    mkdir -p "$PI_HOME/profiles/astralforge"
    cp -a "$REPO_ROOT/profiles/." "$PI_HOME/profiles/astralforge/"
    SYNC_STATUS="SYNCED"
  fi
fi

if [ "$SKIP_NETWORK" -eq 1 ]; then
  if command_exists ctx7; then
    if ctx7 --help >/dev/null 2>&1; then CTX7_STATUS="VERIFIED_LOCAL_CTX7"; else CTX7_STATUS="PARTIAL_CTX7_COMMAND_FAILED"; fi
  else
    CTX7_STATUS="BLOCKED_BY_SKIP_NETWORK_NO_LOCAL_CTX7"
  fi
else
  if command_exists npm; then
    if npx ctx7 --help >/dev/null 2>&1; then
      CTX7_STATUS="VERIFIED_NPX_CTX7_HELP"
    else
      CTX7_STATUS="PARTIAL_CTX7_HELP_FAILED"
    fi
    if [ "$VERIFY_ONLY" -eq 0 ] && [ "$DRY_RUN" -eq 0 ] && [ "$FORCE" -eq 1 ]; then
      if [ -t 0 ]; then
        if npx ctx7 setup >/dev/null 2>&1; then
          CTX7_STATUS="$CTX7_STATUS;SETUP_VERIFIED"
        else
          CTX7_STATUS="$CTX7_STATUS;PARTIAL_SETUP_FAILED"
        fi
      else
        CTX7_STATUS="$CTX7_STATUS;BLOCKED_BY_INTERACTIVE_SETUP"
      fi
    fi
  else
    CTX7_STATUS="BLOCKED_BY_MISSING_NPM"
  fi
fi

if command_exists uv; then
  if command_exists serena && serena --help >/dev/null 2>&1; then
    SERENA_STATUS="VERIFIED_SERENA_HELP"
  else
    if [ "$VERIFY_ONLY" -eq 0 ] && [ "$DRY_RUN" -eq 0 ] && [ "$FORCE" -eq 1 ] && [ "$SKIP_NETWORK" -eq 0 ]; then
      if uv tool install -p 3.13 serena-agent >/dev/null 2>&1; then
        record_note "Serena install command completed"
      else
        record_note "Serena install command failed"
      fi
    fi
    if command_exists serena && serena --help >/dev/null 2>&1; then
      SERENA_STATUS="VERIFIED_SERENA_HELP"
    else
      SERENA_STATUS="PARTIAL_UV_AVAILABLE_SERENA_MISSING"
    fi
  fi
  if [[ "$SERENA_STATUS" == VERIFIED_SERENA_HELP* ]]; then
    if [ -e "$REPO_ROOT/.serena" ] || [ -e "$REPO_ROOT/serena_config.yml" ]; then
      SERENA_STATUS="$SERENA_STATUS;INIT_CONFIG_PRESENT"
    else
      SERENA_STATUS="$SERENA_STATUS;INIT_NOT_CONFIRMED"
    fi
  fi
else
  SERENA_STATUS="BLOCKED_BY_MISSING_UV"
fi

if [ "$SKIP_NETWORK" -eq 1 ]; then
  if command_exists repomix; then
    if repomix --version >/dev/null 2>&1; then REPOMIX_STATUS="VERIFIED_LOCAL_REPOMIX"; else REPOMIX_STATUS="PARTIAL_REPOMIX_COMMAND_FAILED"; fi
  else
    REPOMIX_STATUS="BLOCKED_BY_SKIP_NETWORK_NO_LOCAL_REPOMIX"
  fi
else
  if command_exists npm; then
    if npx repomix@latest --version >/dev/null 2>&1; then
      REPOMIX_STATUS="VERIFIED_NPX_REPOMIX_VERSION"
    else
      REPOMIX_STATUS="PARTIAL_REPOMIX_VERSION_FAILED"
    fi
  else
    REPOMIX_STATUS="BLOCKED_BY_MISSING_NPM"
  fi
fi

if [ "$VERIFY_ONLY" -eq 0 ] && [ "$DRY_RUN" -eq 0 ]; then
  node - "$PI_HOME/.astralforge-install.json" "$REPO_ROOT" "$TIMESTAMP" "$GIT_COMMIT" "$SKILL_COUNT" "$PROFILE_COUNT" "$BACKUP_PATH" "$CTX7_STATUS" "$SERENA_STATUS" "$REPOMIX_STATUS" <<'NODE'
const fs = require('node:fs');
const [out, repoPath, installedAt, gitCommit, skillCount, profileCount, backupPath, context7, serena, repomix] = process.argv.slice(2);
fs.writeFileSync(out, `${JSON.stringify({ repoPath, installedAt, gitCommit, skillCount: Number(skillCount), profileCount: Number(profileCount), backupPath, toolStatus: { context7, serena, repomix } }, null, 2)}\n`);
NODE
  MARKER_STATUS="WRITTEN:$PI_HOME/.astralforge-install.json"
fi

{
  echo "# Pi Core Tools Install Report"
  echo
  echo "Generated: $TIMESTAMP"
  echo "Repo: $REPO_ROOT"
  echo "Git commit: $GIT_COMMIT"
  echo "OS: $OS_NAME"
  echo "Pi home: $PI_HOME"
  echo "Mode: dry_run=$DRY_RUN force=$FORCE verify_only=$VERIFY_ONLY skip_network=$SKIP_NETWORK"
  echo
  echo "## Status"
  echo
  echo "| Item | Result |"
  echo "|------|--------|"
  echo "| Node | $NODE_STATUS |"
  echo "| npm | $NPM_STATUS |"
  echo "| uv | $UV_STATUS |"
  echo "| Backup | $BACKUP_STATUS |"
  echo "| Sync | $SYNC_STATUS |"
  echo "| Marker | $MARKER_STATUS |"
  echo "| Context7 | $CTX7_STATUS |"
  echo "| Serena | $SERENA_STATUS |"
  echo "| Repomix | $REPOMIX_STATUS |"
  echo
  echo "## Counts"
  echo
  echo "- Repo skill count: $SKILL_COUNT"
  echo "- Repo profile count: $PROFILE_COUNT"
  echo
  echo "## Notes"
  if [ "${#NOTES[@]}" -eq 0 ]; then
    echo "- No additional notes."
  else
    for note in "${NOTES[@]}"; do echo "- $note"; done
  fi
} > "$REPORT_PATH"

echo "Pi core tools install report: $REPORT_PATH"
echo "Context7: $CTX7_STATUS"
echo "Serena: $SERENA_STATUS"
echo "Repomix: $REPOMIX_STATUS"
echo "Sync: $SYNC_STATUS"
