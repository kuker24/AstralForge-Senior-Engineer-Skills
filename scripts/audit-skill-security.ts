#!/usr/bin/env tsx
import { existsSync, mkdirSync, readFileSync, readdirSync, statSync, writeFileSync } from 'node:fs';
import { dirname, join, relative } from 'node:path';
import { pathToFileURL } from 'node:url';

export type RiskLevel = 'PASS' | 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL';

export interface Finding {
  readonly ruleId: string;
  readonly level: Exclude<RiskLevel, 'PASS'>;
  readonly filePath: string;
  readonly line: number;
  readonly excerpt: string;
  readonly description: string;
}

interface Rule {
  readonly id: string;
  readonly level: Exclude<RiskLevel, 'PASS'>;
  readonly description: string;
  readonly patterns: readonly RegExp[];
  readonly allowSafeContext?: boolean;
  readonly secretRule?: boolean;
}

interface CliOptions {
  readonly reportOnly: boolean;
  readonly jsonPath: string;
  readonly markdownPath: string;
}

const repoRoot = process.cwd();
const defaultJsonPath = 'reports/skill-security-audit.json';
const defaultMarkdownPath = 'reports/skill-security-audit.md';

const rules: readonly Rule[] = [
  {
    id: 'PROMPT_INJECTION_OVERRIDE',
    level: 'HIGH',
    description: 'Instruction appears to override system/developer/repository policy.',
    allowSafeContext: true,
    patterns: [
      /ignore\s+(all\s+)?(previous|above|system|developer|repo|repository)(\s+(system|developer|repo|repository))?\s+instructions?/i,
      /override\s+(system|developer|repo|repository)\s+(policy|rules|instructions?)/i,
    ],
  },
  {
    id: 'BYPASS_POLICY_OR_APPROVAL',
    level: 'HIGH',
    description: 'Instruction appears to bypass policy, sandbox, or approval controls.',
    allowSafeContext: true,
    patterns: [
      /bypass\s+(policy|sandbox|approval|permission|review)/i,
      /disable\s+(approval|sandbox|safety|policy)/i,
      /approval\s*mode\s*[:=]?\s*(never|none)/i,
    ],
  },
  {
    id: 'SECRET_THEFT_OR_EXFILTRATION',
    level: 'CRITICAL',
    description: 'Instruction appears to steal, dump, print, or exfiltrate secrets.',
    allowSafeContext: true,
    patterns: [
      /(steal|dump|exfiltrate|leak|print)\s+.*(secret|token|api\s*key|cookie|authorization|private\s*key|\.env)/i,
      /(send|upload|post)\s+.*(secret|token|api\s*key|cookie|authorization|private\s*key|\.env)\s+.*https?:\/\//i,
    ],
  },
  {
    id: 'HIDE_ACTIONS_FROM_USER',
    level: 'HIGH',
    description: 'Instruction appears to hide actions from the user or maintainer.',
    allowSafeContext: true,
    patterns: [
      /(hide|conceal)\s+.*(from|to)\s+.*(user|maintainer)/i,
      /do\s+not\s+(tell|inform|notify)\s+the\s+user/i,
      /without\s+the\s+user\s+knowing/i,
    ],
  },
  {
    id: 'DESTRUCTIVE_COMMAND_WITHOUT_APPROVAL',
    level: 'HIGH',
    description: 'Destructive command or deletion workflow appears unsafe without approval.',
    allowSafeContext: true,
    patterns: [
      /rm\s+-rf\s+(\/|~|\$HOME|\*)/i,
      /git\s+clean\s+-f(dx|xd)/i,
      /(delete|destroy|wipe|purge)\s+.*(without\s+approval|without\s+confirmation|silently)/i,
    ],
  },
  {
    id: 'AGGRESSIVE_TRIGGER_DESCRIPTION',
    level: 'MEDIUM',
    description: 'Trigger language appears too broad or aggressive.',
    allowSafeContext: true,
    patterns: [
      /always\s+use\s+this\s+skill\s+for\s+(every|all)\s+(task|request|message)/i,
      /trigger\s+on\s+(every|all)\s+(message|request|task)/i,
    ],
  },
  {
    id: 'UNSUPPORTED_CERTIFICATION_CLAIM',
    level: 'MEDIUM',
    description: 'Claim appears to imply unsupported certification or absolute security.',
    allowSafeContext: true,
    patterns: [
      /(externally\s+certified|officially\s+certified|100%\s+secure|guaranteed\s+secure)/i,
      /(production[-\s]?grade|production[-\s]?ready)\s+.*(certified|guaranteed)/i,
    ],
  },
  {
    id: 'HARDCODED_CREDENTIAL_PATTERN',
    level: 'CRITICAL',
    description: 'Line resembles a hardcoded credential or bearer token.',
    secretRule: true,
    patterns: [
      /\b(sk-[A-Za-z0-9_-]{16,}|sk-sa-[A-Za-z0-9_-]{16,})\b/,
      /\b(AKIA|ASIA)[A-Z0-9]{16}\b/,
      /Authorization\s*[:=]\s*Bearer\s+['"]?[A-Za-z0-9._~+\/-]{20,}/i,
      /(api[_-]?key|token|secret|password)\s*[:=]\s*['"][^'"$<]{16,}['"]/i,
    ],
  },
  {
    id: 'IGNORE_REPO_RULES',
    level: 'HIGH',
    description: 'Instruction appears to ignore AGENTS.md or repository safety rules.',
    allowSafeContext: true,
    patterns: [
      /ignore\s+(AGENTS\.md|repo\s+rules|repository\s+rules)/i,
      /do\s+not\s+follow\s+(AGENTS\.md|repo\s+rules|repository\s+rules)/i,
    ],
  },
  {
    id: 'UNOFFICIAL_TOOL_INSTALL',
    level: 'HIGH',
    description: 'Instruction appears to install tools from an unofficial or random marketplace/source.',
    allowSafeContext: true,
    patterns: [
      /(install|enable|use)\s+.*(random|untrusted|unofficial)\s+.*(marketplace|mcp|plugin)/i,
      /curl\s+.*https?:\/\/.*\|\s*(sh|bash)/i,
    ],
  },
  {
    id: 'NON_CORE_MCP_DEFAULT',
    level: 'HIGH',
    description: 'Instruction appears to activate non-core MCP/tooling as a default.',
    allowSafeContext: true,
    patterns: [
      /(Playwright|GitHub|browser\s+automation|random\s+marketplace)\s+MCP\s+default/i,
      /enable\s+all\s+MCP\s+(by\s+default|servers)/i,
      /activate\s+.*MCP\s+.*by\s+default/i,
    ],
  },
  {
    id: 'REWRITE_RELEASE_OR_FORCE_PUSH',
    level: 'HIGH',
    description: 'Instruction appears to rewrite release/tag history or force-push without explicit safety context.',
    allowSafeContext: true,
    patterns: [
      /git\s+push\s+--force/i,
      /force\s+push/i,
      /rewrite\s+.*(tag|release|history)/i,
      /gh\s+release\s+edit\s+.*(--target|targetCommitish)/i,
    ],
  },
];

function isSafeInstructionContext(text: string): boolean {
  const value = text.toLowerCase();
  return [
    'do not',
    "don't",
    'never',
    'must not',
    'not allowed',
    'no ',
    'bukan',
    'jangan',
    'tidak boleh',
    'without rewriting',
    'not rewrite',
    'not rewritten',
    'off by default',
    'inactive by default',
    'not core default',
    'not a core default',
    'intentionally not',
    'future consideration',
    'blocked',
    'warning',
    'requires approval',
    'require approval',
    'only pause for user input',
    'destructive operations',
    'proper isolation',
    'externally sandboxed',
  ].some((marker) => value.includes(marker));
}

function isPlaceholderSecret(line: string): boolean {
  const value = line.toLowerCase();
  return value.includes('replace_me') || value.includes('<') || value.includes('$') || value.includes('placeholder') || value.includes('example');
}

function redact(value: string): string {
  return value
    .replace(/sk-sa-[A-Za-z0-9_-]+/g, 'sk-sa-[REDACTED]')
    .replace(/sk-[A-Za-z0-9_-]+/g, 'sk-[REDACTED]')
    .replace(/\b(AKIA|ASIA)[A-Z0-9]{16}\b/g, '[AWS_KEY_REDACTED]')
    .replace(/(Authorization\s*[:=]\s*Bearer\s+)(['"]?)[A-Za-z0-9._~+\/-]+/gi, '$1$2[REDACTED]')
    .replace(/((api[_-]?key|token|secret|password)\s*[:=]\s*['"])[^'"]+/gi, '$1[REDACTED]');
}

function truncate(value: string, maxLength = 180): string {
  const trimmed = value.trim();
  return trimmed.length <= maxLength ? trimmed : `${trimmed.slice(0, maxLength - 1)}…`;
}

export function scanText(filePath: string, text: string): Finding[] {
  const findings: Finding[] = [];
  const lines = text.split(/\r?\n/);

  lines.forEach((line, index) => {
    const contextWindow = [lines[index - 1] ?? '', line, lines[index + 1] ?? '', lines[index + 2] ?? ''].join('\n');
    for (const rule of rules) {
      if (rule.allowSafeContext && isSafeInstructionContext(contextWindow)) continue;
      if (rule.secretRule && isPlaceholderSecret(line)) continue;
      if (!rule.patterns.some((pattern) => pattern.test(line))) continue;

      findings.push({
        ruleId: rule.id,
        level: rule.level,
        filePath,
        line: index + 1,
        excerpt: truncate(redact(line)),
        description: rule.description,
      });
    }
  });

  return findings;
}

function walkFiles(directory: string): string[] {
  if (!existsSync(directory)) return [];
  const output: string[] = [];
  for (const entry of readdirSync(directory)) {
    const fullPath = join(directory, entry);
    const stats = statSync(fullPath);
    if (stats.isDirectory()) {
      output.push(...walkFiles(fullPath));
    } else if (stats.isFile()) {
      output.push(fullPath);
    }
  }
  return output;
}

function targetFiles(): string[] {
  const explicit = ['AGENTS.md', 'README.md', 'SECURITY.md'];
  const skillFiles = walkFiles(join(repoRoot, 'skills')).filter((filePath) =>
    /\/(SKILL\.md|agents\/openai\.yaml|references\/sources\.md)$/.test(filePath.replaceAll('\\', '/')),
  );
  const installerConfig = walkFiles(join(repoRoot, 'installer/config')).filter((filePath) => /\.(json|md|yaml|yml|txt)$/.test(filePath));
  const profileFiles = walkFiles(join(repoRoot, 'profiles')).filter((filePath) => filePath.endsWith('.md'));

  return [...explicit.map((filePath) => join(repoRoot, filePath)), ...skillFiles, ...installerConfig, ...profileFiles]
    .filter((filePath) => existsSync(filePath))
    .sort();
}

function riskRank(level: RiskLevel): number {
  return { PASS: 0, LOW: 1, MEDIUM: 2, HIGH: 3, CRITICAL: 4 }[level];
}

function highestRisk(findings: readonly Finding[]): RiskLevel {
  if (findings.length === 0) return 'PASS';
  return findings.reduce<RiskLevel>((highest, finding) => (riskRank(finding.level) > riskRank(highest) ? finding.level : highest), 'PASS');
}

function countByLevel(findings: readonly Finding[]): Record<RiskLevel, number> {
  const counts: Record<RiskLevel, number> = { PASS: 0, LOW: 0, MEDIUM: 0, HIGH: 0, CRITICAL: 0 };
  for (const finding of findings) counts[finding.level] += 1;
  counts.PASS = findings.length === 0 ? 1 : 0;
  return counts;
}

function parseArgs(argv: readonly string[]): CliOptions {
  let reportOnly = false;
  let jsonPath = defaultJsonPath;
  let markdownPath = defaultMarkdownPath;

  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === '--report-only') {
      reportOnly = true;
    } else if (arg === '--json') {
      index += 1;
      jsonPath = argv[index] ?? jsonPath;
    } else if (arg === '--markdown') {
      index += 1;
      markdownPath = argv[index] ?? markdownPath;
    } else if (arg === '--help') {
      console.log('Usage: tsx scripts/audit-skill-security.ts [--report-only] [--json path] [--markdown path]');
      process.exit(0);
    } else {
      throw new Error(`Unknown argument: ${arg}`);
    }
  }

  return { reportOnly, jsonPath, markdownPath };
}

function writeJsonReport(path: string, findings: readonly Finding[], scannedFiles: readonly string[]): void {
  mkdirSync(dirname(path), { recursive: true });
  const payload = {
    generatedAt: new Date().toISOString(),
    scanner: 'AstralForge Skill Security Auditor',
    scannedFileCount: scannedFiles.length,
    overallRisk: highestRisk(findings),
    counts: countByLevel(findings),
    findings,
  };
  writeFileSync(path, `${JSON.stringify(payload, null, 2)}\n`);
}

function writeMarkdownReport(path: string, findings: readonly Finding[], scannedFiles: readonly string[]): void {
  mkdirSync(dirname(path), { recursive: true });
  const counts = countByLevel(findings);
  const lines = [
    '# Skill Security Audit',
    '',
    `Generated: ${new Date().toISOString()}`,
    '',
    'This deterministic local scanner checks skill and profile text for semantic security-risk patterns. It is an additional v3.1.0 guardrail, not an external certification.',
    '',
    '## Summary',
    '',
    `- Overall risk: ${highestRisk(findings)}`,
    `- Scanned files: ${scannedFiles.length}`,
    `- Findings: ${findings.length}`,
    '',
    '| Risk | Count |',
    '|------|------:|',
    `| CRITICAL | ${counts.CRITICAL} |`,
    `| HIGH | ${counts.HIGH} |`,
    `| MEDIUM | ${counts.MEDIUM} |`,
    `| LOW | ${counts.LOW} |`,
    '',
    '## Findings',
    '',
  ];

  if (findings.length === 0) {
    lines.push('- No findings.');
  } else {
    lines.push('| Risk | Rule | File | Line | Redacted excerpt |');
    lines.push('|------|------|------|-----:|------------------|');
    for (const finding of findings) {
      lines.push(`| ${finding.level} | ${finding.ruleId} | \`${finding.filePath}\` | ${finding.line} | ${finding.excerpt.replaceAll('|', '\\|')} |`);
    }
  }

  lines.push('', '## Scanned Paths', '');
  for (const filePath of scannedFiles) {
    lines.push(`- \`${filePath}\``);
  }

  writeFileSync(path, `${lines.join('\n')}\n`);
}

export function runAudit(options: CliOptions): { readonly findings: Finding[]; readonly scannedFiles: string[]; readonly overallRisk: RiskLevel } {
  const files = targetFiles();
  const findings = files.flatMap((filePath) => {
    const relativePath = relative(repoRoot, filePath).replaceAll('\\', '/');
    return scanText(relativePath, readFileSync(filePath, 'utf8'));
  });
  writeJsonReport(options.jsonPath, findings, files.map((filePath) => relative(repoRoot, filePath).replaceAll('\\', '/')));
  writeMarkdownReport(options.markdownPath, findings, files.map((filePath) => relative(repoRoot, filePath).replaceAll('\\', '/')));
  return { findings, scannedFiles: files, overallRisk: highestRisk(findings) };
}

function main(): void {
  const options = parseArgs(process.argv.slice(2));
  const result = runAudit(options);
  console.log(`Skill security audit overall risk: ${result.overallRisk}`);
  console.log(`Findings: ${result.findings.length}`);
  console.log(`JSON: ${options.jsonPath}`);
  console.log(`Markdown: ${options.markdownPath}`);

  if (!options.reportOnly && result.findings.some((finding) => finding.level === 'HIGH' || finding.level === 'CRITICAL')) {
    process.exit(1);
  }
}

if (import.meta.url === pathToFileURL(process.argv[1] ?? '').href) {
  main();
}
