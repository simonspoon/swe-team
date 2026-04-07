---
name: status
description: Force-refresh all project state by re-running every command live. NEVER use cached or previously loaded data. Use when checking project status, verifying state, starting a session, or when you suspect stale context.
---

# Status — Fresh State Verification

Verify the current state of everything by fetching live data. This skill exists because cached/stale state is the #1 source of incorrect answers. Every value reported must come from a command run NOW, not from memory or prior context.

## Critical Rule

**NEVER use cached or previously loaded data — re-run every command fresh.** This means:
- Do NOT reuse git status output from earlier in the conversation.
- Do NOT assume you know the current branch, commit, or working tree state.
- Run every command listed below, even if you "just ran it."

## When to Use

- User says "status", "what's the state", "where are we", "catch me up"
- Start of a session when you need to orient
- Before presenting project state to the user
- Whenever you suspect your context might be stale

## Activation Protocol

### Step 1: Detect Context

Determine which mode to run in:

```bash
# What directory are we in?
pwd

# Is this a git repo?
git rev-parse --is-inside-work-tree 2>/dev/null

# Is suda available?
which suda 2>/dev/null

# Is limbo available?
which limbo 2>/dev/null
```

### Step 2: Current Repo State (if in a git repo)

```bash
# Current branch and working tree
git status

# Recent commits
git log --oneline -5

# Any stashed changes
git stash list
```

### Step 3: Suda Project Check (if suda is available)

```bash
# Is this directory a registered project?
suda projects --json 2>/dev/null
```

Match the current working directory against the project registry. If it matches, note the project name.

### Step 4: Limbo Backlog (if limbo is available)

```bash
# Project-local backlog (if .limbo/ exists in current dir)
limbo list --json 2>/dev/null

# Global backlog
limbo -g list --json 2>/dev/null
```

## Output Format

Present results as a structured table:

```
## Project Status (verified <current timestamp>)

| Area | Status | Details |
|------|--------|---------|
| Branch | `main` | clean working tree |
| HEAD | `abc1234` | last commit message here |
| Recent commits | 5 shown | (list below) |
| Stash | empty | — |
| Suda project | `project-name` | registered |
| Limbo backlog | 3 tasks | 1 in-progress, 2 captured |
| Global backlog | 5 tasks | 2 in-progress, 3 captured |
```

Below the table, list the 5 recent commits from Step 2.

## Rules

1. **Every value must be fetched live.** No exceptions.
2. **Do not skip steps.** Even if a tool is unavailable, note it as "not available" rather than silently omitting.
3. **Timestamp the output.** The user should see exactly when the data was fetched.
4. **Report errors.** If a command fails, show the error — do not silently skip it.
