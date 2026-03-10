# clipm Command Reference

Quick reference for all clipm commands. Most commands output JSON by default. Use `--pretty` for human-readable output. Exception: `add` outputs just the task ID.

**IDs are 4-character strings** (e.g., `unke`, `ozit`), not integers.

## Initialization

```bash
clipm init              # Create .clipm/ in current directory
```

## Task Creation

All three structured fields are **required** by the CLI:

```bash
clipm add "Task name" \
  --action "What concrete work to perform" \
  --verify "How to confirm the action succeeded" \
  --result "Template for what to report back"              # → outputs task ID

clipm add "Task name" --parent <id> \
  --action "..." --verify "..." --result "..."             # Create child task

clipm add "Task name" -d "Detailed description" \
  --action "..." --verify "..." --result "..."             # With description
```

## Task Status

```bash
clipm status <id> todo         # Set to todo
clipm status <id> in-progress  # Set to in-progress
clipm status <id> done --outcome "What was done and verified"  # Set to done (--outcome required)
```

## Task Ownership

```bash
clipm claim <id> <agent-name>    # Assign owner
clipm claim <id> <agent-name> --force  # Force claim (even if already owned)
clipm unclaim <id>                # Remove owner
```

## Dependencies

```bash
clipm block <blocker-id> <blocked-id>    # blocked waits for blocker
clipm unblock <blocker-id> <blocked-id>  # Remove dependency
```

**Argument order**: First arg is the blocker (must finish first), second arg is the blocked task (must wait).

Example: `clipm block A B` means B is blocked by A. A must finish before B can start.

## Hierarchy

```bash
clipm parent <id> <parent-id>    # Set task's parent
clipm unparent <id>              # Remove parent relationship
```

## Notes

```bash
clipm note <id> "Note text"    # Add observation or progress update
```

## Viewing Tasks

**Default behavior:** `list`, `tree`, and `watch` hide completed tasks by default. A done task is only shown if its parent exists and is not done. Use `--show-all` to see everything.

```bash
clipm list                          # All tasks (JSON array, hides completed)
clipm list --show-all               # Include completed tasks
clipm list --status todo            # Filter by status (todo|in-progress|done)
clipm list --unblocked              # Only unblocked tasks
clipm list --blocked                # Only blocked tasks
clipm list --unclaimed              # Only tasks with no owner
clipm list --owner <agent-name>     # Tasks owned by specific agent
clipm list --status todo --unblocked  # Combine filters

clipm show <id>                     # Task details (JSON)
clipm tree                          # Hierarchical view (pretty by default)
clipm tree --show-all               # Include completed tasks in tree
clipm next                          # Next task (depth-first traversal)
clipm next --unclaimed              # Next unowned task
```

## Cleanup

```bash
clipm delete <id>     # Delete task (fails if it has undone children)
clipm prune           # Delete all done tasks with no undone children
```

## Monitoring

```bash
clipm watch                       # Continuously monitor tasks (Ctrl+C to exit)
clipm watch --pretty              # Human-readable tree view (clears & redraws)
clipm watch --show-all --pretty   # Include completed tasks
clipm watch --status in-progress  # Watch specific status
clipm watch --interval 1s         # Custom poll interval (default 500ms)
```

## JSON Output Structure

### Task Object (from `show`, `list`, etc.)

```json
{
  "id": "unke",
  "name": "Task name",
  "action": "What to do",
  "verify": "How to confirm",
  "result": "What to report",
  "outcome": "",
  "status": "todo",
  "parent": null,
  "blockedBy": [],
  "created": "2026-02-10T15:45:56.604661-05:00",
  "updated": "2026-02-10T15:45:56.604661-05:00"
}
```

### Mutating Command Output

Commands that modify a task (`status`, `claim`, `unclaim`, `parent`, `unparent`, `block`, `unblock`, `note`) return only the task ID and the changed field:

```json
{"id": "abcd", "status": "done"}
{"id": "abcd", "owner": "agent-1"}
{"id": "abcd", "owner": null}
{"id": "abcd", "parent": "efgh"}
{"id": "abcd", "parent": null}
{"id": "abcd", "blockedBy": ["efgh"]}
{"id": "abcd", "blockedBy": []}
{"id": "abcd", "noteCount": 2}
```

### `clipm next` Output

```json
{
  "candidates": [
    { "id": "unke", "name": "Task A", ... }
  ]
}
```

## Common Workflows

### Create and Start Task

```bash
clipm add "New task" \
  --action "Do X" --verify "Check Y" --result "Report Z"  # → "abcd"
clipm claim abcd my-agent
clipm status abcd in-progress
```

### Complete Task

```bash
clipm note <id> "Completed: summary of work"
clipm status <id> done --outcome "Did X, confirmed Y, result: Z"
```

### Find Available Work

```bash
clipm next                          # Recommended: depth-first next task
clipm list --status todo --unblocked  # All available tasks
```

Back to [SKILL.md](../SKILL.md)
