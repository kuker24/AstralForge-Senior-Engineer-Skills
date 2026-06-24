#!/usr/bin/env bash
set -euo pipefail

PI_HOME_ARG=""
SKIP_NETWORK=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --pi-home)
      shift
      PI_HOME_ARG="${1:-}"
      ;;
    --skip-network) SKIP_NETWORK=1 ;;
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
REPORT_PATH="$REPO_ROOT/reports/pi-core-tools-verify.md"
OVERALL="PASS"
NOTES=()

command_exists() { command -v "$1" >/dev/null 2>&1; }
set_partial() { [ "$OVERALL" = "PASS" ] && OVERALL="PARTIAL"; NOTES+=("$1"); }
set_blocked() { OVERALL="BLOCKED"; NOTES+=("$1"); }

REPO_SKILL_COUNT=$(find "$REPO_ROOT/skills" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')
REPO_PROFILE_COUNT=$(find "$REPO_ROOT/profiles" -mindepth 1 -maxdepth 1 -type f -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
PI_HOME_STATUS="PASS"
LOCAL_SKILL_STATUS="UNVERIFIED"
PROFILE_STATUS="UNVERIFIED"
CTX7_STATUS="UNVERIFIED"
SERENA_STATUS="UNVERIFIED"
REPOMIX_STATUS="UNVERIFIED"
STALE_STATUS="UNVERIFIED"
GENERATED_STATUS="UNVERIFIED"
MARKER_STATUS="UNVERIFIED"

if [ ! -d "$PI_HOME" ]; then
  PI_HOME_STATUS="BLOCKED_MISSING_PI_HOME"
  set_blocked "Pi home does not exist: $PI_HOME"
else
  PI_HOME_STATUS="PASS"
fi

if [ -d "$PI_HOME/skills" ]; then
  LOCAL_MATCHING_COUNT=0
  while IFS= read -r skill_dir; do
    name=$(basename "$skill_dir")
    if [ -d "$PI_HOME/skills/$name" ]; then
      LOCAL_MATCHING_COUNT=$((LOCAL_MATCHING_COUNT + 1))
    fi
  done < <(find "$REPO_ROOT/skills" -mindepth 1 -maxdepth 1 -type d | sort)
  if [ "$LOCAL_MATCHING_COUNT" = "$REPO_SKILL_COUNT" ]; then
    LOCAL_SKILL_STATUS="PASS:$LOCAL_MATCHING_COUNT/$REPO_SKILL_COUNT"
  else
    LOCAL_SKILL_STATUS="PARTIAL:$LOCAL_MATCHING_COUNT/$REPO_SKILL_COUNT"
    set_partial "Local Pi skill count does not match repo manifest"
  fi
else
  LOCAL_SKILL_STATUS="BLOCKED_NO_LOCAL_SKILLS_DIR"
  set_blocked "Missing local Pi skills directory: $PI_HOME/skills"
fi

if [ -d "$PI_HOME/profiles/astralforge" ]; then
  LOCAL_PROFILE_COUNT=$(find "$PI_HOME/profiles/astralforge" -mindepth 1 -maxdepth 1 -type f -name '*.md' | wc -l | tr -d ' ')
  if [ "$LOCAL_PROFILE_COUNT" = "$REPO_PROFILE_COUNT" ]; then
    PROFILE_STATUS="PASS:$LOCAL_PROFILE_COUNT/$REPO_PROFILE_COUNT"
  else
    PROFILE_STATUS="PARTIAL:$LOCAL_PROFILE_COUNT/$REPO_PROFILE_COUNT"
    set_partial "Installed profile count does not match repo profiles"
  fi
else
  PROFILE_STATUS="PARTIAL_NO_ASTRALFORGE_PROFILES"
  set_partial "Missing $PI_HOME/profiles/astralforge"
fi

if [ -f "$PI_HOME/.astralforge-install.json" ]; then
  MARKER_STATUS="PASS_PRESENT"
else
  MARKER_STATUS="PARTIAL_MISSING_MARKER"
  set_partial "Missing .astralforge-install.json marker"
fi

if [ "$SKIP_NETWORK" -eq 1 ]; then
  if command_exists ctx7 && ctx7 --help >/dev/null 2>&1; then
    CTX7_STATUS="PASS_LOCAL_CTX7"
  else
    CTX7_STATUS="PARTIAL_SKIP_NETWORK_NO_LOCAL_CTX7"
    set_partial "Context7 not verified because --skip-network and no local ctx7 command"
  fi
else
  if command_exists npm && npx ctx7 --help >/dev/null 2>&1; then
    CTX7_STATUS="PASS_NPX_CTX7_HELP"
  else
    CTX7_STATUS="PARTIAL_CTX7_HELP_FAILED"
    set_partial "Context7 npx help did not complete"
  fi
fi

if command_exists uv; then
  if command_exists serena && serena --help >/dev/null 2>&1; then
    if [ -e "$REPO_ROOT/.serena" ] || [ -e "$REPO_ROOT/serena_config.yml" ]; then
      SERENA_STATUS="PASS_SERENA_HELP_INIT_CONFIG_PRESENT"
    else
      SERENA_STATUS="PARTIAL_SERENA_HELP_INIT_NOT_CONFIRMED"
      set_partial "Serena command works, but init status is not confirmed"
    fi
  else
    SERENA_STATUS="PARTIAL_UV_PRESENT_SERENA_MISSING"
    set_partial "uv is available but serena command is missing"
  fi
else
  SERENA_STATUS="BLOCKED_BY_MISSING_UV"
  set_blocked "uv is missing; Serena cannot be installed through the official quick-start path"
fi

if [ "$SKIP_NETWORK" -eq 1 ]; then
  if command_exists repomix && repomix --version >/dev/null 2>&1; then
    REPOMIX_STATUS="PASS_LOCAL_REPOMIX"
  else
    REPOMIX_STATUS="PARTIAL_SKIP_NETWORK_NO_LOCAL_REPOMIX"
    set_partial "Repomix not verified because --skip-network and no local repomix command"
  fi
else
  if command_exists npm && npx repomix@latest --version >/dev/null 2>&1; then
    REPOMIX_STATUS="PASS_NPX_REPOMIX_VERSION"
  else
    REPOMIX_STATUS="PARTIAL_REPOMIX_VERSION_FAILED"
    set_partial "Repomix npx version did not complete"
  fi
fi

STALE_COUNT=0
if [ -d "$PI_HOME/skills" ]; then
  while IFS= read -r local_skill; do
    name=$(basename "$local_skill")
    if [ ! -d "$REPO_ROOT/skills/$name" ] && [ -f "$local_skill/SKILL.md" ] && grep -Eiq 'AstralForge|astralforge' "$local_skill/SKILL.md"; then
      STALE_COUNT=$((STALE_COUNT + 1))
    fi
  done < <(find "$PI_HOME/skills" -mindepth 1 -maxdepth 1 -type d | sort)
fi
if [ "$STALE_COUNT" -eq 0 ]; then
  STALE_STATUS="PASS_NO_STALE_ASTRALFORGE_SKILLS"
else
  STALE_STATUS="PARTIAL_STALE_ASTRALFORGE_SKILLS:$STALE_COUNT"
  set_partial "Found stale AstralForge-like local skills not in repo manifest"
fi

GENERATED_FOUND=()
GENERATED_NOT_IGNORED=()
for name in repomix-output.xml repomix-output.md repomix-output.txt semgrep-results.json osv-results.json gitleaks-report.json gitleaks-dir-report.json playwright-report test-results coverage .stryker-tmp mutation-report; do
  if [ -e "$REPO_ROOT/$name" ]; then
    GENERATED_FOUND+=("$name")
    if ! git -C "$REPO_ROOT" check-ignore -q "$name"; then
      GENERATED_NOT_IGNORED+=("$name")
    fi
  fi
done
if [ "${#GENERATED_FOUND[@]}" -eq 0 ]; then
  GENERATED_STATUS="PASS_ABSENT"
elif [ "${#GENERATED_NOT_IGNORED[@]}" -eq 0 ]; then
  GENERATED_STATUS="PASS_IGNORED:${GENERATED_FOUND[*]}"
else
  GENERATED_STATUS="PARTIAL_NOT_IGNORED:${GENERATED_NOT_IGNORED[*]}"
  set_partial "Generated repo outputs exist and are not ignored"
fi

{
  echo "# Pi Core Tools Verify Report"
  echo
  echo "Generated: $TIMESTAMP"
  echo "Repo: $REPO_ROOT"
  echo "Pi home: $PI_HOME"
  echo "Overall: $OVERALL"
  echo "Skip network: $SKIP_NETWORK"
  echo
  echo "| Check | Result |"
  echo "|-------|--------|"
  echo "| Pi home | $PI_HOME_STATUS |"
  echo "| Skills | $LOCAL_SKILL_STATUS |"
  echo "| Profiles | $PROFILE_STATUS |"
  echo "| Marker | $MARKER_STATUS |"
  echo "| Context7 | $CTX7_STATUS |"
  echo "| Serena | $SERENA_STATUS |"
  echo "| Repomix | $REPOMIX_STATUS |"
  echo "| Stale AstralForge skills | $STALE_STATUS |"
  echo "| Generated outputs | $GENERATED_STATUS |"
  echo
  echo "## Notes"
  if [ "${#NOTES[@]}" -eq 0 ]; then
    echo "- No blockers or partial checks."
  else
    for note in "${NOTES[@]}"; do echo "- $note"; done
  fi
} > "$REPORT_PATH"

echo "Overall: $OVERALL"
echo "Pi core tools verify report: $REPORT_PATH"
echo "Skills: $LOCAL_SKILL_STATUS"
echo "Profiles: $PROFILE_STATUS"
echo "Context7: $CTX7_STATUS"
echo "Serena: $SERENA_STATUS"
echo "Repomix: $REPOMIX_STATUS"

if [ "$OVERALL" = "BLOCKED" ]; then
  exit 1
fi
