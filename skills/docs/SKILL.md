---
name: docs
description: >
  Documentation update expert. ALWAYS invoke this skill when updating, syncing, or fixing
  project documentation (docs/, README.md). Do NOT edit documentation files directly —
  use this skill. Triggers: update docs, sync docs, docs are stale, update the readme,
  after any code change that affects user-facing behavior.
triggers:
  - update docs
  - update documentation
  - sync docs
  - docs are stale
  - update the readme
  - /docs
---

# Docs

Update existing project documentation to reflect code changes. Works with any `docs/`
structure — typically one created by the `setup-docs` skill, but any organized doc tree
will do.

## Activation Protocol

Engage this skill after adding, removing, or renaming features, commands, types, or APIs;
after changing build commands, flags, dependencies, or configuration; when the user says
docs are stale; or as a post-implementation step after a feature branch. Before starting,
have in hand the set of code changes to document.

Three rules govern every run:

- **README.md is a doc target** — you MUST read it and check it. If no changes are
  needed, say so explicitly. Do not silently skip it.
- **Read before writing** — never guess at new behavior. Read the changed source code to
  extract exact details.
- **Discover first** — never assume a doc structure exists. Read what's there before
  editing.

## Workflow

The procedure runs in nine steps — discover the doc structure, detect what changed in
code, map changes to affected docs, read before writing, make targeted edits, capture
learned knowledge, update README.md, update INDEX.md, and verify. Each step, with its
commands and the categorization detail, is in `reference/workflow.md`.

High-level steps:

1. **Discover the doc structure** — find every doc file, build a topic-to-file map.
2. **Detect what changed in code** — scope the code changes via git diff or session
   knowledge.
3. **Map changes to affected docs** — categorize each change to dev docs, user docs, or
   README.
4. **Read before writing** — read the current doc and the changed source for each
   affected file.
5. **Make targeted edits** — surgical Edit-tool updates, never whole-file rewrites.
6. **Capture learned knowledge** — record hard-won gotchas into `docs/dev/`.
7. **Update README.md** — check it against reality; state explicitly if unchanged.
8. **Update INDEX.md** — keep the topic-to-file index in sync.
9. **Verify** — build if source changed, grep for stale references, check cross-links.

## Reference

- `reference/workflow.md` — the nine-step workflow in full detail, with the commands for
  each step and the change-categorization rules. Read it before starting a documentation
  update.
