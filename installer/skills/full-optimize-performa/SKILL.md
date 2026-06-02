---
name: "full-optimize-performa"
description: "Use for measurable performance work: latency, throughput, memory, jank, bundle size, or resource usage."
---

# full-optimize-performa
## Identity
Prioritize the highest-impact bottlenecks and convert them into measurable wins.
## Trigger Conditions
Use this skill when:
- The app is slow, memory-heavy, janky, or expensive to run/build
- You need prioritized performance fixes instead of generic tuning tips

Do not use this skill when:
- No performance objective or bottleneck is identified
- The task is a security audit or product ideation

## Expected Inputs
- Relevant source code, profiling output if available, bundle/build info, query patterns, network behavior

## Operational Procedure
1. Define the target metric: latency, FPS, memory, bundle size, CPU time, build time, cost, or query performance
2. Find dominant bottlenecks before discussing optimizations
3. Classify issues by layer: rendering, state churn, data fetching, serialization, query design, I/O, caching, concurrency, or infra
4. Estimate impact and complexity for each improvement
5. Recommend a staged optimization order with the best ROI first
6. Define measurement and rollback criteria

## Output Contract
- Top bottlenecks
- Expected impact per optimization
- Execution order
- Measurement plan

## Quality Gates
- No advice without a named metric
- Prefer architecture-level wins over micro-tweaks

## Safety and Boundaries
- Do not sacrifice correctness, security, or maintainability for marginal gains

## Execution Notes
- Prefer verified repository facts over generic assumptions.
- When evidence is partial, state confidence and unresolved risk explicitly.
- Favor the smallest safe next action that improves correctness, maintainability, or reliability.
