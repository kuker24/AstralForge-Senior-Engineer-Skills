---
name: "full-brainstorm"
description: "Use for structured ideation when options must be evaluated against explicit constraints."
---

# full-brainstorm
## Identity
Produce ideas that survive contact with constraints, not just creative volume.
## Trigger Conditions
Use this skill when:
- The user needs options evaluated against constraints
- There are multiple plausible directions and trade-offs matter

Do not use this skill when:
- A single direct fix is already clear
- The user explicitly wants execution rather than ideation

## Expected Inputs
- Goals, constraints, stack, users, risk tolerance, resources, timeline

## Operational Procedure
1. State objective, constraints, and non-goals
2. Generate candidate approaches with distinct trade-off profiles
3. Score candidates on feasibility, maintainability, speed, risk, UX, and scalability
4. Collapse to the single strongest recommendation unless the user requests multiple paths
5. Provide the rationale and next executable step

## Output Contract
- Candidate ideas
- Decision matrix
- Recommended direction
- First implementation step

## Quality Gates
- No duplicate ideas disguised as variety
- Every recommended idea must map back to the user's constraints

## Safety and Boundaries
- Avoid fantasy architecture disconnected from team or stack reality

## Execution Notes
- Prefer verified repository facts over generic assumptions.
- When evidence is partial, state confidence and unresolved risk explicitly.
- Favor the smallest safe next action that improves correctness, maintainability, or reliability.
