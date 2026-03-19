---
name: project-docs-explore
description: >
  Explore and understand a project's documentation structure. Use this skill
  proactively when onboarding to a new project, exploring an unfamiliar
  codebase, or starting work on a subsystem you haven't touched before.
  Helps agents discover what docs exist and read only the relevant ones.
---

# Project Docs Explore

Orient yourself using a project's progressive-disclosure docs before writing code.

## Step 1: Check for docs/INDEX.md

Glob for `docs/INDEX.md` in the current working directory.

- **Found** → Continue to Step 2.
- **Not found** → Fall back to README.md. If no README either, report to user: "No project documentation found. Proceeding with code-level exploration only." See [templates/index-template.md](templates/index-template.md) for the expected INDEX.md format.

## Step 2: Read INDEX.md

Read `docs/INDEX.md` in full. It contains a table with columns like:

| Topic | File | When to read |
|-------|------|--------------|

This table maps doc files to task areas.

## Step 3: Match task to relevant docs

1. Identify your current task area (subsystem, feature, or concern).
2. Scan the "When to read" column for rows matching your task.
3. Read **only** the matching doc file(s) — not all docs.
4. If **no rows match**, proceed without docs — not every task has one.
5. If **multiple rows match**, read all of them.

Use doc content to inform implementation. Docs provide architecture context
and conventions but do not replace reading source code.

## Rules

- Read docs **before** writing code, not after.
- Do not modify docs via this skill — use `update-docs` for that.
