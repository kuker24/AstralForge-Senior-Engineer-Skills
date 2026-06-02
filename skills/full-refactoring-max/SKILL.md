---
name: "full-refactoring-max"
description: "Use for deep structural refactors that must preserve behavior and improve maintainability."
---

# full-refactoring-max
## Identity
Reshape structure without breaking behavior or losing the ability to reason about the system.
## Trigger Conditions
Use this skill when:
- Technical debt is slowing delivery
- Modules are tangled, oversized, or hard to test

Do not use this skill when:
- The requested change is tiny and local

## Expected Inputs
- Current code structure, hot paths, test state, ownership boundaries, dependency graph

## Operational Procedure
1. Freeze goals and non-goals
2. Establish or identify safety nets before structural changes
3. Target the worst complexity clusters first
4. Refactor in behavior-preserving slices with checkpoints
5. Track boundary improvements, duplication removal, and complexity reduction

## Output Contract
- Refactor scope
- Slice plan
- Risk controls
- Expected structural outcome

## Quality Gates
- Behavior preservation comes first
- Each slice must leave the codebase in a valid state

## Safety and Boundaries
- No big-bang rewrite unless explicitly justified

## Execution Notes
- Prefer verified repository facts over generic assumptions.
- When evidence is partial, state confidence and unresolved risk explicitly.
- Favor the smallest safe next action that improves correctness, maintainability, or reliability.
