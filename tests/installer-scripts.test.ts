import { describe, expect, it } from 'vitest';
import { existsSync, readFileSync } from 'node:fs';
import { join } from 'node:path';

const repoRoot = process.cwd();

describe('installer scripts', () => {
  const requiredScripts = [
    'install.sh',
    'install-global.sh',
    'verify.sh',
    'scripts/verify-source-skills.sh',
    'installer/install-pi-linux.sh',
    'installer/install-pi-windows.ps1',
  ];

  it('has important installer and verifier scripts', () => {
    for (const scriptPath of requiredScripts) {
      expect(existsSync(join(repoRoot, scriptPath)), `${scriptPath} should exist`).toBe(true);
    }
  });

  it('uses shebangs for shell scripts', () => {
    for (const scriptPath of requiredScripts.filter((path) => path.endsWith('.sh'))) {
      const contents = readFileSync(join(repoRoot, scriptPath), 'utf8');
      expect(contents.startsWith('#!/'), `${scriptPath} should start with a shebang`).toBe(true);
    }
  });
});
