---
description: Drain limbo task queue. Pull next ready+unblocked task, dispatch project-manager to execute it. One task per invocation; exit when scope is drained.
---

Drain limbo via the orchestrator pattern.

# Scope

- `/orchestrate <task-id>` → drain just that subtree (root + descendants).
- `/orchestrate` (no args) → drain all ready/unblocked tasks in the current project's limbo.

# Procedure

1. **Pick the next leaf task**:
   ```bash
   # subtree scope
   limbo tree <task-id> --status ready --unblocked --pretty | head -n 1

   # full drain
   limbo list --status ready --unblocked --pretty | head -n 1
   ```

2. **Dispatch project-manager** via the Agent tool:
   - `subagent_type: swe-team:project-manager`
   - Prompt includes: task ID, working directory, any constraints from CLAUDE.md.
   - The PM advances the task through stages (refined → planned → ready → in-progress → in-review → done).
   - The PM does the work itself; it dispatches only `researcher` (scout) and `committer`.

3. **Wait for PM to return**, then check task status:
   - `done` → continue to next leaf
   - `blocked` → surface the blocker to the user, do not auto-resolve
   - Still in earlier stage → PM didn't complete the loop; surface and stop

4. **Repeat step 1** until scope is drained → exit.

# Rules

- You **do not** code, commit, review, or verify yourself. The PM does that work.
- **One task per dispatch.** Wait for PM to return before picking the next.
- **Drain + exit.** Not a daemon. Not a watcher. If you want recurring drains, schedule via launchd / cron, not via this command.
- **Sequential, not parallel.** Workers running concurrently on the same project corrupt limbo state.

# Stop conditions

- No more ready/unblocked tasks in scope.
- PM returned a blocker that needs user input.
- User interrupted.
- A PM dispatch failed (e.g., context exhausted) — surface and stop, do not retry blindly.

# What this command replaces

This is the slash-command form of the old `orchestrator` agent. The function — task-queue drain + worker dispatch — is automation, not an agent persona. Keeping it as a slash command means it's invocable, scriptable, and visible in your command palette without inventing a runtime role.
