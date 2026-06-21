import { describe, expect, it } from 'vitest';
import { readdirSync, readFileSync, statSync } from 'node:fs';
import { join } from 'node:path';

const repoRoot = process.cwd();
const skillsDir = join(repoRoot, 'skills');

function frontmatterFor(markdown: string): string | null {
  if (!markdown.startsWith('---\n')) return null;
  const end = markdown.indexOf('\n---', 4);
  if (end === -1) return null;
  return markdown.slice(4, end);
}

function field(frontmatter: string, key: string): string | null {
  const match = frontmatter.match(new RegExp(`^${key}:\\s*(.+?)\\s*$`, 'm'));
  return match?.[1]?.trim().replace(/^["']|["']$/g, '') ?? null;
}

describe('source skills manifest', () => {
  const skillFolders = readdirSync(skillsDir)
    .filter((name) => statSync(join(skillsDir, name)).isDirectory())
    .sort();

  it('has source skill folders', () => {
    expect(skillFolders.length).toBeGreaterThan(0);
  });

  it('has valid SKILL.md frontmatter for every source skill', () => {
    const names = new Set<string>();

    for (const folderName of skillFolders) {
      const skillPath = join(skillsDir, folderName, 'SKILL.md');
      const markdown = readFileSync(skillPath, 'utf8');
      const frontmatter = frontmatterFor(markdown);

      expect(frontmatter, `${folderName} frontmatter`).not.toBeNull();
      const name = field(frontmatter!, 'name');
      const description = field(frontmatter!, 'description');

      expect(name, `${folderName} name`).toBe(folderName);
      expect(description, `${folderName} description`).toBeTruthy();
      expect(names.has(name!), `${folderName} duplicate name`).toBe(false);
      names.add(name!);
    }

    expect(names.size).toBe(skillFolders.length);
  });
});
