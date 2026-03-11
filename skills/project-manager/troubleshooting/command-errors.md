# Command Errors

## clipm not found

**Symptom**: `command not found: clipm`

**Fix**:
1. Check if clipm is installed: `which clipm`
2. If not installed, inform user: "clipm CLI is required. Install it or use alternative task tracking."

## clipm init failed

**Symptom**: Error when running `clipm init`

**Check**:
```bash
ls -la .clipm 2>/dev/null || echo "Not initialized"
```

**If already exists**: Skip init, proceed with existing project.

**If permission error**: Check directory write permissions.

## Invalid task ID

**Symptom**: `Task not found` or `Invalid ID`

**Fix**:
```bash
clipm list | jq '.[].id'  # List all valid IDs
```

Use correct ID from list.

## Block/dependency errors

**Symptom**: `Cannot block: would create cycle`

**Fix**: Review dependency graph with `clipm tree`. Remove conflicting block or restructure tasks.

## Task ID conflicts

**Symptom**: `clipm add` returns an ID that collides with an existing task, or `clipm show <id>` returns the wrong task.

**Fix**: clipm IDs are 4-char strings. If you suspect a collision, run `clipm list` to see all IDs. Use `clipm show <id>` to verify you have the right task before operating on it.

## Stale lock file

**Symptom**: `clipm` commands hang or error with "lock" message.

**Fix**:
1. Check for a lock file: `ls .clipm/*.lock 2>/dev/null`
2. If found, check if the owning process is still running
3. Only remove the lock if no clipm process is active

## Missing required flags

**Symptom**: `clipm add` or `clipm status done` errors about missing fields.

**Fix**: Every `clipm add` requires `--action`, `--verify`, `--result`. Every `clipm status <id> done` requires `--outcome "..."`. These are not optional.

Back to [INDEX.md](INDEX.md) | [SKILL.md](../SKILL.md)
