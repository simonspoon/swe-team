---
name: global-backlog
description: View, add, and manage items in the global backlog using limbo --global. Use when the user mentions global backlog, cross-project tasks, backlog items, or wants to add/view/triage tasks that aren't scoped to the current project.
---

# global-backlog — Cross-Project Task Management

Manage a global backlog of tasks across all projects using `limbo -g`. The global backlog lives at `~/.limbo/` and is independent of any project-level limbo instance.

## Prerequisites

- `limbo` must be installed and on PATH
- Global backlog must be initialized: `limbo -g init`

## When to Use

- User asks about the "global backlog" or "cross-project tasks"
- User wants to add a task that isn't specific to the current project
- User wants to review, triage, or prioritize work across projects
- User says "add to backlog", "what's on the backlog", "show me the backlog"

## Quick Reference

All commands use `limbo -g` (or `limbo --global`) to target `~/.limbo/`:

```bash
# View the backlog
limbo -g tree --pretty              # Hierarchical view
limbo -g list --pretty              # Flat list
limbo -g list -s todo --pretty      # Only todos
limbo -g next                       # Next task to work on

# Add items (--action, --verify, --result are REQUIRED)
limbo -g add "Task name" --action "What to do" --verify "How to confirm" --result "Expected outcome"
limbo -g add "Subtask" --parent <id> --action "..." --verify "..." --result "..."
# add returns the new task's short ID (e.g., "jpbc")

# Manage items
limbo -g status <id> in-progress    # Start working
limbo -g status <id> done --outcome "What actually happened"  # Mark complete (--outcome required for structured tasks)
limbo -g edit <id> --name "New name"
limbo -g note <id> "Some context"
limbo -g block <blocker-id> <blocked-id>
limbo -g delete <id>

# Search
limbo -g search "keyword"
```

## Workflow

1. **When the user asks to see the backlog**: Run `limbo -g tree --pretty` to show the current state. If empty, say so.
2. **When the user wants to add something**: Use `limbo -g add` with structured fields (action, verify, result). If the task belongs under an existing item, use `--parent`.
3. **When triaging**: Show the tree, then ask the user which items to prioritize, break down, or remove.
4. **When starting work**: Use `limbo -g status <id> in-progress` to claim it, then proceed with the actual work. Mark done when finished.

## Rules

- Always use `-g` flag — never accidentally write to a project-local limbo
- Use `--pretty` for human-readable output when displaying to the user
- Use JSON output (no `--pretty`) when parsing programmatically (`list` and `next` support this; `tree` always outputs pretty format)
- Keep task names concise but descriptive
- Use parent/child relationships to break large initiatives into actionable items

## Important Behaviors

- **Structured fields are required**: `--action`, `--verify`, and `--result` are mandatory when adding tasks. You cannot add a task without all three.
- **`--outcome` required for done**: When marking a structured task as done, you must provide `--outcome "description"` or the command will fail.
- **Parent completion gating**: A parent task cannot be marked done while it has undone children. Complete all children first.
- **Done tasks are hidden by default**: `list` and `tree` hide completed tasks. Use `--show-all` to include them (e.g., `limbo -g list --show-all --pretty`).
- **Filtering**: `list` supports `--blocked`, `--unblocked`, `--unclaimed`, `--owner`, and `-s <status>` filters.
