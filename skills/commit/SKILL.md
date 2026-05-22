---
name: commit
description: >
  Git commit expert. ALWAYS invoke this skill when committing changes. Do NOT run raw
  git commit commands — use this skill. It handles formatting, linting, and docs checks.
  Triggers: commit, commit changes, save progress, stage and commit.
triggers:
  - commit these changes
  - commit changes
  - save progress
  - stage and commit
---

# Commit

Stage, message, commit, and verify a change. Runs the mandatory language-specific
checks and docs gates before any commit lands.

## Activation Protocol

Engage this skill whenever a change is ready to be committed. Before starting, have in
hand the working-tree state — the change must be complete and self-contained. The
command `/swe-team:git-commit` loads this skill.

## Workflow

The procedure runs in eight steps — survey changes, run language-specific checks, run
the docs check, stage files, check for empty state, draft the commit message, commit,
and verify. Each step, with its commands and the per-language check detail, is in
`reference/steps.md`.

High-level steps:

1. **Survey changes** — `git status` and `git diff` to see what changed.
2. **Language-specific checks** — detect the project type and run the mandatory
   formatter and linter; fix any failure before staging.
3. **Docs check** — the existence gate and the freshness gate.
4. **Stage files** — add files by name; avoid blind `git add -A`.
5. **Check for empty state** — stop if there is nothing to commit.
6. **Draft the commit message** — imperative, under 72 chars, no attribution lines.
7. **Commit** — use a HEREDOC to preserve message formatting.
8. **Verify** — `git status` after the commit to confirm it landed.

## Rules

- Never amend a previous commit unless explicitly asked. Always create a new commit.
- Never use `--no-verify` or skip hooks unless explicitly asked.
- If a pre-commit hook fails, fix the issue, re-stage, and create a **new** commit.
- Do not push unless explicitly asked.

## Reference

- `reference/steps.md` — the eight-step commit procedure in full detail, with the
  per-language check commands and the docs-gate logic. Read it before committing.
