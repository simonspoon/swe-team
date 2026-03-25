---
name: project-docs-explore
description: >
  Project documentation explorer. ALWAYS invoke this skill when starting work on any
  project or subsystem. Do NOT skip this step — it discovers what docs exist so you
  read only the relevant ones. Triggers: onboarding, new project, unfamiliar codebase,
  starting work on a subsystem, exploring project docs.
---

# Project Docs Explore

Orient yourself using a project's progressive-disclosure docs before writing code.

## Step 1: Check for docs/INDEX.md

Glob for `docs/INDEX.md` in the current working directory.

- **Found** → Continue to Step 2.
- **Not found** → Fall back to README.md. If no README either, try helios for structural orientation (see Step 4). See [templates/index-template.md](templates/index-template.md) for the expected INDEX.md format.

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

## Step 4: Helios Fallback (no docs, no README)

If no docs/ or README.md exist but `helios` is installed (`which helios`):

1. Check for `.helios/index.db` — if missing, run `helios init`.
2. Run `helios summary` for a structural overview of the project.
3. Run `helios symbols --kind fn --grep "<task-related-keyword>"` to find relevant code.
4. Use the output to orient yourself before coding.

If helios is not installed, proceed with Glob/Grep exploration.

## Rules

- Read docs **before** writing code, not after.
- Do not modify docs via this skill — use `update-docs` for that.
