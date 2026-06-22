#!/usr/bin/env bash
#
# scripts/test-akses-satu-api.sh
#
# Manual smoke test for the Akses Satu Api custom OpenAI-compatible provider.
# This script is intentionally key-safe: it never prints the value of
# AKSES_SATU_API_KEY. Run only when you have intentionally set a valid key.
#
# Exit codes:
#   0 - chat/completions validation PASSED
#   1 - missing env var / setup error
#   2 - chat/completions validation FAILED
#   3 - responses API FAILED (chat itself may have passed)
#
set -euo pipefail

BASE_URL="${AKSES_SATU_BASE_URL:-https://api.satuakses.top/v1}"
MODEL="${AKSES_SATU_DEFAULT_MODEL:-glm-4.6}"

if [ -z "${AKSES_SATU_API_KEY:-}" ]; then
  echo "ERROR: AKSES_SATU_API_KEY belum diset." >&2
  echo "" >&2
  echo "Set dulu dengan (fish):" >&2
  echo "  set -Ux AKSES_SATU_API_KEY 'sk-sa-REPLACE_ME'" >&2
  echo "  set -Ux AKSES_SATU_BASE_URL 'https://api.satuakses.top/v1'" >&2
  echo "  set -Ux AKSES_SATU_DEFAULT_MODEL 'glm-4.6'" >&2
  echo "" >&2
  echo "Atau bash/zsh:" >&2
  echo "  export AKSES_SATU_API_KEY='sk-sa-REPLACE_ME'" >&2
  echo "  export AKSES_SATU_BASE_URL='https://api.satuakses.top/v1'" >&2
  echo "  export AKSES_SATU_DEFAULT_MODEL='glm-4.6'" >&2
  exit 1
fi

echo "Testing Akses Satu Api provider"
echo "  Base URL: ${BASE_URL}"
echo "  Model:    ${MODEL}"
echo "  API Key:  [REDACTED]"
echo ""

CHAT_PASS=0
CHAT_REASON=""
MODELS_PASS=0
MODELS_REASON=""
RESPONSES_OUTCOME="NOT_RUN"

# ----------------------------------------------------------------------------
# 1. GET /v1/models
# ----------------------------------------------------------------------------
echo "== GET ${BASE_URL}/models =="
models_http="$(curl -sS -o /tmp/akses-satu-models.json -w "%{http_code}" \
  -H "Authorization: Bearer ${AKSES_SATU_API_KEY}" \
  "${BASE_URL}/models" || true)"

if [ "${models_http}" = "200" ]; then
  # Extract the `data[*].id` field if jq is available, otherwise list top-level ids.
  if command -v jq >/dev/null 2>&1; then
    listed="$(jq -r '.data[].id? // empty' /tmp/akses-satu-models.json 2>/dev/null | head -20 | tr '\n' ' ')"
  else
    listed="$(grep -oE '"id"[[:space:]]*:[[:space:]]*"[^"]+"' /tmp/akses-satu-models.json \
      | sed -E 's/.*"id"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/' | head -20 | tr '\n' ' ')"
  fi
  if [ -n "${listed// /}" ]; then
    MODELS_PASS=1
    MODELS_REASON="listed $(echo "${listed}" | wc -w | tr -d ' ') models: ${listed}"
  else
    MODELS_REASON="HTTP 200 but no model ids found in payload"
  fi
else
  MODELS_REASON="HTTP ${models_http}"
fi

if [ "${MODELS_PASS}" = "1" ]; then
  echo "  [PASS] ${MODELS_REASON}"
else
  echo "  [FAIL] ${MODELS_REASON}"
fi
echo ""

# ----------------------------------------------------------------------------
# 2. POST /v1/chat/completions
# ----------------------------------------------------------------------------
echo "== POST ${BASE_URL}/chat/completions =="
chat_http="$(curl -sS -o /tmp/akses-satu-chat.json -w "%{http_code}" \
  -H "Authorization: Bearer ${AKSES_SATU_API_KEY}" \
  -H "Content-Type: application/json" \
  -X POST "${BASE_URL}/chat/completions" \
  -d "{\"model\":\"${MODEL}\",\"messages\":[{\"role\":\"user\",\"content\":\"Jawab hanya satu kata: BERHASIL\"}],\"stream\":false,\"max_tokens\":32}" \
  || true)"

if [ "${chat_http}" = "200" ]; then
  if command -v jq >/dev/null 2>&1; then
    obj="$(jq -r '.object // empty' /tmp/akses-satu-chat.json 2>/dev/null || true)"
    content="$(jq -r '.choices[0].message.content // empty' /tmp/akses-satu-chat.json 2>/dev/null || true)"
  else
    obj="$(grep -oE '"object"[[:space:]]*:[[:space:]]*"[^"]+"' /tmp/akses-satu-chat.json \
      | head -1 | sed -E 's/.*"object"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/')"
    content="$(grep -oE '"content"[[:space:]]*:[[:space:]]*"[^"]+"' /tmp/akses-satu-chat.json \
      | head -1 | sed -E 's/.*"content"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/')"
  fi

  if [ "${obj}" = "chat.completion" ] && [ -n "${content}" ]; then
    CHAT_PASS=1
    CHAT_REASON="object=chat.completion, content=\"${content}\""
  else
    CHAT_REASON="HTTP 200 but object=\"${obj}\" or content empty"
  fi
else
  CHAT_REASON="HTTP ${chat_http}"
fi

if [ "${CHAT_PASS}" = "1" ]; then
  echo "  [PASS] ${CHAT_REASON}"
else
  echo "  [FAIL] ${CHAT_REASON}"
fi
echo ""

# ----------------------------------------------------------------------------
# 3. POST /v1/responses
# ----------------------------------------------------------------------------
echo "== POST ${BASE_URL}/responses =="
responses_http="$(curl -sS -o /tmp/akses-satu-responses.json -w "%{http_code}" \
  -H "Authorization: Bearer ${AKSES_SATU_API_KEY}" \
  -H "Content-Type: application/json" \
  -X POST "${BASE_URL}/responses" \
  -d "{\"model\":\"${MODEL}\",\"input\":\"Jawab hanya satu kata: BERHASIL\"}" \
  || true)"

if [ "${responses_http}" = "200" ]; then
  # Honest classification: a responses API should have output / output_text.
  # If it returns a model list, that is a provider misrouting, not a PASS.
  if command -v jq >/dev/null 2>&1; then
    has_output="$(jq -r 'if (.output != null) or (.output_text != null) then "yes" else "no" end' /tmp/akses-satu-responses.json 2>/dev/null || echo "no")"
    is_model_list="$(jq -r 'if (.data != null) and (.object == "list") then "yes" else "no" end' /tmp/akses-satu-responses.json 2>/dev/null || echo "no")"
  else
    if grep -qE '"output"|"output_text"' /tmp/akses-satu-responses.json; then has_output="yes"; else has_output="no"; fi
    if grep -qE '"data"' /tmp/akses-satu-responses.json; then is_model_list="yes"; else is_model_list="no"; fi
  fi

  if [ "${is_model_list}" = "yes" ]; then
    RESPONSES_OUTCOME="FAIL_PROVIDER_MISROUTE"
    echo "  [FAIL_PROVIDER_MISROUTE] /responses returned a model list instead of a response payload"
  elif [ "${has_output}" = "yes" ]; then
    RESPONSES_OUTCOME="PASS"
    echo "  [PASS] response payload contains output / output_text"
  else
    RESPONSES_OUTCOME="PARTIAL"
    echo "  [PARTIAL] HTTP 200 but no output / output_text field found in payload"
  fi
else
  RESPONSES_OUTCOME="FAIL_HTTP_${responses_http}"
  echo "  [FAIL] HTTP ${responses_http}"
fi
echo ""

# ----------------------------------------------------------------------------
# Summary
# ----------------------------------------------------------------------------
echo "== Summary =="
if [ "${CHAT_PASS}" = "1" ]; then
  echo "  chat/completions: PASS"
else
  echo "  chat/completions: FAIL (${CHAT_REASON})"
fi
echo "  /models:          $([ "${MODELS_PASS}" = "1" ] && echo "PASS" || echo "FAIL")"
echo "  /responses:       ${RESPONSES_OUTCOME}"

# Clean up tmp files (do not log contents; keys are not in them anyway).
rm -f /tmp/akses-satu-models.json /tmp/akses-satu-chat.json /tmp/akses-satu-responses.json

if [ "${CHAT_PASS}" != "1" ]; then
  exit 2
fi
if [ "${RESPONSES_OUTCOME}" = "FAIL_HTTP_"* ]; then
  exit 3
fi
exit 0
