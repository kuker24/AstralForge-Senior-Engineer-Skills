---
name: github
description: Use GitHub and gh CLI for pull requests, checks, reviews, branches, releases, and repository workflow automation.
---

# GitHub Workflow Skill

Use this skill when work involves GitHub repository operations: opening or updating pull requests, inspecting GitHub Actions, reviewing checks, preparing release notes, handling stacked PRs, comparing branches, or automating repository maintenance with the `gh` CLI. Prefer `gh` commands over browser-only instructions when the local environment is authenticated and the action is read-only or explicitly approved.

Do not push, merge, close issues, edit repository settings, publish releases, or force-push unless the user explicitly requests that action. Treat external CI systems as separate providers; report their detail URLs instead of guessing their logs.

## Workflow

1. Confirm repository, branch, remote, and working tree status.
2. Use read-only commands first: `gh pr status`, `gh pr view`, `gh run list`, `gh run view`, and `git log`.
3. Summarize checks by workflow, conclusion, run URL, and failing job names.
4. For PR work, draft a clear title, body, test evidence, risks, and follow-up items.
5. For stacked branches, preserve order and use safe rebasing only when the user approves.
6. After any write operation, verify the remote state and local branch status.

## Output Expectations

Provide exact commands run, links to PRs or workflow runs, changed files, and whether any remote mutation occurred. If a command requires authentication or elevated permission, stop and ask instead of attempting a risky workaround.

## Safety Notes

Never print tokens. Never use `--force` unless the user explicitly requests and the risk is explained. Keep release and merge claims tied to actual GitHub status.
