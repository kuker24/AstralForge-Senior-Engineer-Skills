import { describe, expect, it, vi } from 'vitest';
import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import {
  AKSES_SATU_API_PROVIDER_ID,
  AKSES_SATU_DEFAULT_BASE_URL,
  AKSES_SATU_DEFAULT_MODEL,
  AKSES_SATU_ENDPOINTS,
  AKSES_SATU_MODELS,
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

describe('Akses Satu Api custom provider', () => {
  it('appears in the internal provider registry', () => {
    expect(customProviders.some((provider) => provider.id === AKSES_SATU_API_PROVIDER_ID)).toBe(true);
  });

  it('has the expected default model and static fallback model list', () => {
    const provider = getAksesSatuApiProvider(env);

    expect(provider).toMatchObject({
      id: 'akses-satu-api',
      name: 'Akses Satu Api',
      type: 'openai-compatible',
      baseURL: 'https://api.satuakses.top/v1',
      apiKeyEnv: 'AKSES_SATU_API_KEY',
      defaultModel: 'gpt-5.5',
      endpoints: AKSES_SATU_ENDPOINTS,
    });
    expect(provider.models).toEqual([...AKSES_SATU_MODELS]);
  });

  it('lists models from GET /models with the correct URL and bearer auth', async () => {
    const fetchMock = vi.fn(async () => jsonResponse({ data: [{ id: 'api-model' }] }));

    await expect(listAksesSatuModels({ env, fetchImpl: fetchMock })).resolves.toEqual(['api-model']);

    const request = firstRequest(fetchMock);
    expect(request.url).toBe('https://api.satuakses.top/v1/models');
    expect(request.init.method).toBe('GET');
    expect(headersFrom(request.init).Authorization).toBe('Bearer test-api-key-not-secret');
  });

  it('falls back to the static five-model list if GET /models fails with a non-auth error', async () => {
    const fetchMock = vi.fn(async () => jsonResponse({ error: 'temporary' }, 500));

    await expect(getAksesSatuModelChoices({ env, fetchImpl: fetchMock })).resolves.toEqual([...AKSES_SATU_MODELS]);
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

  it('is present in the Pi installer models config without hardcoded credentials', () => {
    const modelsConfig = JSON.parse(readFileSync(join(process.cwd(), 'installer/config/models.json'), 'utf8')) as {
      providers: Record<string, { apiKey?: string; baseUrl?: string; api?: string; models?: Array<{ id: string }> }>;
    };
    const provider = modelsConfig.providers['akses-satu-api'];

    expect(provider).toBeTruthy();
    expect(provider.baseUrl).toBe('https://api.satuakses.top/v1');
    expect(provider.apiKey).toBe('$AKSES_SATU_API_KEY');
    expect(provider.api).toBe('openai-completions');
    expect(provider.models?.map((model) => model.id)).toEqual([...AKSES_SATU_MODELS]);
  });
});
