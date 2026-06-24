import { describe, expect, it } from 'vitest';
import { existsSync, readFileSync } from 'node:fs';
import { join } from 'node:path';

const repoRoot = process.cwd();

function read(relativePath: string): string {
  return readFileSync(join(repoRoot, relativePath), 'utf8');
}

function hasUnsafeCoreDefaultClaim(text: string, tool: string): boolean {
  return text
    .split('\n')
    .some((line) => {
      const lower = line.toLowerCase();
      return lower.includes(tool.toLowerCase()) && lower.includes('core default') && !/(not|bukan|jangan|intentionally|non-core)/i.test(line);
    });
}

describe('core tools and token profiles', () => {
  it('documents the core tools and profile router files', () => {
    for (const filePath of [
      'docs/tools/core-tools.md',
      'docs/tools/pi-core-tools.md',
      'profiles/minimal.md',
      'profiles/coding.md',
      'profiles/repo-review.md',
      'profiles/docs-research.md',
    ]) {
      expect(existsSync(join(repoRoot, filePath)), filePath).toBe(true);
    }
  });

  it('keeps minimal profile token-conservative', () => {
    const minimal = read('profiles/minimal.md');

    expect(minimal).toContain('Default profile');
    expect(minimal).toMatch(/Context7 MCP is off by default/i);
    expect(minimal).toMatch(/Serena is inactive by default/i);
    expect(minimal).toMatch(/Repomix is inactive by default/i);
    expect(minimal).not.toMatch(/Serena active/i);
    expect(minimal).not.toMatch(/Repomix active/i);
  });

  it('does not promote banned tools as core defaults', () => {
    const combinedDocs = `${read('docs/tools/core-tools.md')}\n${read('README.md')}`;

    for (const banned of ['hermes', 'self-healing external agent', 'random marketplace MCP', 'Playwright MCP', 'GitHub MCP']) {
      expect(hasUnsafeCoreDefaultClaim(combinedDocs, banned), banned).toBe(false);
    }
  });
});
