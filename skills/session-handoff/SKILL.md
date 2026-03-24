---
name: session-handoff
description: Persist session context via suda (preferred) or flat files (fallback). Captures what happened, decisions made, and priorities for next session.
---

# Session Handoff

Preserve session context at end of session. Uses `suda` for structured storage when available, with flat-file fallback.

## When to Invoke

- User signals end of session ("that's all", "let's stop here", "goodbye", etc.)
- Significant milestone completed and context should be saved
- Before a long break in conversation
- User explicitly asks to save state

## Activation Protocol

### Step 0: Check for uncommitted changes

Enumerate every repo touched during this session and check for uncommitted changes.

```bash
for repo in <current-repo> <other-repos-touched-this-session>; do
  echo "=== $repo ==="
  git -C "$repo" status --porcelain
done
```

For each dirty repo, commit and push using `/swe-team:git-commit` before proceeding.

### Step 1: Build the session summary

Compose a summary covering:
- **What was accomplished** (1-2 sentences)
- **Projects touched** and their current state
- **Decisions made** with reasoning (WHY)
- **Priority changes** (if any)
- **New open questions** (if any)

Be specific. "Worked on limbo" is useless. "Added template system to limbo — 3 built-in templates, YAML format" is useful.

### Step 2: Persist via suda (preferred)

Check if suda is available: `which suda`

If available:

```bash
# Update session state with full context
suda state set session-state --stdin <<'EOF'
<session summary from Step 1, plus existing state context>
EOF

# Store any new project-type memories for decisions/context worth preserving
suda store --type project --name "<decision-name>" --project "<project>" \
  --description "<one-line summary>" "<full context with WHY>"

# Update existing project memories if status changed
suda update <ID> --content "<updated status>"
```

When updating session-state, read the existing value first (`suda state get session-state`) and merge — don't replace. Preserve active project info, key decisions, and priorities from prior sessions. Update the "Recent sessions" list (keep last 3).

### Step 3: Persist via flat files (fallback)

Only if suda is NOT available:

1. Find the project memory directory:
   ```bash
   find ~/.claude/projects/ -name "SESSION_STATE.md" -o -name "MEMORY.md" -type f 2>/dev/null
   ```
2. Create `session-log/` subdirectory if needed.
3. Write a timestamped log entry: `session-log/YYYY-MM-DDTHH-MM-SS.md`
4. Re-synthesize `SESSION_STATE.md` from all log entries.

### Step 4: Confirm

Tell the user what was preserved and where.

## Rules

1. **Be specific.** Capture the WHY for every decision.
2. **Merge, don't replace.** Session state is cumulative — new data is additive.
3. **Don't duplicate memory.** Session context goes here. User preferences and feedback are separate memory types.
4. **Keep it under 200 lines.** Consolidate older sections if needed.
5. **Never skip persistence.** Even if one method fails, try the other.
