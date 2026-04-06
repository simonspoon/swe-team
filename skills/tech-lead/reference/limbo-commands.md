# limbo Command Reference

Quick reference for all limbo commands. Most commands output JSON by default. Use `--pretty` for human-readable output. Exception: `add` outputs just the task ID.

**IDs are 4-character strings** (e.g., `unke`, `ozit`), not integers.

## Initialization

```bash
limbo init              # Create .limbo/ in current directory
```

## Task Creation

Structured fields (`--approach`, `--verify`, `--result`) are optional but recommended:

```bash
limbo add "Task name" \
  --approach "What concrete work to perform" \
  --verify "How to confirm the approach succeeded" \
  --result "Template for what to report back"              # -> outputs task ID

limbo add "Task name" --parent <id> \
  --approach "..." --verify "..." --result "..."             # Create child task

limbo add "Task name" -d "Detailed description" \
  --approach "..." --verify "..." --result "..."             # With description
```

## Task Status

limbo is a pure task store -- no gate validation. Status changes are unconditional.
Valid statuses: `captured`, `refined`, `planned`, `ready`, `in-progress`, `in-review`, `done`.

```bash
limbo status <id> captured        # Any status, no field requirements
limbo status <id> in-progress     # No claim or field checks
limbo status <id> done            # No --outcome required by limbo
limbo status <id> done --outcome "What was done"  # --outcome optional, recommended
limbo status <id> captured --reason "requirements changed"  # --reason optional, for audit trail
```

Workflow rules (field requirements, gate validation) are enforced by the PM agent, not by limbo.

## Task Ownership

```bash
limbo claim <id> <agent-name>    # Assign owner
limbo claim <id> <agent-name> --force  # Force claim (even if already owned)
limbo unclaim <id>                # Remove owner
```

## Dependencies

```bash
limbo block <blocker-id> <blocked-id>    # blocked waits for blocker
limbo unblock <blocker-id> <blocked-id>  # Remove dependency
```

**Argument order**: First arg is the blocker (must finish first), second arg is the blocked task (must wait).

Example: `limbo block A B` means B is blocked by A. A must finish before B can start.

## Hierarchy

```bash
limbo parent <id> <parent-id>    # Set task's parent
limbo unparent <id>              # Remove parent relationship
```

## Notes

```bash
limbo note <id> "Note text"    # Add observation or progress update
```

## Viewing Tasks

**Default behavior:** `list`, `tree`, and `watch` hide completed tasks by default. A done task is only shown if its parent exists and is not done. Use `--show-all` to see everything.

```bash
limbo list                          # All tasks (JSON array, hides completed)
limbo list --show-all               # Include completed tasks
limbo list --status captured        # Filter by status
limbo list --unblocked              # Only unblocked tasks
limbo list --blocked                # Only blocked tasks
limbo list --unclaimed              # Only tasks with no owner
limbo list --owner <agent-name>     # Tasks owned by specific agent
limbo list --status ready --unblocked  # Combine filters

limbo show <id>                     # Task details (JSON)
limbo tree                          # Hierarchical view (pretty by default)
limbo tree --show-all               # Include completed tasks in tree
```

## Cleanup

```bash
limbo delete <id>     # Delete task (fails if it has undone children)
limbo prune           # Delete all done tasks with no undone children
```

## Monitoring

```bash
limbo watch                       # Continuously monitor tasks (Ctrl+C to exit)
limbo watch --pretty              # Human-readable tree view (clears & redraws)
limbo watch --show-all --pretty   # Include completed tasks
limbo watch --status in-progress  # Watch specific status
limbo watch --interval 1s         # Custom poll interval (default 500ms)
```

## JSON Output Structure

### Task Object (from `show`, `list`, etc.)

```json
{
  "id": "unke",
  "name": "Task name",
  "approach": "What to do",
  "verify": "How to confirm",
  "result": "What to report",
  "outcome": "",
  "status": "captured",
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

## Common Workflows

### Create and Start Task

```bash
limbo add "New task" \
  --approach "Do X" --verify "Check Y" --result "Report Z"  # -> "abcd"
limbo claim abcd my-agent
limbo status abcd in-progress
```

### Complete Task

```bash
limbo note <id> "Completed: summary of work"
limbo status <id> done --outcome "Did X, confirmed Y, result: Z"
```

### Find Available Work

```bash
limbo list --status ready --unblocked  # All available unblocked tasks
limbo list --unclaimed                 # Unowned tasks
```

Back to [SKILL.md](../SKILL.md)
