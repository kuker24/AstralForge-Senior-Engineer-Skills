import { describe, expect, it } from 'vitest';
import { existsSync, readFileSync } from 'node:fs';
import { join } from 'node:path';

const repoRoot = process.cwd();

describe('project quality configuration', () => {
  it('keeps local reports out of git', () => {
    const gitignore = readFileSync(join(repoRoot, '.gitignore'), 'utf8');
    const requiredIgnores = [
      'semgrep-results.json',
      'osv-results.json',
      'gitleaks-report.json',
      'gitleaks-dir-report.json',
      'repomix-output.*',
      'playwright-report/',
      'test-results/',
      'coverage/',
      '.stryker-tmp/',
      'reports/mutation/',
      'mutation-report/',
    ];

    for (const pattern of requiredIgnores) {
      expect(gitignore, `.gitignore should include ${pattern}`).toContain(pattern);
    }
  });

  it('has required repository guidance files', () => {
    expect(existsSync(join(repoRoot, 'AGENTS.md'))).toBe(true);
    expect(existsSync(join(repoRoot, 'README.md'))).toBe(true);
    expect(existsSync(join(repoRoot, 'docs/adr/README.md'))).toBe(true);
    expect(existsSync(join(repoRoot, 'docs/releases/README.md'))).toBe(true);
  });

  it('has required package scripts', () => {
    const packageJson = JSON.parse(readFileSync(join(repoRoot, 'package.json'), 'utf8')) as {
      scripts?: Record<string, string>;
    };
    const scripts = packageJson.scripts ?? {};
    const requiredScripts = [
      'e2e',
      'knip',
      'test:unit',
      'test:coverage',
      'typecheck',
      'verify:skills',
      'quality:ai',
      'quality:senior',
      'mutation',
      'release:check-actions',
    ];

    for (const script of requiredScripts) {
      expect(scripts[script], `missing npm script ${script}`).toBeTruthy();
    }
  });
});
