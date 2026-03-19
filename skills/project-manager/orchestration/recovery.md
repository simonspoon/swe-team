# Recovery: Resuming Interrupted Projects

How to re-enter a project mid-execution.

## Re-entry Checklist

```mermaid
flowchart TD
    A[Resuming project] --> B[limbo tree]
    B --> C{In-progress tasks?}
    C -->|Yes| D[Check each: still being worked?]
    C -->|No| E[Find next unblocked tasks]
    D -->|Abandoned| F[Reset to todo]
    D -->|Still active| G[Wait or check on agent]
    F --> E
    E --> H[Dispatch subagents]
```

## Step 1: Assess Current State

```bash
limbo tree              # Visual overview
limbo list              # Full task data (JSON)
```

## Step 2: Handle In-Progress Tasks

For each task with status `in-progress`:

```bash
limbo show <id>
```

**If owner is active agent**: Wait for completion or check agent status.

**If owner is stale/unknown**: Reset the task:
```bash
limbo note <id> "Reset: previous agent abandoned"
limbo unclaim <id>              # ← use `unclaim`, NOT `claim` with empty string
limbo status <id> todo
```

**If work was partially done**: Assess and decide:
- Complete manually and mark done
- Reset and re-dispatch from scratch
- Create sub-task for remaining work

## Step 3: Find Available Work

```bash
limbo list --status todo --unblocked
```

Returns tasks that:
- Status is `todo`
- Not blocked by any incomplete task

## Step 4: Resume Dispatch

Dispatch available tasks per [parallel.md](parallel.md).

## State Summary Commands

| What | Command |
|------|---------|
| All active tasks | `limbo list` |
| All tasks (incl. done) | `limbo list --show-all` |
| Visual tree | `limbo tree` |
| Full tree (incl. done) | `limbo tree --show-all` |
| Todo only | `limbo list --status todo` |
| In-progress | `limbo list --status in-progress` |
| Completed | `limbo list --status done --show-all` |
| Next available | `limbo next` |

## Common Re-entry Scenarios

### Scenario: Session crashed mid-project

1. Run `limbo tree` to see state
2. Check each `in-progress` task - likely abandoned
3. Reset abandoned tasks to `todo`
4. Continue dispatching

### Scenario: Returning next day

1. Run `limbo list --status done --show-all` to review completed work
2. Run `limbo tree` to see remaining work
3. Identify any blocked tasks that are now unblocked
4. Dispatch next wave

### Scenario: Another agent was working

Check ownership before resetting:
```bash
limbo show <id>  # Check owner field
```

If owner is current session, safe to reset. If different session, coordinate or wait.

Back to [INDEX.md](INDEX.md) | [SKILL.md](../SKILL.md)
