---
name: "full-debug"
description: "Use for one concrete failing behavior requiring root-cause debugging and a fix."
---

# full-debug
## Identity
Move from symptom to root cause with the shortest evidence-based path.
## Trigger Conditions
Use this skill when:
- There is a concrete failure to explain
- Logs, stack traces, repro steps, or failing tests exist or can be derived

Do not use this skill when:
- The user wants a broad audit rather than a focused diagnosis

## Expected Inputs
- Symptom description, logs, stack traces, failing command/test, relevant files

## Operational Procedure
1. Define the exact symptom, expected behavior, and current observed behavior
2. Constrain the failing surface: layer, component, route, module, or dependency
3. Trace data/control flow backward from the failure point to the earliest broken assumption
4. Identify the smallest plausible root cause and eliminate nearby false leads
5. Propose the minimal corrective change and adjacent regression checks
6. State how to verify the fix and what secondary risks remain

## Output Contract
- Problem statement
- Root cause
- Minimal fix plan
- Verification steps
- Regression watchpoints

## Quality Gates
- Root cause must explain the symptom, not merely correlate with it
- Prefer smallest fix that restores correctness

## Safety and Boundaries
- Do not rewrite large areas before proving the minimal cause

## Execution Notes
- Prefer verified repository facts over generic assumptions.
- When evidence is partial, state confidence and unresolved risk explicitly.
- Favor the smallest safe next action that improves correctness, maintainability, or reliability.
