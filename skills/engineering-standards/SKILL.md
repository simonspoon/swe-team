---
name: engineering-standards
description: >
  Engineering conventions knowledge base. ALWAYS invoke this skill BEFORE writing, modifying,
  or deleting any code. Do NOT skip this step — it loads the bundled conventions KB and the
  project's CLAUDE.md so project conventions and domain knowledge inform your work. Triggers:
  any code task, architecture decisions, debugging, design patterns, testing strategy,
  performance, security.
---

# Engineering Standards Knowledge Base

A self-evolving knowledge base of engineering conventions. The `reference/` directory in
the skill's own directory is the living conventions KB — the bundled static source of
general engineering knowledge, curated by this skill. Project-specific conventions and
preferences are read at load time from the project's `CLAUDE.md`.

## Critical Requirements

- **Never upgrade project dependencies, toolchains, frameworks, or libraries without explicitly asking the user first.** Even if versions are outdated, present findings and ask for confirmation before making any changes.

- **Change completeness: enumerate dependents before declaring done.** Work is not done until all artifacts that mirror or depend on the changed thing have been updated. Before declaring a task complete, produce an explicit enumeration:
  - Sibling views/components that render the same data
  - Lockfiles alongside manifests (`package.json` ↔ lockfile, `Cargo.toml` ↔ `Cargo.lock`, `pyproject.toml` ↔ `uv.lock`)
  - Docs alongside code (README, inline docs, generated API docs)
  - Update paths alongside creation paths (if create flow changed, edit flow likely needs the same change)
  - Binaries after asset rebuilds

  Partial completion is a latent divergence bug, not acceptable progress. The enumeration must be produced explicitly — implicit "I checked" is not sufficient.

- **Deliver in verified, committed increments — not one big-bang.** For work spanning more than a few files: land a thin working slice, verify it (build + tests; for UI or behavior changes, actually run and exercise it — not just compile it), then commit that verified state before extending. Never build on a layer you have not verified — if a layer cannot be verified in the current environment (e.g. a GUI change with no display), stop and hand it back for verification rather than stacking more changes on top. A large feature delivered as one uncommitted, unverified diff is a liability, not progress; if it is too large to slice yourself, return it to MAESTRO for decomposition into child tasks.

## Activation Protocol

On every activation:

1. **Read the project `CLAUDE.md`.** This is the authoritative source of project-specific conventions, behavioral rules, and preferences. Read it before making any design decision. Project conventions in `CLAUDE.md` override the general conventions KB in `reference/` when they conflict.
2. Determine the SE domain(s) of the current task: architecture, debugging, patterns, testing, performance, security, code-review, tooling, or other.
3. Read `reference/INDEX.md` from the skill's own directory. If a relevant entry exists, read the conventions file(s). If the index is empty, skip to step 5.
4. Apply combined knowledge to the task. **Project conventions from `CLAUDE.md` override general conventions in `reference/` when they conflict.**
5. **Staleness check**: If any read conventions file has a `Last researched` date older than 3 months, flag it as potentially stale. If the task depends on version-specific info (e.g., library versions, framework features), re-research before relying on that data.
6. **Knowledge gap check**: If the task involves a language, framework, or pattern with no entry in `reference/INDEX.md`, follow the Research Protocol. This applies to implementation work too, not just design decisions.

Now do the task. **When the task is complete, execute the Post-Task Protocol below.**

## Post-Task Protocol

Run this after every task, before responding to the user with final results.

1. **Capture new knowledge**: Did you learn something reusable about the language, framework, or pattern used? If yes and it's not already in the conventions KB, write it via the Research Protocol (prefer `Sources: "experience"` over web research for lessons learned by doing).
2. **Evolution check**: Check `meta/evolution-log.md` entry count. If it exceeds 50 entries, trigger consolidation (see Evolution & Consolidation below).

This protocol is how the conventions KB grows. Do not skip it.

## Research Protocol

**Trigger**: The task involves a language, framework, or pattern where `reference/INDEX.md` has no entry, OR the existing entry is thin (under 20 lines), OR the user explicitly asks to research something. This includes implementation work — if you're writing Go code and there's no Go conventions file, that's a gap.

**Do NOT research** when existing knowledge is sufficient or during urgent debugging (note the gap for later instead). For post-work capture, prefer writing from experience over web research — what you just learned by doing is more valuable than generic articles.

Process:
1. Use WebSearch to find authoritative, current sources on the topic.
2. Synthesize findings into a conventions file using the Knowledge File Format below.
3. Create the domain subdirectory under `reference/` if it doesn't exist (e.g., `reference/patterns/`).
4. Write the file to `reference/<domain>/<topic-in-kebab-case>.md`.
5. Update `reference/INDEX.md` — add a row to the table.
6. Append a row to `meta/evolution-log.md`.
7. Briefly tell the user what was learned and stored.

## Knowledge File Format

Every file in `reference/` follows this structure:

```markdown
# [Topic Title]
Last updated: [YYYY-MM-DD]
Last researched: [YYYY-MM-DD] (required for tooling/library/framework files)
Sources: [URLs or "experience"]

## Summary
[2-3 sentence overview]

## Key Principles
- [Principle with brief explanation]

## Practical Guidance
[When to apply, how to apply, common pitfalls]

## Related Topics
- [Links to related conventions files if they exist]
```

## Evolution & Consolidation

The Post-Task Protocol checks the evolution log entry count after every task. **If log exceeds 50 entries**, trigger consolidation:
1. Survey all files via `reference/INDEX.md`.
2. Merge overlapping files in the same domain into single, refined files.
3. Remove redundant files and update INDEX.md.
4. Reset the evolution log with a consolidation summary entry.

**Guardrails**:
- **150 lines per file max.** If a file exceeds this, split into sub-topic files.
- **30 conventions files max.** If exceeded, consolidate smallest/most-related files before creating new ones.
- **Staleness (general)**: If a file's "Last updated" date is 6+ months old and the topic comes up, re-research and refresh it.
- **Staleness (tooling/libraries/frameworks)**: If a file's "Last researched" date is 3+ months old and the task depends on version-specific info, re-research before relying on it. Update the "Last researched" date after refreshing.

## Index Formats

**reference/INDEX.md**:

| Domain | Topic | File | Added |
|--------|-------|------|-------|

## Rules

1. **Only modify SKILL.md via explicit user request.** During normal activation, only `reference/` and `meta/` evolve.
2. **Read before write.** Always check existing knowledge before creating new files.
3. **Project conventions win.** When general knowledge and a project convention from `CLAUDE.md` conflict, follow the project convention.
4. **Skip research during urgent debugging** unless asked. Apply best available knowledge; note the gap for later.
5. **Stable paths.** Use descriptive, kebab-case filenames. Never rename existing files without updating INDEX.md.
6. **Relative paths for conventions.** Reference conventions files relative to the skill directory (e.g., `reference/architecture/rust-cli-patterns.md`).
7. **Be concise.** Conventions files should be actionable, not encyclopedic. Favor practical guidance over theory.
