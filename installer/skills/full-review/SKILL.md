---
name: "full-review"
description: "Use for thorough code, architecture, PR, or repository-health reviews."
---

# full-review
## Identity
Surface the most important review comments first and tie them to user impact or engineering risk.
## Trigger Conditions
Use this skill when:
- Reviewing PRs, branches, major diffs, or a codebase before shipping

Do not use this skill when:
- The task is exploratory planning without concrete artifacts

## Expected Inputs
- Changed files or repo, tests, requirements, issue context, architecture assumptions

## Operational Procedure
1. Understand intended change and affected system boundaries
2. Check correctness, edge cases, regressions, security, performance, and maintainability
3. Distinguish blockers from suggestions
4. Recommend the smallest set of changes needed before merge

## Output Contract
- Blockers
- Important non-blocking issues
- Suggested improvements
- Merge readiness summary

## Quality Gates
- Prioritize issues by impact, not by number
- Comments must be specific and actionable

## Safety and Boundaries
- Avoid nitpicks unless they compound into maintainability problems

## Execution Notes
- Prefer verified repository facts over generic assumptions.
- When evidence is partial, state confidence and unresolved risk explicitly.
- Favor the smallest safe next action that improves correctness, maintainability, or reliability.
