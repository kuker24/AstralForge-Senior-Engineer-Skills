import { describe, expect, it } from 'vitest';
import { existsSync, readFileSync } from 'node:fs';
import { join } from 'node:path';

const repoRoot = process.cwd();

describe('repository health smoke checks', () => {
  it('has core project metadata and evidence files', () => {
    for (const filePath of [
      'package.json',
      'README.md',
      'SECURITY.md',
      'reports/INDEX.md',
      'reports/python-audit.txt',
      'reports/commit-history-snapshot.txt',
    ]) {
      expect(existsSync(join(repoRoot, filePath)), filePath).toBe(true);
    }
  });

  it('keeps package scripts wired to local project scripts', () => {
    const packageJson = JSON.parse(readFileSync(join(repoRoot, 'package.json'), 'utf8')) as {
      scripts: Record<string, string>;
    };

    expect(packageJson.scripts.typecheck).toBe('tsc --noEmit');
    expect(packageJson.scripts['verify:skills']).toContain('scripts/verify-source-skills.sh');
    expect(packageJson.scripts['audit:skills']).toContain('scripts/audit-skills.sh');
    expect(packageJson.scripts['release:check-actions']).toContain('scripts/check-github-actions.sh');
  });
});
