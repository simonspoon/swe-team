---
name: suda
description: Manage structured memories, project registry, and session state using the suda CLI. Use for storing user preferences, feedback, project context, and reference material. Triggers on remember this, store memory, recall, what do you know about me, session state, project registry, memory management.
---

# suda — Structured Memory Management

Store and recall structured memories in a SQLite database via the `suda` CLI. Memories are typed (user, feedback, project, reference) and searchable via FTS5.

## Prerequisites

- `suda` must be installed and on PATH
- Database lives at `~/.suda/suda.db` (override with `SUDA_HOME` env var)

## Setup

For suda to load automatically at session start, `~/.claude/CLAUDE.md` must contain the bootstrap instructions. Add this once:

```markdown
## Suda — Structured Memory System

At the start of every session, load context from suda before doing other work:

1. Check if suda is available: `which suda`
2. If available, load relevant memories and state:
   suda state get session-state 2>/dev/null
   suda recall --type user --json --limit 20 2>/dev/null
   suda recall --type feedback --json --limit 20 2>/dev/null
   suda projects --json 2>/dev/null
3. If the CWD matches a registered project, also load project-specific memories:
   suda recall --project <project-name> --json 2>/dev/null
```

Without this bootstrap, suda works but must be invoked manually.

## When to Use

### On session start
Load relevant context before doing anything else:
```bash
suda recall --project <current-project> --json
suda state get session-context --json
```

### During conversation — store memories when you learn:
- **User info** (role, preferences, expertise, working style): type `user`
- **Feedback** (corrections, confirmations, approach preferences): type `feedback`
- **Project context** (goals, deadlines, decisions, architecture): type `project`
- **External resources** (URLs, tool locations, docs, API refs): type `reference`

### On session end
Persist session context for the next session:
```bash
suda state set session-context "summary of what happened, decisions made, next steps"
```

## Commands

### Store a memory
```bash
suda store --type feedback --name "prefers-small-commits" "User wants atomic commits, one concern per commit"
suda store --type project --name "api-redesign-deadline" --project myapp --description "Hard deadline" "API v2 must ship by March 30"
echo "long content" | suda store --type reference --name "deploy-runbook" --stdin
```

### Recall memories
```bash
suda recall "commit preferences"              # FTS5 search
suda recall --project myapp --json             # all memories for a project
suda recall --type user --limit 5 --json       # recent user memories
suda recall                                    # list recent (no query)
```

### Update a memory
```bash
suda update 42 --content "Updated preference: user now prefers conventional commits"
suda update 42 --name "new-name" --description "new desc"
```

### Forget a memory
```bash
suda forget 42
```

### Project registry
```bash
suda projects                                  # list all projects
suda project add myapp /path/to/myapp --description "Main web app"
suda project show myapp
suda project remove myapp
```

### Session state (key-value)
```bash
suda state set current-task "implementing auth flow"
suda state get current-task --json
suda state list
suda state delete current-task
```

### Export / Import
```bash
suda export --project myapp --format json      # export as JSON
suda export --type feedback --format md         # export as Markdown
suda import memories.json                      # import from JSON
```

## Key Rules

1. **Deduplicate before storing.** Always check first: `suda recall --json <keywords>`. If a similar memory exists, use `suda update <ID>` instead of creating a duplicate.
2. **Use `--json` for programmatic reads.** Parse JSON output when you need to act on results. Use human-readable output when displaying to the user.
3. **Be selective about what to store.** Store durable knowledge — preferences, decisions, context that future sessions need. Do not store transient or obvious information.
4. **Scope to projects.** Use `--project` when storing and recalling project-specific memories to keep context clean.
5. **Keep memory names descriptive and kebab-case.** Names like `prefers-rust-over-python` or `api-v2-architecture-decision` are searchable and self-documenting.
