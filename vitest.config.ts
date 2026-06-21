import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
    include: ['tests/**/*.test.ts', 'tests/**/*.spec.ts', 'src/**/*.test.ts', 'src/**/*.spec.ts'],
    exclude: ['node_modules/**', 'e2e/**', 'playwright-report/**', 'test-results/**'],
    reporters: ['dot'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      reportsDirectory: './coverage',
    },
  },
});
