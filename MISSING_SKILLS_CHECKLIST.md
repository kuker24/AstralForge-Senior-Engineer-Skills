# Missing Skills Checklist

Checklist skill yang perlu dicari untuk melengkapi Full Stack Developer toolkit.

---

## 📊 Status Saat Ini

| Kategori | Skill | Status |
|----------|-------|--------|
| Frontend | 6 | ✅ |
| Backend | 5 | ⚠️ Kurang |
| DevOps | 3 | ⚠️ Kurang |
| Testing | 4 | ✅ |
| Security | 2 | ✅ |
| Full Stack | 13 | ✅ |
| **Total** | **55** | **Perlu 20 lagi** |

---

## 🔴 PRIORITAS 1 - WAJIB ADA (8 skill)

| No | Skill | Untuk Apa | GitHub Query | Status | Link |
|----|-------|-----------|--------------|--------|------|
| 1 | nodejs-express | Backend JS, REST API, Middleware | `SKILL.md nodejs express` | ☐ | |
| 2 | docker-kubernetes | Container, Orchestration, Compose | `SKILL.md docker kubernetes` | ☐ | |
| 3 | typescript | Type-safe JS, Advanced types | `SKILL.md typescript` | ☐ | |
| 4 | tailwind-css | Utility-first CSS, Responsive | `SKILL.md tailwind css` | ☐ | |
| 5 | nextjs | React framework, SSR/SSG, App Router | `SKILL.md nextjs react` | ☐ | |
| 6 | prisma-drizzle | Modern ORM, Migrations, Type-safe | `SKILL.md prisma drizzle orm` | ☐ | |
| 7 | authentication | JWT, OAuth, Passkey, WebAuthn | `SKILL.md jwt oauth authentication` | ☐ | |
| 8 | aws-cloud | Cloud services, Serverless, S3 | `SKILL.md aws cloud serverless` | ☐ | |

---

## 🟡 PRIORITAS 2 - SANGAT DISARANKAN (7 skill)

| No | Skill | Untuk Apa | GitHub Query | Status | Link |
|----|-------|-----------|--------------|--------|------|
| 9 | mongodb | NoSQL, Aggregation, Schema design | `SKILL.md mongodb nosql` | ☐ | |
| 10 | redis | Caching, Session, Pub/Sub | `SKILL.md redis caching` | ☐ | |
| 11 | websocket | Real-time, Socket.io, Live updates | `SKILL.md websocket socketio` | ☐ | |
| 12 | graphql-impl | Schema, Resolvers, Apollo Server | `SKILL.md graphql apollo` | ☐ | |
| 13 | message-queue | RabbitMQ, Kafka, Async processing | `SKILL.md rabbitmq kafka queue` | ☐ | |
| 14 | cicd-pipeline | GitHub Actions, GitLab CI, Auto test | `SKILL.md github-actions cicd` | ☐ | |
| 15 | monitoring-logging | APM, Structured logging, Error track | `SKILL.md monitoring logging apm` | ☐ | |

---

## 🟢 PRIORITAS 3 - OPSIONAL (5 skill)

| No | Skill | Untuk Apa | GitHub Query | Status | Link |
|----|-------|-----------|--------------|--------|------|
| 16 | vuejs-svelte | Alternative frontend frameworks | `SKILL.md vue svelte` | ☐ | |
| 17 | react-native-flutter | Mobile development | `SKILL.md react-native flutter` | ☐ | |
| 18 | microservices | Service decomposition, API Gateway | `SKILL.md microservices architecture` | ☐ | |
| 19 | ai-ml-integration | OpenAI, LangChain, Vector DB | `SKILL.md langchain openai ai` | ☐ | |
| 20 | web3-blockchain | Smart contracts, Web3.js | `SKILL.md web3 solidity blockchain` | ☐ | |

---

## 🔍 Cara Mencari di GitHub

### 1. GitHub Search
```
https://github.com/search?q=SKILL.md+nodejs+express&type=code
```

### 2. Filter yang Disarankan
- **Type**: Code
- **Language**: Markdown
- **Sort**: Recently updated

### 3. Repository Official
- **Anthropic**: https://github.com/anthropics/skills
- **OpenAI**: https://github.com/openai/skills

### 4. Topic Tags
- `codex-skill`
- `claude-skill`
- `agent-skill`
- `SKILL.md`

---

## 📝 Cara Install Skill yang Ditemukan

### 1. Download dari GitHub
```bash
# Clone repo
git clone https://github.com/username/repo.git /tmp/new-skill

# Atau download folder spesifik
# Gunakan: https://download-directory.github.io/
```

### 2. Copy ke Folder Skills
```bash
cp -r /tmp/new-skill/skill-name "/home/fahmi/Downloads/LAB GITHUB/LAB SKILL/pro-skill-fullstack-developert/skills/"
```

### 3. Verifikasi
```bash
# Cek SKILL.md ada
ls skills/skill-name/SKILL.md

# Cek frontmatter lengkap
head -10 skills/skill-name/SKILL.md

# Jalankan verify
./verify.sh
```

### 4. Format SKILL.md yang Benar
```markdown
---
name: skill-name
description: Deskripsi lengkap tentang skill ini dan kapan digunakan.
---

# Skill Name

## Instructions

Konten skill di sini...
```

---

## 📦 Struktur Skill yang Ideal

```
skill-name/
├── SKILL.md              # WAJIB: Frontmatter + Instructions
├── scripts/              # OPSIONAL: Script executable
│   ├── helper.py
│   └── setup.sh
├── references/           # OPSIONAL: Dokumentasi referensi
│   └── api-reference.md
├── templates/            # OPSIONAL: Template file
│   └── boilerplate.js
└── assets/               # OPSIONAL: Asset files
    └── config.json
```

---

## ✅ Checklist Final

Setelah menambahkan semua skill:

- [ ] Total skill menjadi 75
- [ ] Semua SKILL.md memiliki frontmatter lengkap
- [ ] Semua script executable (chmod +x)
- [ ] Jalankan `./verify.sh` - semua passed
- [ ] Update `SKILLS_MANIFEST.md`
- [ ] Update `README.md`
- [ ] Test install di laptop lain

---

## 🎯 Target Akhir

| Metric | Saat Ini | Target |
|--------|----------|--------|
| Total Skill | 55 | 75 |
| Frontend | 6 | 9 |
| Backend | 5 | 11 |
| DevOps | 3 | 6 |
| Testing | 4 | 4 |
| Security | 2 | 2 |
| Mobile | 0 | 2 |
| AI/ML | 0 | 1 |

---

**Last Updated**: 2026-05-24
**Status**: 🔄 In Progress
