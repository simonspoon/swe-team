---
name: update-docs
description: Update project documentation (docs/ and README.md) to reflect recent code changes. Discovers the existing doc structure, detects what changed in code, and makes targeted updates to affected docs.
triggers:
  - update docs
  - update documentation
  - sync docs
  - docs are stale
  - update the readme
  - /update-docs
model: sonnet
---

# Update Docs

Update existing project documentation to reflect code changes. Works with any `docs/` structure — typically one created by the `setup-docs` skill, but any organized doc tree will do.

## When to Use

- After adding, removing, or renaming features, commands, types, or APIs
- After changing build commands, flags, dependencies, or configuration
- When a user says docs are stale or asks to sync them
- As a post-implementation step after a feature branch

## ⚠️ CRITICAL REQUIREMENTS

- **README.md is a doc target** — you MUST read it and check it. If no changes are needed, say so explicitly. Do not silently skip it.
- **Read before writing** — never guess at new behavior. Read the changed source code to extract exact details.
- **Discover first** — never assume a doc structure exists. Read what's there before editing.

## Workflow

### Step 1: Discover the Doc Structure

Before anything else, understand what documentation exists:

```bash
# Find all doc files
find docs/ -name '*.md' 2>/dev/null
ls README.md 2>/dev/null
```

Read `docs/INDEX.md` if it exists — it maps topics to files and tells you what each doc covers. If there's no INDEX.md, read the heading and first few lines of each doc file to build a mental map.

Build a **topic-to-file map** — for each doc file, note:
- What topic/subsystem it covers
- Whether it's developer-facing (`docs/dev/`) or user-facing (`docs/user/`)

### Step 2: Detect What Changed in Code

Determine the scope of code changes using one of these strategies:

**If changes were just made in this session:**
- You already know what changed — list the modified files and what was added/removed/renamed

**If there are uncommitted working tree changes:**
```bash
git status
git diff HEAD --name-only -- ':!docs/' ':!*.md'
git diff HEAD -- ':!docs/' ':!*.md'
```

**If asked to sync docs generally:**
```bash
# Find the last commit that touched docs
git log --oneline -1 -- docs/ README.md

# See what source files changed since then
git diff <that-commit>..HEAD --name-only -- ':!docs/' ':!*.md'
git diff <that-commit>..HEAD --stat -- ':!docs/' ':!*.md'
```

**If given a specific commit range or branch:**
```bash
git diff main..HEAD --name-only
git diff main..HEAD --stat
```

**Filter out noise:** Skip lock files (`Cargo.lock`, `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`), generated files, and build artifacts. These never require doc updates.

Read the changed source files to understand what actually changed — don't rely on filenames alone.

### Step 3: Map Changes to Affected Docs

Using your topic-to-file map from Step 1, identify which docs are affected. Categorize each code change:

**Changes that affect developer docs (`docs/dev/`):**
- New/changed/removed types, structs, enums, traits, or interfaces → find the doc that covers that subsystem
- Protocol or wire format changes → find the protocol/API doc
- Architecture changes (new modules, changed data flow) → find the architecture doc
- Error types or variants changed → find the relevant subsystem doc
- Bug fixes → update test descriptions in the contributing/testing doc; if the bug revealed a non-obvious gotcha (e.g., a subtle language footgun, an API that silently misbehaves), add a pitfall note to the relevant subsystem doc so future developers don't reintroduce it
- Test infrastructure changes (new test helpers, changed test commands, added test types, new fixtures) → find the testing or contributing doc
- CI pipeline changes (new required checks, changed test stages, added linting) → find the testing or contributing doc

**Changes that affect user docs (`docs/user/`):**
- New/changed/removed commands, CLI flags, or API endpoints → find the command reference or relevant guide
- Changed behavior, defaults, or error messages → find the relevant guide or troubleshooting doc
- New configuration options → find the config or getting-started doc

**Changes that affect README.md:**
- Public-facing features added or removed
- New flags or modes added to existing binaries — update the relevant Usage section
- Installation steps changed
- Requirements or dependencies changed
- Usage examples became stale

**If a mapped doc file doesn't exist, skip it.** Not every change needs every doc updated.

### Step 4: Read Before Writing

For each affected doc file:

1. **Read the current doc file** — understand its structure, style, and what it already says
2. **Read the changed source code** — extract exact new details (types, signatures, values, defaults)
3. **Identify the specific section** that needs updating — don't rewrite the whole file

### Step 5: Make Targeted Edits

Use the Edit tool for surgical updates. Prefer small, precise edits over rewriting entire files.

**Adding new items:**
- Add to the correct section, maintaining the existing style and order
- Add to tables by inserting a new row in the logical position
- If adding a new section, place it where it fits the existing document flow

**Removing items:**
- Remove the entry, row, or section cleanly
- Grep all doc files for references to removed items — update or remove cross-references

**Renaming items:**
- Grep all doc files for the old name and update every occurrence
- Check code blocks, table cells, prose, and cross-references

**Changing details (types, defaults, behavior):**
- Update the specific value — don't rewrite surrounding context
- If a default changed, grep all docs for the old default value

### Step 6: Capture Learned Knowledge

Review the conversation history for hard-won knowledge that would help future developers (or AI sessions) avoid repeating the same research. This step targets `docs/dev/` files only.

**Scan the conversation for these signals:**
- **API gotchas** — an API was assumed to exist but didn't, or behaved unexpectedly
- **Private/undocumented APIs** — a workaround required using private APIs, KVC, runtime introspection, or similar
- **Platform quirks** — OS version differences, framework behavior that contradicts documentation
- **Failed approaches** — something was tried and failed for a non-obvious reason
- **Build/tooling surprises** — unexpected compiler behavior, flag interactions, dependency issues
- **Performance findings** — measured data that explains why a particular approach was chosen
- **Verification approaches** — a non-obvious way to test or verify behavior was discovered (e.g., a specific test invocation that isolates the issue, a manual verification step that catches regressions)

**How to capture:**
1. Identify the relevant `docs/dev/` file using your topic-to-file map
2. Add a short note in the appropriate section — near the code/feature it relates to
3. Format as a concise callout: what the gotcha is, why it matters, what to do instead
4. Include concrete details (exact property names, bitmask values, version constraints) — don't be vague

**Style:** Write as a factual note, not a narrative. Future readers need the *conclusion*, not the research journey.

**Skip this step if:** the conversation was straightforward with no surprises, failed attempts, or non-obvious discoveries.

### Step 7: Update README.md

README.md is the public face. It should be accurate but doesn't need internals. **You MUST read README.md** — if no updates are needed, say so explicitly. Do not silently skip it.

**Check these sections against reality:**
- Overview / package list — does it match the current structure?
- Requirements — any new dependencies?
- Installation — any new steps?
- Usage / Commands — are examples still valid? Any new flags or modes missing?
- Architecture diagram (if present) — does it reflect current data flow?

**Style rules:**
- Match the existing README style — don't introduce new formatting
- Keep examples runnable — if syntax changed, update the examples
- Don't add implementation details — those belong in `docs/dev/`

### Step 8: Update INDEX.md

If `docs/INDEX.md` exists:

- **New doc file created** → add a row with topic, relative link, and "When to read" description
- **Doc file removed** → remove its row
- **Doc file renamed or topic changed** → update the link and description
- **No structural changes** → skip this step

### Step 9: Verify

1. **Run the build** (only if source code files were modified) — confirm no code was accidentally changed
2. **Grep for stale references** — search docs/ for old names, removed types, or changed defaults:
   ```bash
   # Example: if you renamed FooBar to BazQux
   grep -r "FooBar" docs/ README.md
   ```
3. **Check cross-references** — if doc A links to doc B, make sure the target still exists

## Principles

- **Discover first** — never assume a doc structure; read what exists
- **Edit, don't rewrite** — surgical updates preserve context and authorial voice
- **Read source before writing docs** — never guess at new behavior
- **Match existing style** — don't introduce new formatting conventions
- **README.md stays accurate** — every example should work, every list should be current
- **Skip what doesn't exist** — if the mapping says to update a file that isn't there, move on
