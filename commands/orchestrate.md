---
description: Drain limbo task queue. Pull next unblocked leaf task, dispatch project-manager to execute it. One task per invocation; exit when scope is drained.
---

Drain limbo via the orchestrator pattern.

# Scope

- `/orchestrate <task-id>` → drain just that subtree (root + descendants).
- `/orchestrate` (no args) → drain all unblocked leaf tasks in the current project's limbo.

# Procedure

1. **Pick the next leaf task** — any stage, not just `ready`:

   **Full drain** (`/orchestrate`, no args):
   ```bash
   limbo list --unblocked --pretty
   ```
   **Subtree scope** (`/orchestrate <task-id>`):
   ```bash
   limbo tree <task-id> --unblocked --pretty
   ```

   Read the output and pick the **first unblocked leaf task**, then take its
   short ID — the first token of that task's line (e.g. `rgta`).

   ⚠️ Do NOT pipe these commands through `head -n 1`. The `--pretty` format
   never puts a task on line 1:
   - `limbo list --pretty` groups tasks under `status (N)` header lines, so
     line 1 is a status header (e.g. `captured (1)`) — not a task, no ID.
   - `limbo tree --pretty` puts the subtree *root* on line 1 — you want a
     leaf descendant, not the root.

   If the output is `No tasks found.`, the scope is drained → stop (see
   Stop conditions).

   Pick the next unblocked leaf **regardless of its status** (`captured`,
   `refined`, `planned`, or `ready`). `done` tasks are excluded by default.
   Do NOT filter to `--status ready` — a freshly captured-only queue must still
   drain. The PM advances whatever it receives from its current stage.

2. **Dispatch project-manager** via the Agent tool:
   - `subagent_type: swe-team:project-manager`
   - Prompt includes: task ID, working directory, any constraints from CLAUDE.md.
   - The PM advances the task from its current stage through to done
     (captured → refined → planned → ready → in-progress → in-review → done).
   - The PM orchestrates each stage via specialist subagents (researcher,
     test-engineer, risk-assessor, red-team, tech-lead, code-reviewer, verifier,
     committer) — it synthesizes their output but never implements code itself.

3. **Wait for PM to return**, then check task status:
   - `done` → continue to next leaf
   - `blocked` → surface the blocker to the user, do not auto-resolve
   - PM decomposed the task into subtrees → continue to step 1 (the new leaves are now pickable)
   - PM needs clarification (a `captured` task too vague to execute) → surface to the user and stop
   - Still in earlier stage with no explanation → PM didn't complete the loop; surface and stop

4. **Repeat step 1** until scope is drained → exit.

# Rules

- You **do not** code, commit, review, or verify yourself. The PM does that work.
- **One task per dispatch.** Wait for PM to return before picking the next.
- **Drain + exit.** Not a daemon. Not a watcher. If you want recurring drains, schedule via launchd / cron, not via this command.
- **Sequential, not parallel.** Workers running concurrently on the same project corrupt limbo state.

# Stop conditions

- No more unblocked leaf tasks in scope (all remaining are `done` or `blocked`).
- PM returned a blocker that needs user input.
- User interrupted.
- A PM dispatch failed (e.g., context exhausted) — surface and stop, do not retry blindly.

# What this command replaces

This is the slash-command form of the old `orchestrator` agent. The function — task-queue drain + worker dispatch — is automation, not an agent persona. Keeping it as a slash command means it's invocable, scriptable, and visible in your command palette without inventing a runtime role.
