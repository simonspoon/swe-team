---
name: session-wrap
description: End-of-session skill that reflects on the full session (decisions, approaches, skill usage), captures learnings into suda, and persists session state for the next conversation. Replaces running session-handoff and skill-reflection separately.
---

# Session Wrap

Single end-of-session skill. Reflects broadly on what happened, captures durable learnings, and hands off context for next session.

## When to Invoke

- User signals end of session ("that's all", "wrap up", "goodbye", etc.)
- User explicitly asks to wrap or reflect
- Significant milestone and session is winding down

## Phase 1: Uncommitted Changes

Check every repo touched this session for dirty state.

```bash
for repo in <repos-touched>; do
  echo "=== $repo ==="
  git -C "$repo" status --porcelain
done
```

For each dirty repo: commit and push using `/swe-team:git-commit`.

## Phase 2: Session Reflection

Review the full conversation and answer these questions. Write your answers out visibly.

### Decisions & Reasoning
- What non-obvious decisions were made? Why?
- Did any decision change mid-session? What caused the pivot?
- Were there trade-offs? What was chosen and what was sacrificed?

### Approaches & Outcomes
- What approaches worked well? Anything surprisingly effective?
- What failed or had to be retried? What was the root cause?
- Did anything take longer than expected? Why?

### Process & Feedback
- Did the user correct you? What was the correction?
- Did the user confirm a non-obvious approach? (Quiet signals: "yes exactly", "perfect", accepting without pushback)
- Were there process improvements discovered?

### Skill Usage (only if skills were invoked)
- Which skills were used? Did any underperform?
- Were there moments where a skill's instructions were unclear or incomplete?
- Did you have to work around a skill limitation?

**For each reflection item:** decide if it's worth persisting. Not everything is — routine decisions and expected outcomes don't need memories. Focus on the surprising, the corrective, and the reusable.

## Phase 3: Persist Learnings

For each item worth keeping, store it via suda. Check for duplicates first.

```bash
# Check before creating
suda recall --json "<keywords>" 2>/dev/null

# Store new learnings by type
suda store --type feedback --name "<name>" --description "<desc>" "<content with Why and How to apply>"
suda store --type project --name "<name>" --project "<project>" --description "<desc>" "<content>"
suda store --type user --name "<name>" --description "<desc>" "<content>"

# Update existing memories if they need revision
suda update <ID> --content "<updated content>"
```

**Rules for what to store:**
- User corrections → feedback memory (always)
- User confirmations of non-obvious approaches → feedback memory
- Project decisions with reasoning → project memory
- New info about user preferences/role → user memory
- Skill improvements needed → note in reflection output (don't store, act on it in Phase 4)

**Do NOT store:** routine decisions, things derivable from code/git, ephemeral task state, things already in suda.

## Phase 4: Skill Improvements (conditional)

Only run this phase if Phase 2 identified skill issues. For each issue:

1. Read the skill's SKILL.md
2. Categorize: structure, clarity, guardrails, templates, or critical requirements
3. Apply the fix directly — keep SKILL.md focused (~100 lines)
4. Validate links and frontmatter

Skip this phase entirely if no skill issues were found. Don't force it.

## Phase 5: Session Handoff

Read existing session state, merge new context, and persist.

```bash
# Read current state
suda state get session-state 2>/dev/null

# Update with merged context
suda state set session-state --stdin <<'EOF'
<merged session state — keep last 3 sessions in Recent, update Active Projects, update Priorities>
EOF
```

Session state must include:
- **What was accomplished** (specific, not vague)
- **Projects touched** and their current state (branch, commit status, version)
- **Key decisions** with reasoning
- **Current priorities** (updated if changed)
- **Open questions** (new or carried forward)

**Merge, don't replace.** Read existing state first. Carry forward active project info and priorities that haven't changed.

## Phase 6: Confirm

Tell the user:
- Key learnings captured (count and brief summary)
- Skill improvements applied (if any)
- Session state persisted
- Any repos that were committed/pushed

Keep it brief.

## Rules

1. **Be selective.** Not every session produces durable learnings. That's fine.
2. **Be specific.** "Improved workflow" is useless. "Backgrounding the subshell in Stop hooks prevents blocking the prompt" is useful.
3. **Merge, don't replace** session state.
4. **Don't duplicate** existing suda memories — check first.
5. **Reflection is visible.** Write your Phase 2 answers out so the user can see and correct them.
