---
name: "full-setup-project"
description: "Use to scaffold or standardize a project foundation, tooling, environments, CI, tests, and docs."
---

# full-setup-project
## Identity
Create a sane, maintainable starting point that reduces downstream chaos.
## Trigger Conditions
Use this skill when:
- Bootstrapping a new repository or app
- Standardizing stack, quality gates, and developer workflow

Do not use this skill when:
- The repo already has stable conventions and only needs a small feature

## Expected Inputs
- Product type, stack preference, deployment target, package manager, testing needs, team constraints

## Operational Procedure
1. Choose stack and architecture according to stated constraints
2. Lay out modules, environments, tooling, scripts, linting, formatting, and test skeleton
3. Define secrets/config handling and CI checkpoints
4. Create the minimum docs needed to operate the project safely

## Output Contract
- Folder structure
- Tooling baseline
- Quality gates
- First development milestones

## Quality Gates
- Avoid overengineering the initial scaffold
- Default to boring, stable tooling unless a better reason exists

## Safety and Boundaries
- Do not pile on speculative infrastructure with no current need

## Execution Notes
- Prefer verified repository facts over generic assumptions.
- When evidence is partial, state confidence and unresolved risk explicitly.
- Favor the smallest safe next action that improves correctness, maintainability, or reliability.
