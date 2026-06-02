---
name: full-dependency-audit
description: Audit dependencies for security vulnerabilities, license compliance, and updates. Use when reviewing dependencies, fixing vulnerabilities, or planning updates.
---

# Full Dependency Audit

## When to Use

- Reviewing dependency security
- Checking license compliance
- Planning dependency updates
- Fixing vulnerabilities

## Input

- Package files (package.json, requirements.txt)
- Security requirements
- License policies

## Output

- Audit report
- Vulnerability fixes
- License compliance report
- Update recommendations

## Checklist

1. **Security Audit**
   - Run npm audit / pip-audit
   - Check CVE databases
   - Review transitive dependencies
   - Fix critical vulnerabilities

2. **License Audit**
   - Check license types
   - Verify compliance
   - Document exceptions
   - Create policy

3. **Version Audit**
   - Check for outdated packages
   - Review changelogs
   - Test updates
   - Plan upgrade path

4. **Maintenance**
   - Set up automated audits
   - Configure Dependabot
   - Schedule regular reviews
   - Document decisions

## Best Practices

- Automate security scanning
- Review before updating
- Test after updates
- Document license decisions
- Use lock files
- Pin critical dependencies

## Anti-Patterns

❌ Ignoring security warnings
❌ Updating without testing
❌ No license checking
❌ No lock file
❌ Outdated dependencies

## Validation

- No critical vulnerabilities
- Licenses are compliant
- Updates are tested
- Lock file is committed

## Examples

### Example 1: Security Audit
```bash
# npm audit
npm audit
npm audit fix
npm audit fix --force  # Breaking changes

# pip-audit
pip-audit
pip-audit --fix

# yarn audit
yarn audit
```

### Example 2: License Audit
```bash
# license-checker (npm)
npx license-checker --summary
npx license-checker --failOn "GPL-3.0"

# pip-licenses (Python)
pip-licenses --format=json
pip-licenses --fail-on="GPL"
```

### Example 3: Dependabot Configuration
```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 10
    reviewers:
      - "team-lead"
    labels:
      - "dependencies"
    groups:
      development:
        dependency-type: "development"
      production:
        dependency-type: "production"
```

### Example 4: Audit Script
```typescript
// scripts/audit.ts
import { execSync } from 'child_process';

interface AuditResult {
  vulnerabilities: {
    critical: number;
    high: number;
    moderate: number;
    low: number;
  };
  licenses: {
    compliant: string[];
    nonCompliant: string[];
  };
}

async function runAudit(): Promise<AuditResult> {
  // Security audit
  const auditOutput = execSync('npm audit --json', { encoding: 'utf-8' });
  const audit = JSON.parse(auditOutput);
  
  // License audit
  const licenseOutput = execSync('npx license-checker --json', { encoding: 'utf-8' });
  const licenses = JSON.parse(licenseOutput);
  
  const allowedLicenses = ['MIT', 'Apache-2.0', 'BSD-2-Clause', 'BSD-3-Clause', 'ISC'];
  
  const compliant = Object.entries(licenses)
    .filter(([_, info]: [string, any]) => allowedLicenses.includes(info.licenses))
    .map(([name]) => name);
    
  const nonCompliant = Object.entries(licenses)
    .filter(([_, info]: [string, any]) => !allowedLicenses.includes(info.licenses))
    .map(([name]) => name);
  
  return {
    vulnerabilities: audit.metadata.vulnerabilities,
    licenses: { compliant, nonCompliant },
  };
}

runAudit().then(result => {
  console.log(JSON.stringify(result, null, 2));
});
```

## Common Licenses

| License | Type | Requirements |
|---------|------|--------------|
| MIT | Permissive | Include copyright |
| Apache-2.0 | Permissive | Include copyright, notice |
| BSD-2-Clause | Permissive | Include copyright |
| BSD-3-Clause | Permissive | Include copyright, no endorsement |
| ISC | Permissive | Include copyright |
| GPL-3.0 | Copyleft | Open source derivative |
| AGPL-3.0 | Copyleft | Open source, network |

## Output Structure

```
├── reports/
│   ├── security-audit.md
│   ├── license-audit.md
│   └── update-plan.md
├── .github/
│   └── dependabot.yml
├── scripts/
│   └── audit.ts
└── .nsprc               # License policy
```
