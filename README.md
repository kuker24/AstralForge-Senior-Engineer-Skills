# AstralForge Senior Engineer Skills

[![CI](https://github.com/kuker24/AstralForge-Senior-Engineer-Skills/actions/workflows/ci.yml/badge.svg)](https://github.com/kuker24/AstralForge-Senior-Engineer-Skills/actions/workflows/ci.yml)
[![Security](https://github.com/kuker24/AstralForge-Senior-Engineer-Skills/actions/workflows/security.yml/badge.svg)](https://github.com/kuker24/AstralForge-Senior-Engineer-Skills/actions/workflows/security.yml)

**Senior-grade AI engineering skills with local QA, security, and review gates.**

AstralForge adalah paket **83 source skill folders** untuk fullstack + UI/UX + senior engineering workflow, dilengkapi stack local no-login untuk QA, security, dependency review, secret scanning, type safety, unit testing, coverage, ADR, dan review packaging.

Status verifikasi dibedakan secara eksplisit: **Verified**, **Supported**, **Manual only**, **Needs review**, dan **Unverified**. Audit substantif saat ini menemukan **25 PASS**, **12 STUB**, dan **46 BROKEN** dari 83 folder skill; lihat [reports/skill-audit-summary.md](reports/skill-audit-summary.md). Karena itu README tidak mengklaim semua 83 skill sudah fully verified.

- Package name: `astralforge-senior-engineer-skills`
- Current target repository: `https://github.com/kuker24/AstralForge-Senior-Engineer-Skills`
- Suggested repo name later: `AstralForge_SeniorEngineerSkills`

---

## 📦 Package Contents

| Component | Description |
|-----------|-------------|
| **Skills** | 83 source skill folders; 25 currently pass the substantive audit |
| **Installer** | Pi installer package files are present; sandbox/CI installer verification is pending |
| **Global Install** | Global install scripts are present; sandbox/CI installer verification is pending |

---

## 🧰 AI Agent Tooling

Repo ini juga menyertakan konfigurasi lokal untuk tool pendukung coding AI agent. Status di bawah mengikuti evidence di `reports/` dan command lokal yang benar-benar dijalankan.

| Tool | Status | Local Command | Evidence |
|------|--------|---------------|----------|
| TypeScript Typecheck | Verified | `npm run typecheck` | [Evidence inventory](reports/evidence-inventory.md), [CI setup](reports/ci-setup-evidence.md) |
| Vitest + Coverage | Verified | `npm run test:unit`, `npm run test:coverage` | [Evidence inventory](reports/evidence-inventory.md), [CI setup](reports/ci-setup-evidence.md) |
| Source skill verifier | Verified | `npm run verify:skills` | [Evidence inventory](reports/evidence-inventory.md), [Skill manifest](SKILLS_MANIFEST.md) |
| pre-commit | Verified | `pre-commit run --all-files` | [Evidence inventory](reports/evidence-inventory.md), `.pre-commit-config.yaml` |
| Semgrep CE | Verified | `semgrep scan --config p/default --metrics=off --json --json-output=semgrep-results.json` | [Security CI setup](reports/security-ci-setup-evidence.md) |
| OSV-Scanner | Verified | `osv-scanner scan source -r . --format json --output-file osv-results.json` | [Security CI setup](reports/security-ci-setup-evidence.md) |
| Gitleaks | Verified | `gitleaks git --redact --report-format json --report-path gitleaks-report.json .` | [Security CI setup](reports/security-ci-setup-evidence.md), `.gitleaks.toml` |
| Knip | Verified | `npx knip` | [CI setup](reports/ci-setup-evidence.md), `knip.json` |
| ADR | Verified | Review `docs/adr/` | [ADR index](docs/adr/README.md) |
| Skill substantive audit | Needs review | `bash scripts/audit-skills.sh` | [Skill audit summary](reports/skill-audit-summary.md) |
| GitHub Actions CI | Supported | `.github/workflows/ci.yml` | [CI setup](reports/ci-setup-evidence.md); remote green run pending |
| GitHub Actions Security | Supported | `.github/workflows/security.yml` | [Security CI setup](reports/security-ci-setup-evidence.md); remote green run pending |
| Playwright Test | Supported | `npx playwright test --project=chromium` | Placeholder smoke test only; real app-flow E2E pending |
| Repomix | Supported | `repomix --compress` | Config present; full output intentionally ignored |
| OMNI | Supported | `omni stats --detail` | Local integration documented in [Evidence inventory](reports/evidence-inventory.md) |
| Context7 Pi | Supported | Pi package integration | Local integration documented in [Evidence inventory](reports/evidence-inventory.md) |
| Serena MCP | Supported | Serena MCP setup | Local integration documented in [Evidence inventory](reports/evidence-inventory.md) |
| StrykerJS | Manual only | `npm run mutation` | `stryker.config.json`; do not run unless explicitly requested |

Helper lokal:

```bash
bash scripts/ai-checks.sh
bash scripts/ai-quality-checks.sh
bash scripts/ai-senior-checks.sh
```

Daily senior quality commands:

```bash
npm run typecheck
npm run test:unit
npm run test:coverage
npm run verify:skills
pre-commit run --all-files
bash scripts/ai-senior-checks.sh
```

Manual-only mutation testing:

```bash
npm run mutation
```

> Do not run StrykerJS mutation testing unless explicitly requested.

Output lokal yang diabaikan Git:

```txt
semgrep-results.json
osv-results.json
gitleaks-report.json
gitleaks-dir-report.json
repomix-output.*
coverage/
playwright-report/
test-results/
.stryker-tmp/
mutation-report/
.knip-cache/
```

---

## Verification Status

This repository distinguishes between:

- **Verified**: a command/config has local evidence and/or committed evidence report.
- **Supported**: scripts/configuration exist, but full CI or durable evidence is still pending.
- **Manual only**: available only when explicitly requested, for example StrykerJS mutation testing.
- **Needs review**: audit found issues or incomplete evidence that should be reviewed before stronger claims.
- **Unverified**: no reliable command or report evidence yet.

Current skill audit status:

| Metric | Count |
|--------|------:|
| Total source skill folders | 83 |
| Audit PASS | 25 |
| Audit STUB | 12 |
| Audit BROKEN | 46 |
| Audit NEEDS_REVIEW | 0 |

See [reports/skill-audit-summary.md](reports/skill-audit-summary.md) and [reports/skill-audit-results.csv](reports/skill-audit-results.csv).

---

## 📊 Source Folder Statistics

These category counts describe the 83 source skill folders, not fully verified skill quality.

| Kategori | Jumlah |
|----------|--------|
| Frontend | 9 |
| Backend | 9 |
| Database | 5 |
| DevOps | 8 |
| Security | 4 |
| Testing | 5 |
| Mobile | 1 |
| AI/ML | 1 |
| Blockchain | 1 |
| Full Stack | 21 |
| Lainnya | 20 |
| **Total** | **83** |

---

## 🚀 Instalasi

### Pi Complete Installer (Recommended)

Paket instalasi lengkap untuk Pi dengan skills, extensions, dan konfigurasi:

```bash
cd installer/
chmod +x install-pi-linux.sh
./install-pi-linux.sh
```

**Windows:**
```powershell
cd installer
.\install-pi-windows.ps1
```

📖 Lihat [installer/README.md](installer/README.md) untuk dokumentasi lengkap.

### Global Installation

Install ke semua platform: Pi, OpenCode, Claude, Codex, Agents

```bash
chmod +x install-global.sh
./install-global.sh
```

### Single Platform Installation

#### Linux/macOS
```bash
chmod +x install.sh
./install.sh
```

#### Windows (PowerShell)
```powershell
.\install.ps1
```

### Opsi
```bash
# Force install (overwrite existing)
./install.sh --force

# Dry run (tanpa install)
./install.sh --dry-run
```

### Supported Platforms

| Platform | Directory | Auto-Discovery |
|----------|-----------|----------------|
| Pi | `~/.pi/agent/skills/` | ✅ |
| OpenCode/OpenClaude | `~/.config/opencode/skills/` | ✅ |
| Claude | `~/.claude/skills/` | ✅ |
| Codex | `~/.codex/skills/` | ✅ |
| Agents | `~/.agents/skills/` | ✅ |

---

## 📦 Daftar Skill

### 🔴 Priority 1 - Wajib Ada (8 skill baru)

| Skill | Fungsi |
|-------|--------|
| nodejs-express | Backend JS, REST API, Middleware |
| docker-kubernetes | Container, Orchestration, K8s |
| typescript | Type-safe JS, Advanced types |
| tailwind-css | Utility-first CSS, Responsive |
| nextjs | React framework, SSR/SSG |
| prisma-drizzle | Modern ORM, Migrations |
| authentication | JWT, OAuth, Passkey |
| aws-cloud | Lambda, API Gateway, S3 |

### 🟡 Priority 2 - Sangat Disarankan (7 skill baru)

| Skill | Fungsi |
|-------|--------|
| mongodb | NoSQL, Aggregation, Schema |
| redis | Caching, Session, Pub/Sub |
| websocket | Real-time, Socket.IO |
| graphql-impl | Apollo Server, Schema, Resolver |
| message-queue | RabbitMQ, Kafka, Async |
| cicd-pipeline | GitHub Actions, CI/CD |
| monitoring-logging | OpenTelemetry, Sentry |

### 🟢 Priority 3 - Opsional (5 skill baru)

| Skill | Fungsi |
|-------|--------|
| vuejs-svelte | Vue 3, Svelte 5 |
| react-native-flutter | Mobile development |
| microservices | Service architecture |
| ai-ml-integration | OpenAI, RAG, Embeddings |
| web3-blockchain | Wallet, Smart contracts |

### 🔧 Full Stack Skills (8 skill baru)

| Skill | Fungsi |
|-------|--------|
| full-api-design | REST API design, Versioning |
| full-database-migration | Zero-downtime migrations |
| full-performance-audit | Profiling, Optimization |
| full-dependency-audit | Security, License compliance |
| full-architecture-review | System design, Scalability |
| full-data-pipeline | ETL/ELT, Data quality |
| full-infrastructure-as-code | Terraform, Pulumi |
| full-api-testing | Contract, Load, Security testing |

### 📚 Skill Lainnya (55 skill existing)

<details>
<summary>Klik untuk expand</summary>

- algorithmic-art
- api-patterns
- autonomous-skill
- brand-guidelines
- canvas-design
- claude-api
- claude-frontend-design
- claude-skill
- claude-skill-creator
- database-design
- deep-research
- deployment-procedures
- doc-coauthoring
- docx
- frontend-design
- full-audit-keamanan
- full-brainstorm
- full-bug-hunter
- full-debug
- full-init
- full-master-plan
- full-optimize-performa
- full-orchestrator-max-otonom
- full-refactoring-max
- full-review
- full-security
- full-setup-project
- full-test
- gh-fix-ci
- github
- imagegen
- internal-comms
- kiro-skill
- lint-and-validate
- mcp-builder
- nanobanana-skill
- openai-docs
- pdf
- playwright
- plugin-creator
- pptx
- python-patterns
- react-best-practices
- skill-creator
- skill-installer
- slack-gif-creator
- spec-kit-skill
- supabase-postgres-best-practices
- template-skill
- theme-factory
- ui-ux-pro-max
- web-artifacts-builder
- webapp-testing
- xlsx
- youtube-transcribe-skill

</details>

---

## 🔍 Verifikasi

```bash
# Verifikasi instalasi
./verify.sh

# Verifikasi source folder/frontmatter
npm run verify:skills

# Audit substantif skill
bash scripts/audit-skills.sh
```

---

## 📁 Struktur per Skill

```
skill-name/
├── SKILL.md              # Skill definition dengan frontmatter
├── agents/
│   └── openai.yaml       # Agent configuration
└── references/
    └── sources.md         # Source documentation & license
```

---

## 🔗 Sumber Skill

| Sumber | Repository | Jumlah |
|--------|------------|--------|
| Anthropic | [github.com/anthropics/skills](https://github.com/anthropics/skills) | 17 |
| OpenAI | [github.com/openai/skills](https://github.com/openai/skills) | 6 |
| Community | Various | 5 |
| Custom | Local | 55 |

---

## 📄 Dokumentasi

- [ARCHITECTURE.md](ARCHITECTURE.md) - Arsitektur repo dan batas stack
- [installer/README.md](installer/README.md) - Dokumentasi installer Pi
- [SKILLS_MANIFEST.md](SKILLS_MANIFEST.md) - Daftar lengkap semua skill
- [MISSING_SKILLS_CHECKLIST.md](MISSING_SKILLS_CHECKLIST.md) - Checklist skill
- [reports/skill-completion-report.md](reports/skill-completion-report.md) - Report completion
- [reports/evidence-inventory.md](reports/evidence-inventory.md) - Inventory klaim dan evidence
- [reports/ci-setup-evidence.md](reports/ci-setup-evidence.md) - Evidence setup CI baseline
- [reports/security-ci-setup-evidence.md](reports/security-ci-setup-evidence.md) - Evidence setup security CI
- [reports/skill-audit-summary.md](reports/skill-audit-summary.md) - Ringkasan audit substansi skill
- [reports/skill-audit-results.csv](reports/skill-audit-results.csv) - CSV hasil audit substansi skill
- [reports/source-skill-index.md](reports/source-skill-index.md) - Index sumber skill
- [reports/global-installation-report.md](reports/global-installation-report.md) - Report instalasi global

---

## 📝 License

Each skill may have its own license. Check individual `references/sources.md` files for details.

---

## 🤝 Kontribusi

1. Fork repository
2. Buat skill baru di folder `skills/`
3. Pastikan memiliki SKILL.md dengan frontmatter
4. Jalankan `./verify.sh`
5. Submit Pull Request

---

## 📞 Support

- GitHub Issues: [Create Issue](../../issues)
- Documentation: [README.md](README.md)

---

**Version**: 3.0.0
**Last Updated**: 2026-06-22
**Total Source Skill Folders**: 83
**Substantive Audit PASS**: 25
