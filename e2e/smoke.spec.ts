import { test } from '@playwright/test';

test('homepage loads when a local app server is configured', async ({ page }) => {
  test.skip(true, 'This repository is a portable AI-skill/tooling package, not a runnable web app yet. Configure baseURL/webServer before enabling this smoke test.');

  await page.goto('/');
});
