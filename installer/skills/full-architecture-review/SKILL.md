---
name: full-architecture-review
description: Review system architecture for scalability, reliability, and maintainability. Use when evaluating architecture, planning scaling, or assessing technical debt.
---

# Full Architecture Review

## When to Use

- Evaluating system architecture
- Planning scaling strategy
- Assessing technical debt
- Reviewing design decisions

## Input

- System documentation
- Current architecture diagrams
- Performance metrics
- Business requirements

## Output

- Architecture review report
- Risk assessment
- Improvement recommendations
- Roadmap

## Checklist

1. **System Design Review**
   - Evaluate component coupling
   - Check scalability patterns
   - Review data flow
   - Assess fault tolerance

2. **Infrastructure Review**
   - Review deployment architecture
   - Check redundancy
   - Evaluate monitoring
   - Assess disaster recovery

3. **Code Architecture**
   - Review design patterns
   - Check separation of concerns
   - Evaluate testability
   - Assess maintainability

4. **Security Review**
   - Check authentication
   - Review authorization
   - Assess data protection
   - Evaluate compliance

## Best Practices

- Document current state
- Identify pain points
- Prioritize improvements
- Create actionable roadmap
- Involve team in review
- Review regularly

## Anti-Patterns

❌ Big bang rewrites
❌ Ignoring technical debt
❌ No documentation
❌ Not involving team
❌ One-time review

## Validation

- Review is comprehensive
- Risks are identified
- Recommendations are actionable
- Roadmap is realistic

## Examples

### Example 1: Architecture Review Template
```markdown
# Architecture Review: [Project Name]

## Executive Summary
[Brief overview of findings]

## Current State
- **Components**: [List main components]
- **Data Flow**: [Describe data flow]
- **Infrastructure**: [Describe infrastructure]

## Findings

### Critical Issues
1. [Issue]: [Description]
   - Impact: [High/Medium/Low]
   - Recommendation: [Action]

### Improvements
1. [Area]: [Description]
   - Benefit: [Expected improvement]
   - Effort: [High/Medium/Low]

## Recommendations
1. [Priority 1]: [Action items]
2. [Priority 2]: [Action items]

## Roadmap
- **Q1**: [Quick wins]
- **Q2**: [Major improvements]
- **Q3**: [Strategic changes]
```

### Example 2: Scalability Assessment
```typescript
// lib/architecture/scalability.ts
interface ScalabilityCheck {
  component: string;
  currentState: string;
  bottleneck: string;
  recommendation: string;
  effort: 'low' | 'medium' | 'high';
}

export function assessScalability(): ScalabilityCheck[] {
  return [
    {
      component: 'Database',
      currentState: 'Single PostgreSQL instance',
      bottleneck: 'Read heavy workload, single connection pool',
      recommendation: 'Add read replicas, implement connection pooling',
      effort: 'medium',
    },
    {
      component: 'API',
      currentState: 'Single Express server',
      bottleneck: 'No horizontal scaling, stateful sessions',
      recommendation: 'Add load balancer, externalize session store',
      effort: 'high',
    },
    {
      component: 'Cache',
      currentState: 'No caching layer',
      bottleneck: 'Repeated database queries',
      recommendation: 'Add Redis cache for frequently accessed data',
      effort: 'low',
    },
  ];
}
```

### Example 3: Technical Debt Assessment
```typescript
// lib/architecture/techDebt.ts
interface TechDebtItem {
  area: string;
  description: string;
  impact: 'low' | 'medium' | 'high';
  effort: 'low' | 'medium' | 'high';
  priority: number;
}

export function assessTechDebt(): TechDebtItem[] {
  return [
    {
      area: 'Testing',
      description: 'No integration tests for payment flow',
      impact: 'high',
      effort: 'medium',
      priority: 1,
    },
    {
      area: 'Documentation',
      description: 'API documentation outdated',
      impact: 'medium',
      effort: 'low',
      priority: 2,
    },
    {
      area: 'Dependencies',
      description: 'Using deprecated authentication library',
      impact: 'high',
      effort: 'high',
      priority: 3,
    },
  ];
}
```

### Example 4: Architecture Decision Record
```markdown
# ADR-001: Use Event-Driven Architecture

## Status
Accepted

## Context
[Description of the problem]

## Decision
We will use event-driven architecture for inter-service communication.

## Consequences
### Positive
- Loose coupling between services
- Better scalability
- Easier to add new consumers

### Negative
- More complex debugging
- Eventual consistency
- Need for idempotency

## Alternatives Considered
1. Synchronous REST: Too tightly coupled
2. Shared database: Not scalable
```

## Architecture Patterns

| Pattern | Use Case | Trade-off |
|---------|----------|-----------|
| Monolith | Simple apps, small team | Easy to develop, hard to scale |
| Microservices | Complex domains, large team | Scalable, complex |
| Event-Driven | Async workflows | Decoupled, eventual consistency |
| CQRS | Read-heavy systems | Optimized reads, complex |

## Output Structure

```
├── docs/
│   ├── architecture-review.md
│   ├── adr/                    # Architecture Decision Records
│   │   ├── 001-event-driven.md
│   │   └── 002-database-choice.md
│   ├── diagrams/
│   │   ├── system-overview.md
│   │   └── data-flow.md
│   └── roadmap.md
└── tools/
    └── architecture-checklist.md
```
