---
name: session-handoff
description: Update SESSION_STATE.md at the end of a session to preserve strategic context, decisions, and priorities for the next session. Use when ending a session, wrapping up work, signing off, or when the user says goodbye/done/that's all.
---

# Session Handoff

Update the session state file so the next session inherits full strategic context.

## When to Invoke

- User signals end of session ("that's all", "let's stop here", "goodbye", etc.)
- Significant milestone completed and context should be saved
- Before a long break in conversation
- User explicitly asks to save state

## Activation Protocol

1. Read the current `SESSION_STATE.md` from the project memory directory.
2. Reflect on what happened this session.
3. Update each section based on what changed.
4. Write the updated file.
5. Confirm to the user what was preserved.

## What to Update

### Always update:
- **Last updated** date
- **Active Projects** — status changes, new projects, completed work
- **Current Priorities** — what's next, reordered by importance
- **Open Questions** — new questions raised, resolved questions removed

### Update if changed:
- **Key Decisions & Why** — new decisions made this session (include the WHY)
- **Team roster** — new skills/agents added or modified
- **Working Style** — new preferences or corrections observed
- **Last evaluation** — if team-evaluator was run

### Add if new:
- **Previous session** — brief summary of what this session accomplished

## SESSION_STATE.md Structure

```markdown
# Session State

Last updated: [YYYY-MM-DD]
Previous session: [1-2 sentence summary of last session]

## Who You Are
[Role definition — stable, rarely changes]

## Active Projects
[Per-project: status, location, recent changes, next steps]

## Key Decisions & Why
[Numbered list of decisions with reasoning — append only, don't delete old ones unless obsolete]

## Current Priorities
[Ordered list — reorder based on what matters now]

## Working Style
[User preferences for communication and collaboration]

## Open Questions
[Things to think about or discuss next session]
```

## Rules

1. **Preserve decisions.** Don't remove old decisions unless they've been explicitly superseded. They're historical context.
2. **Be specific.** "Worked on limbo" is useless. "Added template system to limbo — 3 built-in templates, YAML format, +1358 lines" is useful.
3. **Capture the WHY.** For every decision, record why it was made. The next session needs reasoning, not just conclusions.
4. **Keep it under 200 lines.** If it's getting long, consolidate older project sections. Move completed projects to a "Completed" section at the bottom.
5. **Don't duplicate memory.** SESSION_STATE.md captures strategic context and priorities. User preferences, feedback, and project facts go in memory files. Don't put the same info in both places.
6. **Update, don't append.** Each section should reflect the CURRENT state, not a log. The "Previous session" field is the only chronological element.

## Finding the File

The SESSION_STATE.md lives in the project memory directory. Find it via:
```bash
find ~/.claude/projects/ -name "SESSION_STATE.md" -type f 2>/dev/null
```

If no SESSION_STATE.md exists, create one using the structure above.

## Example Update

Before (from last session):
```
## Current Priorities
1. Build SWE agent team
2. Train all skills
```

After (this session accomplished #1 and #2):
```
## Current Priorities
1. Use the team on real work — battle-test on actual projects
2. Build simplify/refactor skill — lowest team eval score
3. Consider code-index tool for faster exploration
```
