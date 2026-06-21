export const AKSES_SATU_API_PROVIDER_ID = 'akses-satu-api';
export const AKSES_SATU_API_NAME = 'Akses Satu Api';
export const AKSES_SATU_API_KEY_ENV = 'AKSES_SATU_API_KEY';
export const AKSES_SATU_BASE_URL_ENV = 'AKSES_SATU_BASE_URL';
export const AKSES_SATU_DEFAULT_MODEL_ENV = 'AKSES_SATU_DEFAULT_MODEL';
export const AKSES_SATU_DEFAULT_BASE_URL = 'https://api.satuakses.top/v1';
export const AKSES_SATU_DEFAULT_MODEL = 'gpt-5.5';

export const AKSES_SATU_MODELS = [
  'gpt-5.5',
  'claude-opus-4.8',
  'minimax-m3',
  'mimo-v2.5-pro',
  'deepseek-v4-pro',
] as const;

export const AKSES_SATU_ENDPOINTS = {
  models: '/models',
  chatCompletions: '/chat/completions',
  responses: '/responses',
} as const;

export type AksesSatuModel = (typeof AKSES_SATU_MODELS)[number];

export interface AksesSatuApiProvider {
  id: typeof AKSES_SATU_API_PROVIDER_ID;
  name: typeof AKSES_SATU_API_NAME;
  type: 'openai-compatible';
  baseURL: string;
  apiKeyEnv: typeof AKSES_SATU_API_KEY_ENV;
  defaultModel: string;
  models: readonly string[];
  endpoints: typeof AKSES_SATU_ENDPOINTS;
}

export interface ChatMessage {
  role: 'system' | 'developer' | 'user' | 'assistant' | 'tool';
  content: string | Array<Record<string, unknown>>;
  name?: string;
  tool_call_id?: string;
}

export interface AksesSatuClientOptions {
  env?: NodeJS.ProcessEnv;
  fetchImpl?: typeof fetch;
  timeoutMs?: number;
}

export interface AksesSatuChatCompletionParams {
  model?: string;
  messages: ChatMessage[];
  stream?: boolean;
  [key: string]: unknown;
}

export interface AksesSatuResponseParams {
  model?: string;
  input: string | unknown[] | Record<string, unknown>;
  previous_response_id?: string;
  [key: string]: unknown;
}

export interface AksesSatuModelListOptions extends AksesSatuClientOptions {
  fallbackOnFailure?: boolean;
}

export class AksesSatuApiError extends Error {
  readonly status?: number;
  readonly code: string;

  constructor(message: string, code: string, status?: number) {
    super(message);
    this.name = 'AksesSatuApiError';
    this.code = code;
    this.status = status;
  }
}

export function getAksesSatuApiProvider(env: NodeJS.ProcessEnv = process.env): AksesSatuApiProvider {
  return {
    id: AKSES_SATU_API_PROVIDER_ID,
    name: AKSES_SATU_API_NAME,
    type: 'openai-compatible',
    baseURL: env[AKSES_SATU_BASE_URL_ENV] ?? AKSES_SATU_DEFAULT_BASE_URL,
    apiKeyEnv: AKSES_SATU_API_KEY_ENV,
    defaultModel: env[AKSES_SATU_DEFAULT_MODEL_ENV] ?? AKSES_SATU_DEFAULT_MODEL,
    models: AKSES_SATU_MODELS,
    endpoints: AKSES_SATU_ENDPOINTS,
  };
}

export const aksesSatuApiProvider = getAksesSatuApiProvider();

function normalizeBaseURL(baseURL: string): string {
  return baseURL.replace(/\/+$/, '');
}

function resolveApiKey(env: NodeJS.ProcessEnv): string {
  const apiKey = env[AKSES_SATU_API_KEY_ENV]?.trim();
  if (!apiKey) {
    throw new AksesSatuApiError(
      'AKSES_SATU_API_KEY belum diset. Tambahkan ke environment atau .env lokal.',
      'missing_api_key',
      401,
    );
  }
  return apiKey;
}

function resolveFetch(fetchImpl?: typeof fetch): typeof fetch {
  const resolvedFetch = fetchImpl ?? globalThis.fetch;
  if (!resolvedFetch) {
    throw new AksesSatuApiError('Fetch API tidak tersedia di runtime ini.', 'fetch_unavailable');
  }
  return resolvedFetch;
}

function endpointUrl(path: string, env: NodeJS.ProcessEnv): string {
  return `${normalizeBaseURL(env[AKSES_SATU_BASE_URL_ENV] ?? AKSES_SATU_DEFAULT_BASE_URL)}${path}`;
}

function timeoutSignal(timeoutMs: number): AbortSignal {
  const controller = new AbortController();
  setTimeout(() => controller.abort(), timeoutMs).unref?.();
  return controller.signal;
}

async function parseJsonResponse(response: Response): Promise<unknown> {
  const text = await response.text();
  if (!text) return null;

  try {
    return JSON.parse(text) as unknown;
  } catch {
    throw new AksesSatuApiError('Respons Akses Satu Api bukan JSON valid.', 'invalid_json', response.status);
  }
}

function errorMessageForStatus(status: number): { code: string; message: string } {
  if (status === 401) {
    return { code: 'unauthorized', message: 'Akses Satu Api menolak request. Periksa AKSES_SATU_API_KEY.' };
  }
  if (status === 404) {
    return { code: 'not_found', message: 'Endpoint Akses Satu Api tidak ditemukan. Periksa base URL dan path endpoint.' };
  }
  if (status === 429) {
    return { code: 'rate_limited', message: 'Akses Satu Api rate limit. Coba lagi nanti.' };
  }
  if (status >= 500) {
    return { code: 'provider_error', message: 'Akses Satu Api sedang mengembalikan error server.' };
  }
  return { code: 'request_failed', message: `Request Akses Satu Api gagal dengan status ${status}.` };
}

async function requestAksesSatuJson<T>(
  path: string,
  init: Omit<RequestInit, 'headers'>,
  options: AksesSatuClientOptions = {},
): Promise<T> {
  const env = options.env ?? process.env;
  const apiKey = resolveApiKey(env);
  const fetchImpl = resolveFetch(options.fetchImpl);
  const timeoutMs = options.timeoutMs ?? 30_000;

  let response: Response;
  try {
    response = await fetchImpl(endpointUrl(path, env), {
      ...init,
      signal: init.signal ?? timeoutSignal(timeoutMs),
      headers: {
        Authorization: `Bearer ${apiKey}`,
        ...(init.body ? { 'Content-Type': 'application/json' } : {}),
      },
    });
  } catch (error) {
    if (error instanceof Error && error.name === 'AbortError') {
      throw new AksesSatuApiError('Request Akses Satu Api timeout.', 'timeout');
    }
    throw new AksesSatuApiError('Network error saat menghubungi Akses Satu Api.', 'network_error');
  }

  if (!response.ok) {
    const { code, message } = errorMessageForStatus(response.status);
    throw new AksesSatuApiError(message, code, response.status);
  }

  return (await parseJsonResponse(response)) as T;
}

function modelFromResponseItem(item: unknown): string | null {
  if (typeof item === 'string') return item;
  if (!item || typeof item !== 'object') return null;
  const maybeId = (item as { id?: unknown }).id;
  return typeof maybeId === 'string' && maybeId.trim() ? maybeId : null;
}

function modelsFromPayload(payload: unknown): string[] {
  if (Array.isArray(payload)) {
    return payload.map(modelFromResponseItem).filter((model): model is string => Boolean(model));
  }

  if (payload && typeof payload === 'object') {
    const data = (payload as { data?: unknown }).data;
    if (Array.isArray(data)) {
      return data.map(modelFromResponseItem).filter((model): model is string => Boolean(model));
    }
  }

  throw new AksesSatuApiError('Format daftar model Akses Satu Api tidak valid.', 'invalid_model_list');
}

export async function listAksesSatuModels(options: AksesSatuClientOptions = {}): Promise<string[]> {
  const payload = await requestAksesSatuJson<unknown>(AKSES_SATU_ENDPOINTS.models, { method: 'GET' }, options);
  return modelsFromPayload(payload);
}

export async function getAksesSatuModelChoices(options: AksesSatuModelListOptions = {}): Promise<string[]> {
  try {
    const models = await listAksesSatuModels(options);
    return models.length > 0 ? models : [...AKSES_SATU_MODELS];
  } catch (error) {
    if (
      error instanceof AksesSatuApiError &&
      (error.code === 'missing_api_key' || error.code === 'unauthorized')
    ) {
      throw error;
    }
    if (options.fallbackOnFailure ?? true) {
      return [...AKSES_SATU_MODELS];
    }
    throw error;
  }
}

export async function createAksesSatuChatCompletion<T = unknown>(
  params: AksesSatuChatCompletionParams,
  options: AksesSatuClientOptions = {},
): Promise<T> {
  const env = options.env ?? process.env;
  const model = params.model ?? getAksesSatuApiProvider(env).defaultModel;
  return requestAksesSatuJson<T>(
    AKSES_SATU_ENDPOINTS.chatCompletions,
    {
      method: 'POST',
      body: JSON.stringify({ ...params, model, stream: params.stream ?? false }),
    },
    options,
  );
}

export async function createAksesSatuResponse<T = unknown>(
  params: AksesSatuResponseParams,
  options: AksesSatuClientOptions = {},
): Promise<T> {
  const env = options.env ?? process.env;
  const model = params.model ?? getAksesSatuApiProvider(env).defaultModel;
  return requestAksesSatuJson<T>(
    AKSES_SATU_ENDPOINTS.responses,
    {
      method: 'POST',
      body: JSON.stringify({ ...params, model }),
    },
    options,
  );
}
