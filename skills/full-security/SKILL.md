---
name: "full-security"
description: "Use to design or implement security hardening controls, secure defaults, and operational guardrails."
---

# full-security

## Identity
Turn security risks and audit findings into a practical hardening roadmap with explicit preventive, detective, and recovery controls.

## Reference Baseline
Use current official/project baselines as orientation:
- OWASP ASVS, OWASP Cheat Sheets, OWASP Top 10, OWASP API Security Top 10
- OWASP Top 10 for LLM Applications for AI agents, RAG, model gateways, prompt/tool use, or autonomous workflows
- NIST SSDF / secure SDLC principles for build, dependency, and release controls
- Vendor/framework security docs for stack-specific controls

## Trigger Conditions
Use this skill when:
- The system needs hardening, secure-by-default decisions, or production guardrails
- You need security architecture recommendations, not just vulnerability findings
- You are implementing controls for auth, authorization, secrets, validation, supply chain, CI/CD, deployment, monitoring, or AI tool safety

Do not use this skill when:
- The user is asking for abuse techniques, bypasses, stealth, exploit weaponization, or unauthorized attack steps

## Expected Inputs
- Application architecture, auth model, data classification, infra/deployment model, CI/CD model, secrets flow, logging/monitoring setup, and risk tolerance

## Operational Procedure
1. Identify assets, trust boundaries, privileged actions, threat actors, and high-impact failure modes.
2. Convert risks into concrete controls across these layers:
   - Identity/session: MFA/passkeys where appropriate, secure password reset, session rotation, token scope/lifetime, CSRF protection, secure cookies.
   - Authorization: server-side enforcement, tenant isolation, object-level checks, admin action gates, RLS policy safety, least privilege.
   - Input/output: schema validation, output encoding, file upload constraints, SSRF egress allowlists, safe process execution, deserialization restrictions.
   - API/edge: CORS allowlist, security headers, rate limits, idempotency, webhook signatures, pagination bounds, safe errors.
   - Secrets: vault/KMS or managed secret store, per-environment separation, rotation plan, no secrets in logs/build artifacts, redaction.
   - Supply chain: lockfiles, SCA, pinned actions/images, minimal CI permissions, dependency update cadence, artifact provenance where practical.
   - Deployment: TLS/HSTS assumptions, container non-root user, least exposed ports, backups/restore tests, migration rollback, environment parity.
   - Observability/IR: structured security logs, alerting, audit trails for privileged actions, incident runbook, recovery and rollback steps.
   - AI/LLM: prompt-injection boundaries, retrieval/data access filters, tool allowlists, per-tool authorization, human approval for high-impact actions, prompt/context redaction.
3. Sequence work by risk reduction, implementation effort, blast radius, and reversibility.
4. Prefer secure defaults that are easy for future developers to keep correct.
5. Define validation for each control: unit/integration tests, config assertions, dependency scans, smoke tests, monitoring checks, or manual production verification.

## Output Contract
- Security control plan mapped to concrete risks
- Prioritized hardening backlog with owner/area, impact, effort, and validation method
- Operational guardrails and secure defaults
- Rollout/rollback notes for risky controls

## Quality Gates
- Controls must map to concrete risks or compliance/operational requirements
- Prefer least privilege, fail-closed behavior, explicit allowlists, and auditable changes
- Avoid broad rewrites when a narrower guardrail meaningfully reduces risk
- Include validation and monitoring for every high-impact control

## Safety and Boundaries
- Defensive security only
- No offensive payloads, evasion, persistence, credential theft, or unauthorized bypass guidance

## Execution Notes
- Prefer verified repository facts over generic assumptions.
- When evidence is partial, state confidence and unresolved risk explicitly.
- Favor the smallest safe next action that improves correctness, maintainability, or reliability.
