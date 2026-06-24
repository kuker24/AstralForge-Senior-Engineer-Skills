import { describe, expect, it } from 'vitest';
import { readdirSync, readFileSync, statSync } from 'node:fs';
import { join } from 'node:path';

const repoRoot = process.cwd();
const skillsDir = join(repoRoot, 'skills');
const forbiddenSkillPhrases = [
  'replace with description of the skill',
  'replace with description',
  'todo:',
  'tbd',
  'lorem ipsum',
  'placeholder',
];

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

function parseCsvLine(line: string): string[] {
  const columns: string[] = [];
  let current = '';
  let inQuotes = false;

  for (let index = 0; index < line.length; index += 1) {
    const char = line[index];
    const next = line[index + 1];

    if (char === '"' && inQuotes && next === '"') {
      current += '"';
      index += 1;
    } else if (char === '"') {
      inQuotes = !inQuotes;
    } else if (char === ',' && !inQuotes) {
      columns.push(current);
      current = '';
    } else {
      current += char;
    }
  }

  columns.push(current);
  return columns;
}

function auditCounts(): Record<string, number> {
  const csv = readFileSync(join(repoRoot, 'reports/skill-audit-results.csv'), 'utf8').trim().split('\n');
  const headers = parseCsvLine(csv[0]);
  const verdictIndex = headers.indexOf('verdict');
  const counts: Record<string, number> = { PASS: 0, NEEDS_REVIEW: 0, STUB: 0, BROKEN: 0 };

  expect(verdictIndex).toBeGreaterThanOrEqual(0);

  for (const line of csv.slice(1)) {
    const columns = parseCsvLine(line);
    const verdict = columns[verdictIndex];
    counts[verdict] = (counts[verdict] ?? 0) + 1;
  }
  return counts;
}

describe('source skills manifest', () => {
  it('parses quoted CSV fields with commas safely', () => {
    expect(parseCsvLine('name,notes,verdict')).toEqual(['name', 'notes', 'verdict']);
    expect(parseCsvLine('skill,"broken links: https://example.com/a,b",PASS')).toEqual([
      'skill',
      'broken links: https://example.com/a,b',
      'PASS',
    ]);
    expect(parseCsvLine('skill,"quoted ""value""",PASS')).toEqual(['skill', 'quoted "value"', 'PASS']);
  });

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

  it('has required support files for every source skill', () => {
    for (const folderName of skillFolders) {
      const agentConfig = readFileSync(join(skillsDir, folderName, 'agents/openai.yaml'), 'utf8');
      const sources = readFileSync(join(skillsDir, folderName, 'references/sources.md'), 'utf8');

      expect(agentConfig.trim(), `${folderName} agents/openai.yaml`).toBeTruthy();
      expect(sources.trim(), `${folderName} references/sources.md`).toBeTruthy();
      expect(sources, `${folderName} references heading`).toContain('# Sources & References');
    }
  });

  it('does not contain unfinished marker phrases in source skill bodies', () => {
    for (const folderName of skillFolders) {
      const markdown = readFileSync(join(skillsDir, folderName, 'SKILL.md'), 'utf8').toLowerCase();
      for (const phrase of forbiddenSkillPhrases) {
        expect(markdown, `${folderName} contains forbidden phrase ${phrase}`).not.toContain(phrase);
      }
    }
  });

  it('keeps SKILLS_MANIFEST.md source count aligned with skills directory', () => {
    const manifest = readFileSync(join(repoRoot, 'SKILLS_MANIFEST.md'), 'utf8');
    expect(manifest).toContain(`Total source skills | ${skillFolders.length}`);
    expect(manifest).toContain(`Skills with \`SKILL.md\` | ${skillFolders.length}`);
    expect(manifest).toContain(`Unique frontmatter names | ${skillFolders.length}`);
  });

  it('keeps README audit status aligned with generated audit output', () => {
    const counts = auditCounts();
    const total = skillFolders.length;
    const readme = readFileSync(join(repoRoot, 'README.md'), 'utf8');

    expect(counts.PASS).toBe(total);
    expect(counts.NEEDS_REVIEW).toBe(0);
    expect(counts.STUB).toBe(0);
    expect(counts.BROKEN).toBe(0);
    expect(readme).toContain(`Audit substantif saat ini menemukan **${total} PASS**, **0 NEEDS_REVIEW**, **0 STUB**, dan **0 BROKEN**`);
  });
});
