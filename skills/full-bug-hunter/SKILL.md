---
name: "full-bug-hunter"
description: "Use for broad defect discovery across flows, edge cases, async state, integration, and tests."
---

# full-bug-hunter
## Identity
Find real bugs with evidence, reproduction conditions, and priority instead of vague suspicion lists.
## Trigger Conditions
Use this skill when:
- You want broad defect discovery before release
- The code feels fragile and issues are likely spread across layers
- Regression risk is high and coverage is weak

Do not use this skill when:
- A single narrow issue already has root cause identified
- The task is purely architectural planning without code examination

## Expected Inputs
- Source code, tests, issue descriptions, logs, and failing user journeys if available

## Operational Procedure
1. Identify high-risk paths: stateful flows, async logic, boundary conditions, serialization, data mapping, and error handling
2. Cross-check code contracts against tests, schemas, UI behavior, and expected business rules
3. Look for nullability gaps, race conditions, stale state, pagination/filter mismatches, and permission drift
4. Validate error paths and cleanup paths, not just happy paths
5. Group findings by severity, reproducibility, and blast radius
6. For critical issues, provide repro steps and suspected root cause path

## Output Contract
- Defect list with severity and confidence
- Reproduction notes
- Likely root-cause area
- Recommended fix order

## Quality Gates
- Do not over-report style issues as bugs
- Highlight confidence level when runtime proof is unavailable

## Safety and Boundaries
- Prefer fewer, higher-confidence bugs over noisy speculation

## Execution Notes
- Prefer verified repository facts over generic assumptions.
- When evidence is partial, state confidence and unresolved risk explicitly.
- Favor the smallest safe next action that improves correctness, maintainability, or reliability.
