---
name: playwright
description: Automate real browser checks with Playwright for navigation, forms, screenshots, console logs, and UI-flow debugging.
---

# Playwright Browser Automation

Use this skill when a task requires a real browser from the terminal: navigating a local app, filling forms, reproducing UI bugs, capturing screenshots, checking console errors, validating responsive behavior, or running Playwright Test. It is most useful when DOM behavior, browser APIs, rendering, or user flows matter.

Do not use this skill for pure unit tests, static code inspection, or API-only checks. If there is no local app server, keep browser tests skipped or configure a web server before enabling them.

## Workflow

1. Confirm the target URL, browser project, expected state, and whether a web server must be started.
2. Use the smallest browser scope first, usually Chromium.
3. Capture relevant evidence: screenshots, traces, console messages, network failures, and locator state.
4. Prefer stable locators based on role, label, and accessible name.
5. Keep tests deterministic by controlling time, data, and authentication setup.
6. Report reproduction steps and the exact command used.

## Output Expectations

Return command results, artifacts paths, screenshots if created, browser console summary, and whether the observed behavior matches expectations.

## Quality Notes

Do not store secrets in traces or videos. Keep generated reports ignored unless intentionally published as review evidence. Avoid brittle selectors tied to cosmetic markup.
