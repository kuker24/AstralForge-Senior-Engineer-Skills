/**
 * Akses Satu Api - Pi Custom Provider Extension (installer copy)
 *
 * This file is mirrored into `installer/extensions/akses-satu-api-provider/`
 * so that the Pi installer (`installer/install-pi-linux.sh` /
 * `install-pi-windows.ps1`) can install it as a managed extension into
 * `~/.pi/agent/extensions/`.
 *
 * Source of truth: `extensions/akses-satu-api-provider/index.ts` in the repo
 * root. Keep both copies in sync.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const PROVIDER_ID = "akses-satu-api";
const DISPLAY_NAME = "Akses Satu Api";
const BASE_URL = "https://api.satuakses.top/v1";
const API_KEY_ENV = "$AKSES_SATU_API_KEY";

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
  spec("glm-4.6", "GLM 4.6 (verified live)", false, ["text"], 131072, 8192),
  spec("claude-sonnet-4.6", "Claude Sonnet 4.6 (verified live)", true, ["text", "image"], 200000, 16384),
  spec("cipher", "Cipher (verified live)", false, ["text"], 32768, 4096),
  spec("idsa-v1.0", "IDSA v1.0 (verified live)", false, ["text"], 32768, 4096),
  spec("google-gemma-2-9b-it", "Google Gemma 2 9B IT (verified live)", false, ["text"], 8192, 4096),
  spec("mimo-v2.5", "MiMo V2.5 (verified live)", false, ["text"], 32768, 8192),
  spec("claude-opus-4.8", "Claude Opus 4.8 (verified live)", true, ["text", "image"], 200000, 16384),
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
