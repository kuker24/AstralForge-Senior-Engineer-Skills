# AstralForge v3.1.0 Release Notes Evidence

Published release: https://github.com/kuker24/AstralForge-Senior-Engineer-Skills/releases/tag/v3.1.0
Release target: `69bce2de8d24a23792a3b87114f11c7d52737efb`

## Highlights

- Adds Pi Core Tools integration for token-efficient agent workflows.
- Adds Context7 CLI + Skills documentation for on-demand library/API docs.
- Adds Serena MCP profile guidance for coding and repo-review modes.
- Adds Repomix token reporting and compressed-context workflow.
- Adds AstralForge Token Profile Router profiles: `minimal`, `coding`, `repo-review`, and `docs-research`.
- Adds Skill Security Auditor for semantic skill risk scanning.
- Adds Pi install, verify, and cleanup scripts with backup/dry-run safety.
- Stabilizes ECMA/Open XML references for docx, pptx, and xlsx skill audits.

## Verification

- CI: success — https://github.com/kuker24/AstralForge-Senior-Engineer-Skills/actions/runs/28136613415
- Security: success — https://github.com/kuker24/AstralForge-Senior-Engineer-Skills/actions/runs/28136613414
- Installers: success — https://github.com/kuker24/AstralForge-Senior-Engineer-Skills/actions/runs/28136613412
- `npm run verify:skills`: PASS
- `npm run audit:skills`: PASS, 83 PASS / 0 non-PASS
- `npm run audit:skill-security`: PASS
- `npm run quality:core-tools`: PASS
- Pi local install/verify: PASS
- Context7 CLI help: PASS
- Context7 interactive setup: manual/non-interactive note
- Serena: PASS
- Repomix: PASS

## Release Safety

- `v3.0.0` release/tag was not rewritten.
- `v3.0.0` still targets `17ea37eaaa9095f0a1210898027ce4b0874c0b88`.
- No force push was used.
- `v3.1.0` is a new release on top of verified main.
