import { describe, expect, it } from 'vitest';
import { readFileSync } from 'node:fs';
import { join } from 'node:path';

const repoRoot = process.cwd();

function read(relativePath: string): string {
  return readFileSync(join(repoRoot, relativePath), 'utf8');
}

function auditCount(verdict: string): number {
  const summary = read('reports/skill-audit-summary.md');
  const match = summary.match(new RegExp(`\\| ${verdict} \\|\\s*(\\d+) \\|`));
  if (!match) throw new Error(`Missing verdict ${verdict} in skill audit summary`);
  return Number(match[1]);
}

describe('README and evidence claims', () => {
  it('keeps README aligned with current skill audit summary', () => {
    const readme = read('README.md');
    const pass = auditCount('PASS');
    const needsReview = auditCount('NEEDS_REVIEW');
    const stub = auditCount('STUB');
    const broken = auditCount('BROKEN');

    expect(readme).toContain(`Audit substantif saat ini menemukan **${pass} PASS**, **${needsReview} NEEDS_REVIEW**, **${stub} STUB**, dan **${broken} BROKEN**`);
    expect(readme).not.toContain('| Audit PASS | 25 |');
    expect(readme).not.toContain('| Audit STUB | 12 |');
    expect(readme).not.toContain('| Audit BROKEN | 46 |');
  });

  it('links Python audit and commit history evidence', () => {
    const readme = read('README.md');

    expect(readme).toContain('reports/python-audit.txt');
    expect(readme).toContain('reports/commit-history-snapshot.txt');
  });

  it('keeps SECURITY.md limitations current without external certification claims', () => {
    const security = read('SECURITY.md');

    expect(security).not.toContain('Not every source skill is substantively verified');
    expect(security).toContain('Skill Security Auditor');
    expect(security).toContain('not an external certification');
    expect(security.toLowerCase()).not.toContain('externally certified');
  });

  it('does not keep placeholder descriptions in SKILLS_MANIFEST.md', () => {
    const manifest = read('SKILLS_MANIFEST.md');

    expect(manifest).toContain('Total source skills | 83');
    expect(manifest).not.toContain('Replace with description of the skill');
  });

  it('contains new core-tool npm scripts', () => {
    const packageJson = JSON.parse(read('package.json')) as { scripts: Record<string, string> };

    for (const scriptName of [
      'audit:skill-security',
      'pi:install-core-tools',
      'pi:verify-core-tools',
      'pi:clean-local',
      'token:report',
      'quality:core-tools',
    ]) {
      expect(packageJson.scripts[scriptName], scriptName).toBeTruthy();
    }
  });

  it('documents release/tag preservation for v3.0.0', () => {
    const docs = `${read('README.md')}\n${read('docs/tools/pi-core-tools.md')}`;

    expect(docs).toContain('v3.0.0');
    expect(docs).toContain('17ea37e');
    expect(docs).toMatch(/no tag rewrite|Do not rewrite the tag|no rewrite/i);
  });
});
