# Command Errors

## limbo not found

**Symptom**: `command not found: limbo`

**Fix**:
1. Check if limbo is installed: `which limbo`
2. If not installed, inform user: "limbo CLI is required. Install it or use alternative task tracking."

## limbo init failed

**Symptom**: Error when running `limbo init`

**Check**:
```bash
ls -la .limbo 2>/dev/null || echo "Not initialized"
```

**If already exists**: Skip init, proceed with existing project.

**If permission error**: Check directory write permissions.

## Invalid task ID

**Symptom**: `Task not found` or `Invalid ID`

**Fix**:
```bash
limbo list | jq '.[].id'  # List all valid IDs
```

Use correct ID from list.

## Block/dependency errors

**Symptom**: `Cannot block: would create cycle`

**Fix**: Review dependency graph with `limbo tree`. Remove conflicting block or restructure tasks.

## Task ID conflicts

**Symptom**: `limbo add` returns an ID that collides with an existing task, or `limbo show <id>` returns the wrong task.

**Fix**: limbo IDs are 4-char strings. If you suspect a collision, run `limbo list` to see all IDs. Use `limbo show <id>` to verify you have the right task before operating on it.

## Stale lock file

**Symptom**: `limbo` commands hang or error with "lock" message.

**Fix**:
1. Check for a lock file: `ls .limbo/*.lock 2>/dev/null`
2. If found, check if the owning process is still running
3. Only remove the lock if no limbo process is active

## Structured fields

limbo does not enforce any field requirements. All structured fields (`--approach`, `--verify`, `--result`, `--outcome`) are optional. Use them for clarity and traceability as recommended by the PM workflow.

Back to [SKILL.md](../SKILL.md)
