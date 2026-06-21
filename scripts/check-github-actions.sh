#!/usr/bin/env bash
set -euo pipefail

REPO="${GITHUB_REPOSITORY:-kuker24/AstralForge-Senior-Engineer-Skills}"
BRANCH="${GITHUB_REF_NAME:-main}"
SHA="$(git rev-parse HEAD 2>/dev/null || true)"
WATCH=false
DRY_RUN=false
TIMEOUT_SECONDS=900
INTERVAL_SECONDS=20
WORKFLOWS=("ci.yml" "security.yml" "installers.yml")

usage() {
  cat <<'USAGE'
Usage: scripts/check-github-actions.sh [OPTIONS]

Read-only GitHub Actions verification for release readiness. This script does
not push, tag, publish, upload reports, or modify repository state.

Options:
  --repo OWNER/REPO      GitHub repository to inspect.
  --branch BRANCH       Branch to inspect. Default: main or GITHUB_REF_NAME.
  --sha SHA             Commit SHA that each workflow must match. Default: HEAD.
  --workflow FILE       Add a workflow file to check. May be repeated.
                        Defaults: ci.yml, security.yml, installers.yml.
  --watch               Poll until workflows pass/fail or timeout.
  --timeout SECONDS     Watch timeout. Default: 900.
  --interval SECONDS    Watch polling interval. Default: 20.
  --dry-run             Print intended read-only checks and exit 0.
  --help                Show this help.

Examples:
  scripts/check-github-actions.sh --dry-run
  scripts/check-github-actions.sh --repo kuker24/AstralForge-Senior-Engineer-Skills --branch main --sha "$(git rev-parse HEAD)"
  scripts/check-github-actions.sh --watch --timeout 1800
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      [[ $# -ge 2 ]] || { echo "Missing value for --repo" >&2; exit 64; }
      REPO="$2"
      shift 2
      ;;
    --branch)
      [[ $# -ge 2 ]] || { echo "Missing value for --branch" >&2; exit 64; }
      BRANCH="$2"
      shift 2
      ;;
    --sha)
      [[ $# -ge 2 ]] || { echo "Missing value for --sha" >&2; exit 64; }
      SHA="$2"
      shift 2
      ;;
    --workflow)
      [[ $# -ge 2 ]] || { echo "Missing value for --workflow" >&2; exit 64; }
      if [[ "${WORKFLOWS_OVERRIDDEN:-false}" != true ]]; then
        WORKFLOWS=()
        WORKFLOWS_OVERRIDDEN=true
      fi
      WORKFLOWS+=("$2")
      shift 2
      ;;
    --watch)
      WATCH=true
      shift
      ;;
    --timeout)
      [[ $# -ge 2 ]] || { echo "Missing value for --timeout" >&2; exit 64; }
      TIMEOUT_SECONDS="$2"
      shift 2
      ;;
    --interval)
      [[ $# -ge 2 ]] || { echo "Missing value for --interval" >&2; exit 64; }
      INTERVAL_SECONDS="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 64
      ;;
  esac
done

if [[ -z "$SHA" ]]; then
  echo "Could not determine commit SHA. Pass --sha explicitly." >&2
  exit 64
fi

validate_positive_integer() {
  local name="$1"
  local value="$2"
  if [[ ! "$value" =~ ^[0-9]+$ ]] || [[ "$value" -eq 0 ]]; then
    echo "$name must be a positive integer, got: $value" >&2
    exit 64
  fi
}

validate_positive_integer "--timeout" "$TIMEOUT_SECONDS"
validate_positive_integer "--interval" "$INTERVAL_SECONDS"

print_plan() {
  echo "AstralForge GitHub Actions verification"
  echo "Repository: $REPO"
  echo "Branch: $BRANCH"
  echo "Commit SHA: $SHA"
  echo "Watch: $WATCH"
  echo "Timeout seconds: $TIMEOUT_SECONDS"
  echo "Interval seconds: $INTERVAL_SECONDS"
  echo "Workflows:"
  for workflow in "${WORKFLOWS[@]}"; do
    echo "  - $workflow"
  done
}

if [[ "$DRY_RUN" == true ]]; then
  print_plan
  echo "Dry run only: no GitHub API calls performed."
  exit 0
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "gh CLI is required for remote workflow verification." >&2
  echo "Install gh or run this check in an environment where gh is available." >&2
  exit 127
fi

check_once() {
  local all_success=true
  local any_pending=false
  local tmp_file
  tmp_file="$(mktemp)"

  print_plan

  for workflow in "${WORKFLOWS[@]}"; do
    echo ""
    echo "Checking workflow: $workflow"
    if ! gh run list \
      --repo "$REPO" \
      --workflow "$workflow" \
      --branch "$BRANCH" \
      --limit 50 \
      --json headSha,status,conclusion,url,workflowName,createdAt \
      > "$tmp_file"; then
      rm -f "$tmp_file"
      echo "Failed to query GitHub Actions for workflow: $workflow" >&2
      return 3
    fi

    set +e
    node - "$tmp_file" "$SHA" "$workflow" <<'NODE'
const fs = require('node:fs');
const [file, sha, workflow] = process.argv.slice(2);
const runs = JSON.parse(fs.readFileSync(file, 'utf8'));
const matches = runs.filter((run) => run.headSha === sha);
if (matches.length === 0) {
  console.log(`PENDING: no run found for ${workflow} at ${sha}`);
  process.exit(20);
}
const run = matches[0];
console.log(`Run: ${run.workflowName || workflow}`);
console.log(`Created: ${run.createdAt || 'unknown'}`);
console.log(`Status: ${run.status || 'unknown'}`);
console.log(`Conclusion: ${run.conclusion || 'pending'}`);
console.log(`URL: ${run.url || 'unknown'}`);
if (run.status !== 'completed') {
  process.exit(21);
}
if (run.conclusion !== 'success') {
  process.exit(22);
}
NODE
    node_status=$?
    set -e
    case $node_status in
      0)
        echo "PASS: $workflow"
        ;;
      20|21)
        any_pending=true
        all_success=false
        ;;
      22)
        rm -f "$tmp_file"
        echo "FAIL: $workflow did not conclude successfully." >&2
        return 1
        ;;
      *)
        rm -f "$tmp_file"
        echo "FAIL: unable to evaluate $workflow." >&2
        return 3
        ;;
    esac
  done

  rm -f "$tmp_file"

  if [[ "$all_success" == true ]]; then
    echo ""
    echo "All required workflows passed for $SHA."
    return 0
  fi

  if [[ "$any_pending" == true ]]; then
    echo ""
    echo "One or more workflows are pending or missing for $SHA."
    return 2
  fi

  return 1
}

if [[ "$WATCH" != true ]]; then
  check_once
  exit $?
fi

start_time="$(date +%s)"
while true; do
  set +e
  check_once
  status=$?
  set -e

  if [[ "$status" -eq 0 || "$status" -eq 1 || "$status" -eq 3 ]]; then
    exit "$status"
  fi

  now="$(date +%s)"
  elapsed=$((now - start_time))
  if [[ "$elapsed" -ge "$TIMEOUT_SECONDS" ]]; then
    echo "Timed out waiting for workflows after ${elapsed}s." >&2
    exit 2
  fi

  echo "Waiting ${INTERVAL_SECONDS}s before next check..."
  sleep "$INTERVAL_SECONDS"
done
