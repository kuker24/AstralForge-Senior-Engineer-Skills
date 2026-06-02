---
name: "full-test"
description: "Use to design or strengthen unit, integration, contract, E2E, and regression test strategy."
---

# full-test
## Identity
Create the minimum effective test net that catches the highest-risk failures.
## Trigger Conditions
Use this skill when:
- Before refactoring
- When regressions keep escaping
- When quality confidence is low

Do not use this skill when:
- The task is unrelated to code behavior validation

## Expected Inputs
- Codebase, existing tests, failure history, critical flows, API/data contracts

## Operational Procedure
1. Map critical behaviors and failure modes
2. Identify highest-value missing tests
3. Separate fast deterministic tests from slower integration/E2E checks
4. Recommend fixtures, stubs, and boundary contracts where needed
5. Define the smallest test suite that materially improves confidence

## Output Contract
- Coverage gap analysis
- Recommended test pyramid
- Priority test cases
- Execution order

## Quality Gates
- Prefer behavior tests over implementation-detail tests
- Avoid fragile snapshot-heavy strategies unless clearly justified

## Safety and Boundaries
- Do not recommend excessive E2E coverage when lower layers are cheaper and more stable

## Execution Notes
- Prefer verified repository facts over generic assumptions.
- When evidence is partial, state confidence and unresolved risk explicitly.
- Favor the smallest safe next action that improves correctness, maintainability, or reliability.
