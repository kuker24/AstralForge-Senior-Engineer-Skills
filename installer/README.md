# Pi Coding Agent - Complete Installer Package

Paket instalasi lengkap untuk Pi Coding Agent dengan **83 skills**, **extensions**, dan **konfigurasi custom**.

---

## 📦 Package Contents

```
installer/
├── install-pi-linux.sh      # Installer untuk Linux/macOS
├── install-pi-windows.ps1   # Installer untuk Windows
├── README.md                # Dokumentasi ini
├── config/                  # Konfigurasi
│   ├── settings.json        # Pengaturan Pi
│   ├── models.json          # Konfigurasi model (tanpa API key)
│   └── presets.json         # Preset mode
├── extensions/              # 26 extensions
│   ├── auto-commit-on-exit.ts
│   ├── custom-footer.ts
│   ├── custom-header.ts
│   ├── dirty-repo-guard.ts
│   ├── extensions-menu.ts
│   ├── file-trigger.ts      # UPDATED: Fixed trigger file location
│   ├── git-checkpoint.ts
│   ├── handoff.ts
│   ├── hidden-thinking-label.ts
│   ├── message-renderer.ts
│   ├── model-status.ts
│   ├── notify.ts
│   ├── plan-mode/           # RESTORED: Planning mode extension
│   ├── prompt-customizer.ts
│   ├── rainbow-editor.ts
│   ├── reload-runtime.ts
│   ├── session-name.ts
│   ├── structured-output.ts
│   ├── titlebar-spinner.ts
│   ├── todo.ts
│   ├── working-indicator.ts
│   └── subagent/            # Subagent extensions
├── prompts/                 # Custom prompts
│   ├── implement-and-review.md
│   ├── implement.md
│   ├── otonom.md
│   └── scout-and-plan.md
├── agents/                  # Agent definitions
│   ├── planner.md
│   ├── reviewer.md
│   ├── scout.md
│   └── worker.md            # UPDATED: Enhanced subagent definition
└── skills/                  # 83 skills
    ├── nodejs-express/
    ├── docker-kubernetes/
    ├── typescript/
    ├── tailwind-css/
    ├── nextjs/
    ├── prisma-drizzle/
    ├── authentication/
    ├── aws-cloud/
    ├── mongodb/
    ├── redis/
    ├── websocket/
    ├── graphql-impl/
    ├── message-queue/
    ├── cicd-pipeline/
    ├── monitoring-logging/
    ├── vuejs-svelte/
    ├── react-native-flutter/
    ├── microservices/
    ├── ai-ml-integration/
    ├── web3-blockchain/
    └── ... (83 total)
```

---

## 🚀 Quick Start

### Linux/macOS

```bash
# 1. Download package
# 2. Extract
# 3. Run installer
chmod +x install-pi-linux.sh
./install-pi-linux.sh
```

### Windows (PowerShell)

```powershell
# 1. Download package
# 2. Extract
# 3. Run installer (Run as Administrator if needed)
.\install-pi-windows.ps1
```

---

## ⚙️ Options

### Linux/macOS

```bash
# Force install (overwrite existing)
./install-pi-linux.sh --force

# Skip skills installation
./install-pi-linux.sh --no-skills

# Show help
./install-pi-linux.sh --help
```

### Windows

```powershell
# Force install (overwrite existing)
.\install-pi-windows.ps1 -Force

# Skip skills installation
.\install-pi-windows.ps1 -NoSkills

# Show help
.\install-pi-windows.ps1 -Help
```

---

## 🔑 API Key Configuration

**API key tidak disertakan dalam package ini untuk keamanan.**

Setelah instalasi, konfigurasi API key Anda:

### Option 1: Edit models.json

Edit `~/.pi/agent/models.json`:

```json
{
  "providers": {
    "gitlawb-opengateway": {
      "apiKey": "YOUR_ACTUAL_API_KEY_HERE"
    }
  }
}
```

### Option 2: Environment Variable

```bash
# Linux/macOS
export OPENGATEWAY_API_KEY='your-api-key-here'

# Windows PowerShell
$env:OPENGATEWAY_API_KEY = 'your-api-key-here'
```

---

## 📋 What's Included

### Configuration (3 files)
- **settings.json**: Pengaturan Pi (theme, model default, thinking level)
- **models.json**: Konfigurasi model providers (tanpa API key)
- **presets.json**: Preset mode (plan, implement, review, safe)

### Extensions (26 files)
- **auto-commit-on-exit**: Auto commit saat keluar
- **custom-footer**: Custom footer display
- **custom-header**: Custom header display
- **dirty-repo-guard**: Proteksi repo kotor
- **extensions-menu**: Menu extensions
- **file-trigger**: Trigger file events (UPDATED: Fixed trigger file location)
- **git-checkpoint**: Git checkpoint
- **handoff**: Handoff antar session
- **hidden-thinking-label**: Label thinking tersembunyi
- **message-renderer**: Render pesan
- **model-status**: Status model
- **notify**: Notifikasi
- **plan-mode**: Planning mode extension (RESTORED)
- **prompt-customizer**: Custom prompt
- **rainbow-editor**: Editor warna-warni
- **reload-runtime**: Reload runtime
- **session-name**: Nama session
- **structured-output**: Output terstruktur
- **titlebar-spinner**: Spinner titlebar
- **todo**: Manajemen todo
- **working-indicator**: Indikator kerja
- **subagent/**: Subagent extensions

### Prompts (4 files)
- **implement-and-review.md**: Implementasi dan review
- **implement.md**: Implementasi
- **otonom.md**: Mode otonom
- **scout-and-plan.md**: Scout dan plan

### Agents (4 files)
- **planner.md**: Agent planner
- **reviewer.md**: Agent reviewer
- **scout.md**: Agent scout
- **worker.md**: Agent worker (UPDATED: Enhanced subagent definition)

### Skills (83 files)
Semua 83 skills sudah termasuk:
- **Frontend**: tailwind-css, nextjs, vuejs-svelte, dll.
- **Backend**: nodejs-express, mongodb, redis, dll.
- **Database**: prisma-drizzle, mongodb, redis, dll.
- **DevOps**: docker-kubernetes, aws-cloud, cicd-pipeline, dll.
- **Security**: authentication, full-audit-keamanan, dll.
- **Testing**: full-test, full-api-testing, dll.
- **Mobile**: react-native-flutter
- **AI/ML**: ai-ml-integration
- **Blockchain**: web3-blockchain
- **Full Stack**: 21 full-* skills

---

## 🔄 Update Skills

Untuk update skills ke versi terbaru:

```bash
# Download skills terbaru
# Copy ke ~/.pi/agent/skills/
# Atau gunakan installer dengan --force
./install-pi-linux.sh --force
```

---

## 🛡️ Security Notes

- **API key tidak disertakan** dalam package
- **Backup otomatis** sebelum instalasi
- **Skip existing files** secara default (gunakan --force untuk overwrite)
- **Verifikasi instalasi** setelah selesai

---

## 📁 Installation Directory

```
~/.pi/agent/
├── settings.json      # Pengaturan
├── models.json        # Konfigurasi model
├── presets.json       # Preset mode
├── extensions/        # Extensions
├── prompts/           # Custom prompts
├── agents/            # Agent definitions
├── skills/            # 83 skills
└── backup-*/          # Backup (jika ada)
```

---

## 🧪 Verification

Setelah instalasi, verifikasi:

```bash
# Check Pi
pi --version

# Check skills
ls ~/.pi/agent/skills/ | wc -l  # Should output: 83

# Check extensions
ls ~/.pi/agent/extensions/ | wc -l  # Should output: ~26

# Test skill loading
pi --skill nodejs-express
```

---

## 🐛 Troubleshooting

### Pi not found
```bash
# Install Pi
npm install -g @earendil-works/pi-coding-agent
```

### Permission denied
```bash
# Linux/macOS
chmod +x install-pi-linux.sh

# Windows (Run as Administrator)
```

### Skills not loading
```bash
# Reinstall skills
./install-pi-linux.sh --force
```

### API key error
```bash
# Edit models.json
nano ~/.pi/agent/models.json
# Replace YOUR_API_KEY_HERE with actual key
```

---

## 📞 Support

- **GitHub**: [Repository Link]
- **Issues**: [Issues Link]
- **Documentation**: [Docs Link]

---

## 📝 Version

- **Package Version**: 1.3.0
- **Pi Version**: 0.77.0+
- **Skills Version**: 2.0.0
- **Last Updated**: 2026-05-29

### Changelog

#### v1.3.0 (2026-05-29)
- RESTORED: `plan-mode` extension - Planning mode extension
- UPDATED: Extensions count to 26
- All 83 skills included

#### v1.2.0 (2026-05-29)
- UPDATED: `settings.json` - Version 0.77.0, added new models
- UPDATED: `models.json` - Environment variable format for API key
- All 83 skills included

#### v1.1.0 (2026-05-25)
- UPDATED: `file-trigger.ts` - Fixed trigger file location to use ~/.pi/agent/
- UPDATED: `worker.md` - Enhanced subagent definition with better output format
- All 83 skills included

#### v1.0.0 (2026-05-24)
- Initial release
- 83 skills included
- 25 extensions included
- 4 custom prompts included
- 4 agent definitions included

---

## 📄 License

Each component may have its own license. Check individual files for details.

---

**Enjoy your Pi Coding Agent with 83 skills!** 🚀
