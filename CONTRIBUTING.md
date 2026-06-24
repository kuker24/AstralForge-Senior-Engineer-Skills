# Contributing to AstralForge

AstralForge adalah paket skill lokal untuk AI engineering workflow. Kontribusi harus menjaga evidence, keamanan, dan kualitas skill. Jangan menambahkan klaim `Verified`, `Supported`, atau `Done` tanpa bukti dari audit lokal, test, atau CI.

## Cara menambah skill baru

Tambahkan skill baru hanya jika ada kebutuhan nyata dan batas trigger-nya jelas. Skill baru harus membantu agent melakukan pekerjaan operasional, bukan sekadar menambah jumlah folder.

### Struktur wajib

```txt
skills/
└── nama-skill/
    ├── SKILL.md          # Isi minimal 150 kata, bukan placeholder
    ├── agents/
    │   └── openai.yaml   # Config agent, bukan template kosong
    └── references/
        └── sources.md    # Link sumber yang hidup (HTTP 200)
```

### Standar minimum SKILL.md

- Frontmatter valid dan konsisten dengan folder:
  - `name` harus sama persis dengan nama folder.
  - `description` harus pendek, spesifik, dan action-oriented.
  - `license` atau metadata lisensi harus dicantumkan jika skill menyertakan kode/aset/sumber dengan lisensi eksplisit.
- Isi body minimal 150 kata substantif.
- Body harus menjelaskan:
  - kapan skill dipakai;
  - kapan skill tidak dipakai;
  - workflow langkah demi langkah;
  - output yang diharapkan;
  - validation gates;
  - catatan safety atau quality.
- Bukan copy-paste dari skill lain tanpa modifikasi domain yang nyata.
- Tidak boleh berisi marker unfinished seperti `TODO`, `TBD`, `replace with description`, atau filler generik.
- Jika skill berhubungan dengan tool, API, SDK, framework, atau standar tertentu, tambahkan sumber relevan di `references/sources.md`.

### Standar minimum agents/openai.yaml

`agents/openai.yaml` harus non-empty dan berisi:

```yaml
name: nama-skill
description: Short action-oriented description
version: 1.0.0
triggers:
  - "specific trigger phrase"
keywords:
  - keyword
```

Gunakan 5–10 trigger phrase yang cukup spesifik agar skill tidak over-trigger. Gunakan 5–12 keyword yang relevan dengan domain skill.

### Standar minimum references/sources.md

`references/sources.md` harus berisi:

- `# Sources & References`
- `## Official Documentation`
- `## Repositories Referenced` jika relevan
- `## Standards or Specifications` jika relevan
- `## Access Date`
- `## License Notes`

Tambahkan minimal dua URL HTTP yang real, relevan, dan bisa dijangkau. Preferensi sumber:

1. dokumentasi resmi;
2. standar/spesifikasi primer;
3. repository open-source resmi;
4. referensi teknis bereputasi.

Jangan menambahkan fake references atau URL yang tidak relevan hanya untuk lolos audit.

## Cara run audit lokal sebelum PR

```bash
./scripts/audit-skills.sh
```

atau:

```bash
npm run audit:skills
```

Skill dengan status `STUB`, `BROKEN`, atau `NEEDS_REVIEW` tidak akan diterima. Audit ini lebih ketat daripada struktur folder dasar karena juga mengecek support files, word count, marker unfinished, dan link HTTP.

## Cara jalankan semua QA lokal

Minimal sebelum PR:

```bash
npm run typecheck
npm run test:coverage
npm run verify:skills
npm run audit:skills
pre-commit run --all-files
```

Checks tambahan yang disarankan untuk perubahan security/dependency/release:

```bash
semgrep scan --config p/default --metrics=off
osv-scanner scan source -r . --format json --output-file osv-results.json
gitleaks dir --redact --report-format json --report-path gitleaks-dir-report.json .
npx knip
```

Jangan commit output lokal besar seperti `coverage/`, `playwright-report/`, `test-results/`, `repomix-output.*`, `semgrep-results.json`, `osv-results.json`, atau `gitleaks-*.json` kecuali file tersebut memang compact evidence yang sengaja ditempatkan di `reports/` dan tidak mengandung secret.

## PR checklist

- [ ] Audit skill lolos dengan verdict `PASS`.
- [ ] `npm run typecheck` lolos.
- [ ] `npm run test:coverage` lolos.
- [ ] `npm run verify:skills` lolos.
- [ ] `pre-commit run --all-files` lolos.
- [ ] Tidak ada secret/token/API key/private config di dalam file.
- [ ] Semua link di `sources.md` hidup dan relevan.
- [ ] `agents/openai.yaml` berisi trigger dan keyword yang spesifik.
- [ ] Entry `CHANGELOG.md` ditambahkan jika perubahan memengaruhi perilaku, audit status, dokumentasi publik, atau release readiness.
- [ ] README tidak mengklaim status lebih tinggi daripada evidence.

## Melaporkan bug

Gunakan GitHub Issues dengan template yang tersedia. Sertakan:

- langkah reproduksi;
- file atau skill yang terdampak;
- command yang dijalankan;
- hasil yang diharapkan;
- hasil aktual;
- log ringkas yang sudah diredaksi.

Jangan memasukkan token, API key, `.env`, private config, atau data sensitif ke issue publik.

## Aturan keamanan kontribusi

- Jangan commit `.env` atau `.env.*`.
- Jangan hardcode credential provider custom.
- Jangan print `Authorization` header atau API key di test, log, docs, snapshot, atau report.
- Jangan menjalankan Stryker mutation testing kecuali maintainer meminta eksplisit.
- Jangan force-push branch shared tanpa instruksi eksplisit.
