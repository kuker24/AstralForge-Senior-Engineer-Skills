# Changelog

All notable changes to this project will be documented in this file.

---

## [2.1.0] - 2026-05-29

### Updated
- **Pi Installer v1.3.0**
  - Restored `plan-mode` extension
  - Updated extensions count to 26
  - Updated `settings.json` to version 0.77.0
  - Added new models: `gitlawb-opengateway/mimo-v2.5`, `opencode-go/mimo-v2.5-pro`, `xiaomi-token-plan-sgp/mimo-v2.5`
  - Updated `models.json` with environment variable format for API key (`$OPENGATEWAY_API_KEY`)
  - Updated `README.md` with changelog

### Added
- Complete Pi installer package (`installer/`)
  - `install-pi-linux.sh` - Linux/macOS installer
  - `install-pi-windows.ps1` - Windows installer
  - Configuration files (settings, models, presets)
  - 26 extensions (including plan-mode)
  - 4 custom prompts
  - 4 agent definitions
  - 83 skills

### Documentation
- Updated main `README.md` with installer section
- Added `installer/README.md` with detailed documentation
- Added `reports/global-installation-report.md`

---

## [2.0.0] - 2026-05-24

### Added
- **20 new skills (P1+P2+P3)**
  - P1 (8): nodejs-express, docker-kubernetes, typescript, tailwind-css, nextjs, prisma-drizzle, authentication, aws-cloud
  - P2 (7): mongodb, redis, websocket, graphql-impl, message-queue, cicd-pipeline, monitoring-logging
  - P3 (5): vuejs-svelte, react-native-flutter, microservices, ai-ml-integration, web3-blockchain

- **8 new full-* skills**
  - full-api-design, full-database-migration, full-performance-audit
  - full-dependency-audit, full-architecture-review, full-data-pipeline
  - full-infrastructure-as-code, full-api-testing

### Updated
- **13 existing full-* skills**
  - Added `references/sources.md` to all
  - Updated content and documentation

### Documentation
- `SKILLS_MANIFEST.md` - Complete skill listing
- `MISSING_SKILLS_CHECKLIST.md` - Skill tracking
- `reports/skill-completion-report.md` - Completion report
- `reports/source-skill-index.md` - Source index

---

## [1.0.0] - 2026-05-24

### Added
- Initial release with 55 skills
- Installation scripts (Linux/Windows)
- Verification scripts
- Basic documentation

---

## Version Numbering

This project uses [Semantic Versioning](https://semver.org/):
- **MAJOR**: Incompatible API changes
- **MINOR**: New functionality in a backwards compatible manner
- **PATCH**: Backwards compatible bug fixes

---

## Release Process

1. Update version in `README.md`
2. Update `CHANGELOG.md` with changes
3. Run `./verify.sh` to ensure all skills are valid
4. Run `./install-global.sh` to test installation
5. Create git tag with version number
6. Push to repository
