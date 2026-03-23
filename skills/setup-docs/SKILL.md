---
name: setup-docs
description: Create a progressive disclosure documentation system for any software project. Generates docs/ with dev/ and user/ subdirectories, and an INDEX.md for discovery.
triggers:
  - setup docs
  - create documentation
  - set up documentation
  - progressive disclosure docs
  - /setup-docs
---

# Setup Docs

Create a progressive disclosure documentation system for a software project. The goal: agents and humans read only what's relevant to their current task, instead of loading everything into every conversation.

## Output Structure

```
docs/
  INDEX.md              # Discovery hub with "when to read" guidance
  dev/                  # Developer/contributor documentation
    architecture.md     # Crate/module relationships, data flow, key abstractions
    ...                 # One file per major subsystem or concern
    contributing.md     # How to add features, run tests, common patterns
  user/                 # End-user documentation
    getting-started.md  # Installation, first use walkthrough
    commands.md         # Unified command/API reference
    ...                 # Guides, troubleshooting, etc.
```

## ⚠️ CRITICAL: Execution Method

This skill typically produces 6-10 files. After Phase 2 (planning), invoke `/swe-team:project-manager` to create a limbo task hierarchy and dispatch parallel writing agents. Do NOT try to write all files sequentially yourself.

**Prerequisite**: `/swe-team:project-manager` requires the `limbo` CLI. Before invoking it, check:

```bash
command -v limbo >/dev/null 2>&1 && echo "OK" || echo "MISSING"
```

If `limbo` is missing: **STOP.** Tell the user: "limbo CLI is not installed. /swe-team:setup-docs requires /swe-team:project-manager which requires limbo. Install limbo first, or run /swe-team:setup-docs manually." Do NOT proceed without limbo — the parallel dispatch workflow depends on it.

## Workflow

### Phase 1: Discover the Project

Before writing anything, understand what exists:

1. **Read README.md** — understand user-facing documentation
2. **Scan the codebase structure** — `ls` top-level, identify crates/packages/modules
3. **Read key source files** — models, types, main entry points. Extract exact details: type names, field names, method signatures, constants, defaults. This is your research — do it now, not in a separate phase.
4. **Find existing docs** — check for `docs/`, wiki references, inline doc comments
5. **Examine test infrastructure** — find test directories, config files (e.g. `pytest.ini`, `jest.config.*`, `.github/workflows/`), and a few sample test files. Note:
   - Test runner and commands (how to run the full suite, how to run a single test)
   - How tests are organized (unit / integration / e2e, directory conventions)
   - Custom fixtures, helpers, or test utilities
   - CI pipeline test steps, if present

### Phase 2: Plan the Documentation

Based on discovery, decide which files to create. Not every project needs every file. Use this checklist:

**Developer docs (`docs/dev/`) — one file per major concern:**

| Consider creating | When the project has |
|---|---|
| `architecture.md` | Multiple packages/crates/modules with relationships |
| `protocol.md` | Wire protocols, binary formats, API contracts |
| `data-model.md` | Complex data structures, schemas, or type hierarchies |
| `{subsystem}.md` | Any subsystem complex enough to warrant its own reference |
| `testing.md` | Multiple test types, custom fixtures/helpers, or non-trivial test setup. For simple projects, cover testing in `contributing.md` instead |
| `contributing.md` | Always — covers the "ripple" of adding a feature, code style, PR process |

**User docs (`docs/user/`) — one file per user task:**

| Consider creating | When the project has |
|---|---|
| `getting-started.md` | Installation steps, first-use walkthrough |
| `commands.md` | CLI commands, API endpoints, or multiple interfaces |
| `configuration.md` | Config files, environment variables, flags |
| `scripting-guide.md` | A scripting/plugin/extension system |
| `troubleshooting.md` | Known failure modes, error messages, debugging steps |

**Present the plan to the user before writing.** Use EnterPlanMode or AskUserQuestion to confirm the file list.

**Count your files.** Before proceeding, write down the exact file list and count. You will need this to verify you dispatch agents for ALL of them.

### Phase 3: Write

Create `docs/dev/` and `docs/user/` directories first. Then dispatch parallel writing agents via `/swe-team:project-manager`.

**Task structure for project-manager:**
- One root task for the overall docs effort
- One leaf task per doc file (no need for grouping tasks — they just add status management overhead)
- `block` all content file tasks → INDEX.md task (INDEX.md must wait for all content)

**Each writing agent does its own research.** Include in the agent prompt:
- The exact source files to read before writing
- The specific details to extract (types, fields, constants)
- The writing rules from this skill

**Accuracy matters more than speed.** Wrong docs are worse than no docs. Tell agents to read source before writing; never guess.

**Writing rules:**

- Start every file with a `# Title` heading
- Use tables for structured data (fields, variants, options)
- Use code blocks for types, signatures, and examples
- Include source file references so readers can jump to code
- Be precise — include types, defaults, and edge cases
- No emojis unless the project style uses them
- Keep each file focused on one topic — if it's getting long, split it

**Testing documentation content** (whether in `testing.md` or a section of `contributing.md`):

- How to run the full test suite (exact commands)
- How to run a single test or subset (by file, by name pattern, by marker/tag)
- Test directory layout and naming conventions
- Key fixtures, helpers, or test utilities and what they provide
- Any environment setup required for tests (databases, env vars, test servers)
- How to verify a feature works end-to-end (manual or automated)
- CI pipeline: what runs on PR, what runs on merge, any required checks

### Phase 4: Create INDEX.md

After all content files exist (blocked by dependencies in limbo), create `docs/INDEX.md` with:

- Two sections: **Developer Documentation** and **User Documentation**
- Three columns per table: **Topic**, **File** (relative link), **When to read**
- The "When to read" column is critical — it drives progressive disclosure by telling agents/humans when each file is relevant

Example:
```markdown
| Topic | File | When to read |
|-------|------|-------------|
| Architecture | [dev/architecture.md](dev/architecture.md) | Onboarding, understanding module relationships |
| Contributing | [dev/contributing.md](dev/contributing.md) | Adding features, running tests |
```

### Phase 5: Verify

1. Run the project's build command — ensure no code was broken (there should be no code changes)
2. Verify all planned files exist
3. Spot-check that key types/enums from the codebase appear in the docs
4. Confirm INDEX.md links are correct

## Principles

- **Progressive disclosure over comprehensive loading** — don't make agents read everything upfront
- **Accuracy over coverage** — a smaller set of correct docs beats a large set of vague ones
- **Source of truth is the code** — always read source before writing; never guess
- **One topic per file** — makes it easy to load just what's needed
- **"When to read" is the key feature** — without it, INDEX.md is just a table of contents
