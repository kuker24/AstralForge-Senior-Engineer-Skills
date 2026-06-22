import { describe, expect, it, vi } from 'vitest';
import { readFileSync, statSync } from 'node:fs';
import { join } from 'node:path';
import {
  AKSES_SATU_API_PROVIDER_ID,
  AKSES_SATU_CONFIGURED_MODELS,
  AKSES_SATU_DEFAULT_BASE_URL,
  AKSES_SATU_DEFAULT_MODEL,
  AKSES_SATU_ENDPOINTS,
  AKSES_SATU_MODELS,
  AKSES_SATU_VERIFIED_LIVE_MODELS,
  AksesSatuApiError,
  createAksesSatuChatCompletion,
  createAksesSatuResponse,
  customProviders,
  getAksesSatuApiProvider,
  getAksesSatuModelChoices,
  listAksesSatuModels,
} from '../src/providers';

const env = {
  AKSES_SATU_API_KEY: 'test-api-key-not-secret',
  AKSES_SATU_BASE_URL: AKSES_SATU_DEFAULT_BASE_URL,
  AKSES_SATU_DEFAULT_MODEL: AKSES_SATU_DEFAULT_MODEL,
};

function jsonResponse(payload: unknown, status = 200): Response {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}

function firstRequest(fetchMock: ReturnType<typeof vi.fn>) {
  const call = fetchMock.mock.calls[0];
  if (!call) throw new Error('fetch was not called');
  return {
    url: call[0] as string,
    init: call[1] as RequestInit,
  };
}

function headersFrom(init: RequestInit): Record<string, string> {
  return init.headers as Record<string, string>;
}

const EXPECTED_UNION = [
  'glm-4.6',
  'claude-sonnet-4.6',
  'cipher',
  'idsa-v1.0',
  'google-gemma-2-9b-it',
  'mimo-v2.5',
  'claude-opus-4.8',
  'gpt-5.5',
  'minimax-m3',
  'mimo-v2.5-pro',
  'deepseek-v4-pro',
];

describe('Akses Satu Api custom provider', () => {
  it('appears in the internal provider registry', () => {
    expect(customProviders.some((provider) => provider.id === AKSES_SATU_API_PROVIDER_ID)).toBe(true);
  });

  it('has the expected default model and full model union', () => {
    const provider = getAksesSatuApiProvider(env);

    expect(provider).toMatchObject({
      id: 'akses-satu-api',
      name: 'Akses Satu Api',
      type: 'openai-compatible',
      baseURL: 'https://api.satuakses.top/v1',
      apiKeyEnv: 'AKSES_SATU_API_KEY',
      defaultModel: 'glm-4.6',
      endpoints: AKSES_SATU_ENDPOINTS,
    });
    expect(provider.models).toEqual(EXPECTED_UNION);
    expect(provider.verifiedLiveModels).toEqual([...AKSES_SATU_VERIFIED_LIVE_MODELS]);
    expect(provider.configuredModels).toEqual([...AKSES_SATU_CONFIGURED_MODELS]);
  });

  it('exposes the verified-live and configured-only model lists separately', () => {
    // All 11 union models were verified live on 2026-06-22.
    expect(AKSES_SATU_VERIFIED_LIVE_MODELS).toContain('glm-4.6');
    expect(AKSES_SATU_VERIFIED_LIVE_MODELS).toContain('claude-opus-4.8');
    expect(AKSES_SATU_VERIFIED_LIVE_MODELS).toContain('gpt-5.5');
    expect(AKSES_SATU_VERIFIED_LIVE_MODELS).toContain('minimax-m3');
    expect(AKSES_SATU_VERIFIED_LIVE_MODELS).toContain('mimo-v2.5-pro');
    expect(AKSES_SATU_VERIFIED_LIVE_MODELS).toContain('deepseek-v4-pro');
    expect(AKSES_SATU_VERIFIED_LIVE_MODELS.length).toBe(11);

    // No configured-only models remain (all 11 are verified live).
    expect(AKSES_SATU_CONFIGURED_MODELS.length).toBe(0);
  });

  it('keeps the model union deduplicated (verified-live + configured-only)', () => {
    const setFromUnion = new Set(AKSES_SATU_MODELS);
    expect(setFromUnion.size).toBe(AKSES_SATU_MODELS.length);
    expect(AKSES_SATU_MODELS.length).toBe(11);
    // verified-live + configured-only = 11, no duplicates.
    expect(AKSES_SATU_VERIFIED_LIVE_MODELS.length + AKSES_SATU_CONFIGURED_MODELS.length).toBe(11);
  });

  it('treats all 11 union models as verified live (2026-06-22 test pass)', () => {
    // This guards against accidental demotion of newly-verified models.
    for (const m of AKSES_SATU_MODELS) {
      expect(AKSES_SATU_VERIFIED_LIVE_MODELS).toContain(m);
    }
  });

  it('lists models from GET /models with the correct URL and bearer auth', async () => {
    const fetchMock = vi.fn(async () => jsonResponse({ data: [{ id: 'api-model' }] }));

    await expect(listAksesSatuModels({ env, fetchImpl: fetchMock })).resolves.toEqual(['api-model']);

    const request = firstRequest(fetchMock);
    expect(request.url).toBe('https://api.satuakses.top/v1/models');
    expect(request.init.method).toBe('GET');
    expect(headersFrom(request.init).Authorization).toBe('Bearer test-api-key-not-secret');
  });

  it('falls back to the static model union if GET /models fails with a non-auth error', async () => {
    const fetchMock = vi.fn(async () => jsonResponse({ error: 'temporary' }, 500));

    await expect(getAksesSatuModelChoices({ env, fetchImpl: fetchMock })).resolves.toEqual(EXPECTED_UNION);
  });

  it('does not hide 401 auth failures behind the static model fallback', async () => {
    const fetchMock = vi.fn(async () => jsonResponse({ error: 'unauthorized' }, 401));

    await expect(getAksesSatuModelChoices({ env, fetchImpl: fetchMock })).rejects.toMatchObject({
      code: 'unauthorized',
      status: 401,
    });
  });

  it('posts chat completions to /chat/completions with selected model and messages', async () => {
    const fetchMock = vi.fn(async () => jsonResponse({ id: 'chatcmpl-test' }));

    await createAksesSatuChatCompletion(
      { model: 'minimax-m3', messages: [{ role: 'user', content: 'Halo!' }] },
      { env, fetchImpl: fetchMock },
    );

    const request = firstRequest(fetchMock);
    expect(request.url).toBe('https://api.satuakses.top/v1/chat/completions');
    expect(request.init.method).toBe('POST');
    expect(headersFrom(request.init).Authorization).toBe('Bearer test-api-key-not-secret');
    expect(headersFrom(request.init)['Content-Type']).toBe('application/json');
    expect(JSON.parse(request.init.body as string)).toEqual({
      model: 'minimax-m3',
      messages: [{ role: 'user', content: 'Halo!' }],
      stream: false,
    });
  });

  it('defaults chat completions to glm-4.6 when no model is given', async () => {
    const fetchMock = vi.fn(async () => jsonResponse({ id: 'chatcmpl-test' }));

    await createAksesSatuChatCompletion(
      { messages: [{ role: 'user', content: 'Halo!' }] },
      { env, fetchImpl: fetchMock },
    );

    const request = firstRequest(fetchMock);
    expect(JSON.parse(request.init.body as string).model).toBe('glm-4.6');
  });

  it('posts Responses API requests to /responses with selected model and input', async () => {
    const fetchMock = vi.fn(async () => jsonResponse({ id: 'resp-test' }));

    await createAksesSatuResponse(
      { model: 'deepseek-v4-pro', input: 'Jelaskan API gateway', previous_response_id: 'resp-prev' },
      { env, fetchImpl: fetchMock },
    );

    const request = firstRequest(fetchMock);
    expect(request.url).toBe('https://api.satuakses.top/v1/responses');
    expect(request.init.method).toBe('POST');
    expect(headersFrom(request.init).Authorization).toBe('Bearer test-api-key-not-secret');
    expect(JSON.parse(request.init.body as string)).toEqual({
      model: 'deepseek-v4-pro',
      input: 'Jelaskan API gateway',
      previous_response_id: 'resp-prev',
    });
  });

  it('throws a clear error when AKSES_SATU_API_KEY is missing', async () => {
    const fetchMock = vi.fn();

    await expect(listAksesSatuModels({ env: {}, fetchImpl: fetchMock })).rejects.toMatchObject({
      name: 'AksesSatuApiError',
      code: 'missing_api_key',
      message: 'AKSES_SATU_API_KEY belum diset. Tambahkan ke environment atau .env lokal.',
    } satisfies Partial<AksesSatuApiError>);
    expect(fetchMock).not.toHaveBeenCalled();
  });

  it('does not print API keys or Authorization headers while making requests', async () => {
    const fetchMock = vi.fn(async () => jsonResponse({ id: 'chatcmpl-test' }));
    const logSpy = vi.spyOn(console, 'log').mockImplementation(() => undefined);
    const errorSpy = vi.spyOn(console, 'error').mockImplementation(() => undefined);

    try {
      await createAksesSatuChatCompletion(
        { messages: [{ role: 'user', content: 'Halo!' }] },
        { env, fetchImpl: fetchMock },
      );
    } finally {
      logSpy.mockRestore();
      errorSpy.mockRestore();
    }

    const printed = [...logSpy.mock.calls, ...errorSpy.mock.calls].flat().join(' ');
    expect(printed).not.toContain('Authorization');
    expect(printed).not.toContain('test-api-key-not-secret');
  });

  it('is present in the Pi installer models config with the full model union', () => {
    const modelsConfig = JSON.parse(readFileSync(join(process.cwd(), 'installer/config/models.json'), 'utf8')) as {
      providers: Record<string, { apiKey?: string; baseUrl?: string; api?: string; authHeader?: boolean; models?: Array<{ id: string }> }>;
    };
    const provider = modelsConfig.providers['akses-satu-api'];

    expect(provider).toBeTruthy();
    expect(provider.baseUrl).toBe('https://api.satuakses.top/v1');
    expect(provider.apiKey).toBe('$AKSES_SATU_API_KEY');
    expect(provider.api).toBe('openai-completions');
    expect(provider.authHeader).toBe(true);
    expect(provider.models?.map((model) => model.id)).toEqual(EXPECTED_UNION);
  });

  it('enables verified-live akses-satu-api models in installer settings.json', () => {
    const settings = JSON.parse(readFileSync(join(process.cwd(), 'installer/config/settings.json'), 'utf8')) as {
      enabledModels?: string[];
    };
    const enabled = settings.enabledModels ?? [];

    expect(enabled).toContain('akses-satu-api/glm-4.6');
    expect(enabled).toContain('akses-satu-api/claude-sonnet-4.6');
    expect(enabled).toContain('akses-satu-api/cipher');
    expect(enabled).toContain('akses-satu-api/idsa-v1.0');
    expect(enabled).toContain('akses-satu-api/google-gemma-2-9b-it');
    expect(enabled).toContain('akses-satu-api/mimo-v2.5');
    expect(enabled).toContain('akses-satu-api/claude-opus-4.8');
  });

  it('keeps .env.example as a placeholder, not a real-looking key', () => {
    const envExample = readFileSync(join(process.cwd(), '.env.example'), 'utf8');

    expect(envExample).toContain('AKSES_SATU_API_KEY=sk-sa-REPLACE_ME');
    expect(envExample).toContain('AKSES_SATU_BASE_URL=https://api.satuakses.top/v1');
    expect(envExample).toContain('AKSES_SATU_DEFAULT_MODEL=glm-4.6');
    // Must not contain common real-key shapes.
    expect(envExample).not.toMatch(/sk-ant-/);
    expect(envExample).not.toMatch(/sk-proj-/);
    expect(envExample).not.toMatch(/sk-or-/);
    expect(envExample).not.toMatch(/AIza[0-9A-Za-z_-]{20,}/);
  });

  it('has a runnable Pi launcher script that redacts the API key', () => {
    const launcherPath = join(process.cwd(), 'scripts/run-pi-akses-satu.sh');
    const stat = statSync(launcherPath);
    // Executable bit for owner.
    expect(stat.mode & 0o100).toBeGreaterThan(0);
    const contents = readFileSync(launcherPath, 'utf8');
    expect(contents.startsWith('#!/')).toBe(true);
    expect(contents).toContain('[REDACTED]');
    // The script must not contain a real-looking API key shape.
    expect(contents).not.toMatch(/sk-ant-[A-Za-z0-9_-]{20,}/);
    expect(contents).not.toMatch(/sk-proj-[A-Za-z0-9_-]{20,}/);
    expect(contents).not.toMatch(/sk-or-[A-Za-z0-9_-]{20,}/);
    expect(contents).toContain('--provider');
    expect(contents).toContain('--model');
  });

  it('has a manual API test script that calls the real endpoints', () => {
    const testScriptPath = join(process.cwd(), 'scripts/test-akses-satu-api.sh');
    const stat = statSync(testScriptPath);
    expect(stat.mode & 0o100).toBeGreaterThan(0);
    const contents = readFileSync(testScriptPath, 'utf8');
    expect(contents.startsWith('#!/')).toBe(true);
    // The chat section must POST to /chat/completions (the prior bug was hitting /models).
    expect(contents).toContain('/chat/completions');
    expect(contents).toContain('/models');
    expect(contents).toContain('/responses');
    // No raw key printing.
    expect(contents).not.toMatch(/\$\{?AKSES_SATU_API_KEY\}?[^\n]*echo/);
    expect(contents).toContain('[REDACTED]');
  });

  it('ships a Pi extension that registers the provider via pi.registerProvider', () => {
    const extPath = join(process.cwd(), 'extensions/akses-satu-api-provider/index.ts');
    const contents = readFileSync(extPath, 'utf8');
    expect(contents).toContain('registerProvider');
    expect(contents).toContain('akses-satu-api');
    expect(contents).toContain('https://api.satuakses.top/v1');
    expect(contents).toContain('$AKSES_SATU_API_KEY');
    expect(contents).toContain('glm-4.6');
    // Must not log auth headers.
    expect(contents).not.toMatch(/console\.log.*[Aa]uthorization/);
  });
});
