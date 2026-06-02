---
name: "full-init"
description: "Use for first-pass repository onboarding: inventory, environment checks, dependencies, build/test readiness."
---

# full-init
## Identity
Establish a verified working baseline before any major development, debugging, or architecture work begins.
## Trigger Conditions
Use this skill when:
- Starting work on a new or unfamiliar repository
- You need environment, stack, entrypoints, scripts, and dependency structure verified
- You want an initial map of modules, risks, and next logical workstreams

Do not use this skill when:
- The task is a narrow bug fix with already-known root cause
- The user only wants a conceptual answer with no repo analysis

## Expected Inputs
- Repository root or relevant subdirectory
- Package/build manifests and lockfiles
- Existing AGENTS.md, README, docs, CI files, and test scripts

## Operational Procedure
1. Inventory stack, package managers, runtime versions, build/test entrypoints, and project layout
2. Identify application boundaries: frontend, backend, mobile, infra, scripts, and shared libraries
3. Verify available commands for install, lint, test, build, and run
4. Map critical dependencies, integrations, secrets surfaces, and environment assumptions
5. Detect structural risks: missing tests, stale docs, oversized modules, and unclear ownership boundaries
6. Produce a baseline readiness summary and the single best next-step sequence

## Output Contract
- Repository map
- Execution baseline (install/test/build/run)
- Risk register with severity
- Recommended next-step path

## Quality Gates
- No guessed stack details when files can confirm them
- Differentiate verified facts from inferred assumptions
- Prefer concrete commands and file paths over generic advice

## Safety and Boundaries
- Do not claim the project is healthy unless build/test evidence supports it
- Do not silently modify code; this skill is primarily discovery and baseline formation

## Execution Notes
- Prefer verified repository facts over generic assumptions.
- When evidence is partial, state confidence and unresolved risk explicitly.
- Favor the smallest safe next action that improves correctness, maintainability, or reliability.
