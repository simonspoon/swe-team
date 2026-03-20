---
name: session-handoff
description: Append a timestamped session log entry and re-synthesize SESSION_STATE.md. Concurrent-safe — each session writes its own log file, so parallel sessions cannot clobber each other.
---

# Session Handoff

Preserve session context using an append-only log. Each session writes its own timestamped entry, then re-synthesizes the consolidated SESSION_STATE.md from all log entries.

## When to Invoke

- User signals end of session ("that's all", "let's stop here", "goodbye", etc.)
- Significant milestone completed and context should be saved
- Before a long break in conversation
- User explicitly asks to save state

## Why Append-Only

Multiple Claude Code sessions can run concurrently against the same project. A read-modify-write pattern on a single SESSION_STATE.md causes last-writer-wins data loss. The log pattern ensures each session's handoff is durable regardless of timing.

## Activation Protocol

### Step 1: Write a log entry

1. Determine the project memory directory (find the directory containing SESSION_STATE.md or MEMORY.md under `~/.claude/projects/`).
2. Create the `session-log/` subdirectory inside it if it doesn't exist.
3. Generate a filename using the current UTC timestamp: `session-log/YYYY-MM-DDTHH-MM-SS.md`
4. Write the log entry using the **Log Entry Format** below.

### Step 2: Re-synthesize SESSION_STATE.md

1. Read the current `SESSION_STATE.md` (if it exists).
2. Read ALL files in `session-log/` sorted by filename (chronological).
3. Synthesize an updated SESSION_STATE.md that incorporates all log entries. Apply the **Synthesis Rules** below.
4. Write the updated SESSION_STATE.md.
5. Confirm to the user what was preserved.

### Step 3: Prune old log entries

If there are more than 20 log entries, delete the oldest entries beyond 20. The data is already consolidated into SESSION_STATE.md.

## Log Entry Format

Each log entry captures the **delta** — what this session changed, not the full state.

```markdown
---
session_end: YYYY-MM-DDTHH:MM:SS
project_dir: /path/to/working/directory
---

## Summary
[1-2 sentence description of what was accomplished]

## Projects Touched
- **project_name**: [status update — what changed, current state]

## Decisions Made
- [Decision with reasoning — include the WHY]

## Priority Changes
- [What shifted and why, if anything]

## New Questions
- [Any new open questions raised]
```

Omit any section that has no content for this session (e.g., if no decisions were made, omit "Decisions Made").

## Synthesis Rules

When building SESSION_STATE.md from log entries:

1. **Preserve the structure.** SESSION_STATE.md keeps its existing section layout (Who You Are, Active Projects, Key Decisions & Why, Current Priorities, Working Style, Open Questions).
2. **Merge, don't replace.** Each log entry's data is additive. A project status update from log entry B doesn't erase project info from log entry A — it updates that project's section.
3. **"Previous session" becomes "Recent sessions."** List the last 3 session summaries (from log entries), most recent first.
4. **Decisions append.** New decisions from log entries get appended to the numbered list. Don't remove old decisions unless explicitly superseded.
5. **Priorities reflect latest.** If multiple log entries reorder priorities, use the most recent entry's ordering as the base.
6. **Questions accumulate.** New questions from log entries are added. Only remove questions that were explicitly answered in a log entry.
7. **Last updated = most recent log entry's timestamp.**
8. **Keep it under 200 lines.** Consolidate older project sections if needed. Move completed projects to a "Completed" section.

## Finding the Memory Directory

```bash
find ~/.claude/projects/ -name "SESSION_STATE.md" -type f 2>/dev/null
```

If no SESSION_STATE.md exists, check for MEMORY.md instead:
```bash
find ~/.claude/projects/ -name "MEMORY.md" -type f 2>/dev/null
```

Create SESSION_STATE.md and session-log/ in whichever directory you find.

## Rules

1. **Log entries are the source of truth.** SESSION_STATE.md is a synthesized cache. If they conflict, the log entries win.
2. **Never skip the log entry.** Even if synthesis fails, the log entry must be written. It's the durable record.
3. **Be specific.** "Worked on limbo" is useless. "Added template system to limbo — 3 built-in templates, YAML format" is useful.
4. **Capture the WHY.** For every decision, record why it was made.
5. **Don't duplicate memory.** Session context goes here. User preferences and feedback go in memory files.
6. **Self-healing.** If SESSION_STATE.md seems stale or incomplete, the next synthesis pass will catch up from the log entries.
