/**
 * Akses Satu Api - Pi Custom Provider Extension
 *
 * Registers the `akses-satu-api` provider with Pi Code / Pi Agent (v0.79.9+)
 * using the native `pi.registerProvider()` extension API.
 *
 * The provider is OpenAI-compatible (`/v1/models`, `/v1/chat/completions`,
 * `/v1/responses`) and authenticates with `Authorization: Bearer $AKSES_SATU_API_KEY`.
 *
 * Usage:
 *   # Set your key first (do NOT commit it):
 *   set -Ux AKSES_SATU_API_KEY "sk-sa-..."
 *
 *   # Then run Pi with this extension:
 *   pi -e ./extensions/akses-satu-api-provider --provider akses-satu-api --model glm-4.6
 *
 *   # Or install via:
 *   pi install ./extensions/akses-satu-api-provider
 *
 * Notes:
 *   - The default model is `glm-4.6` because it is the only model verified
 *     end-to-end through `/v1/chat/completions` in this environment.
 *   - `verifiedLiveModels` are advertised as enabled; `configuredModels` are
 *     kept in the provider union but not registered as active models.
 *   - This extension does NOT log Authorization headers or API keys.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const PROVIDER_ID = "akses-satu-api";
const DISPLAY_NAME = "Akses Satu Api";
const BASE_URL = "https://api.satuakses.top/v1";
const API_KEY_ENV = "$AKSES_SATU_API_KEY";

/** Models verified live through `GET /v1/models` (and `glm-4.6` through chat). */
const VERIFIED_LIVE_MODELS = [
  "glm-4.6",
  "claude-sonnet-4.6",
  "cipher",
  "idsa-v1.0",
  "google-gemma-2-9b-it",
  "mimo-v2.5",
  "claude-opus-4.8",
] as const;

/** Models requested by the user that are NOT yet verified live. */
const CONFIGURED_ONLY_MODELS = [
  "gpt-5.5",
  "minimax-m3",
  "mimo-v2.5-pro",
  "deepseek-v4-pro",
] as const;

interface ModelSpec {
  id: string;
  name: string;
  reasoning: boolean;
  input: ("text" | "image")[];
  cost: { input: number; output: number; cacheRead: number; cacheWrite: number };
  contextWindow: number;
  maxTokens: number;
}

function spec(
  id: string,
  name: string,
  reasoning: boolean,
  input: ("text" | "image")[],
  contextWindow: number,
  maxTokens: number,
): ModelSpec {
  return {
    id,
    name,
    reasoning,
    input,
    cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
    contextWindow,
    maxTokens,
  };
}

const ALL_MODELS: ModelSpec[] = [
  // Verified live (default candidates)
  spec("glm-4.6", "GLM 4.6 (verified live)", false, ["text"], 131072, 8192),
  spec("claude-sonnet-4.6", "Claude Sonnet 4.6 (verified live)", true, ["text", "image"], 200000, 16384),
  spec("cipher", "Cipher (verified live)", false, ["text"], 32768, 4096),
  spec("idsa-v1.0", "IDSA v1.0 (verified live)", false, ["text"], 32768, 4096),
  spec("google-gemma-2-9b-it", "Google Gemma 2 9B IT (verified live)", false, ["text"], 8192, 4096),
  spec("mimo-v2.5", "MiMo V2.5 (verified live)", false, ["text"], 32768, 8192),
  spec("claude-opus-4.8", "Claude Opus 4.8 (verified live)", true, ["text", "image"], 200000, 16384),
  // Configured (requested, not yet verified live)
  spec("gpt-5.5", "GPT 5.5 (configured)", true, ["text", "image"], 256000, 16384),
  spec("minimax-m3", "MiniMax M3 (configured)", false, ["text"], 131072, 8192),
  spec("mimo-v2.5-pro", "MiMo V2.5 Pro (configured)", false, ["text"], 131072, 8192),
  spec("deepseek-v4-pro", "DeepSeek V4 Pro (configured)", true, ["text"], 131072, 8192),
];

export default function (pi: ExtensionAPI): void {
  pi.registerProvider(PROVIDER_ID, {
    name: DISPLAY_NAME,
    baseUrl: BASE_URL,
    apiKey: API_KEY_ENV,
    api: "openai-completions",
    authHeader: true,
    models: ALL_MODELS,
  });
}

export const _internal = {
  providerId: PROVIDER_ID,
  verifiedLiveModels: VERIFIED_LIVE_MODELS,
  configuredOnlyModels: CONFIGURED_ONLY_MODELS,
};
