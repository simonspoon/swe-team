---
name: session-init
description: Load and summarize suda context at session start via a Sonnet agent, keeping the main context window lean. Replaces raw suda dumps with a condensed briefing.
---

# Session Init

Load suda context through a Sonnet agent that deduplicates, filters, and summarizes — returning a compact briefing instead of dumping raw JSON into the main context.

## When to Invoke

- Start of every session (triggered by CLAUDE.md bootstrap)
- User says "reload context" or "refresh suda"

## Protocol

Spawn a **Sonnet agent** with the following prompt. Do NOT load suda data directly — the whole point is to keep raw data out of the main context.

### Agent Prompt

Use the Agent tool with `model: "sonnet"` and this prompt:

```
You are a session initialization agent. Load all suda context, process it, and return a condensed briefing.

## Step 1: Load Everything

Run these commands and capture all output:

1. suda state get session-state 2>/dev/null
2. suda recall --type user --json --limit 20 2>/dev/null
3. suda recall --type feedback --json --limit 30 2>/dev/null
4. suda projects --json 2>/dev/null
5. Detect the current working directory (pwd) and match it against the project registry. If it matches a registered project, also run:
   suda recall --project <project-name> --json 2>/dev/null

## Step 2: Process

### Deduplicate
- Identify feedback entries that cover the same rule (e.g., same topic, different IDs).
- For duplicates, keep the higher-ID entry (newer) and report the stale IDs for cleanup.

### Categorize feedback by urgency
- **Hard rules**: Things that must ALWAYS or NEVER be done (e.g., "no co-authored-by in commits", "always use git-commit skill"). List these verbatim — do not paraphrase.
- **Preferences**: Softer guidance about approach or style. Summarize these concisely.
- **Project-specific**: Feedback tied to a specific technology or project. Only include if relevant to the current working directory.

### Filter by relevance
- If in a registered project directory, prioritize project-specific memories.
- Omit feedback that only applies to technologies/projects not in the current context (e.g., skip Tauri-specific feedback when working on a Go project).

## Step 3: Return Briefing

Return a structured briefing in this exact format:

---
## Session Briefing

### Session State
<2-3 sentence summary of where the last session left off. If no session state, say "No prior session state.">

### Hard Rules (always apply)
- <rule 1 — verbatim>
- <rule 2 — verbatim>
- ...

### Preferences
- <summarized preference 1>
- <summarized preference 2>
- ...

### User Profile
<1-2 sentence summary of who the user is and how to work with them>

### Active Projects
<table of registered projects with name, path, description>

### Project Context (if in a registered project)
<relevant project-specific memories>

### Housekeeping
- Duplicate entries to clean up: <list IDs>
- Stale entries (>3 months old): <list IDs>
- Total memories loaded: <count>
- Briefing size vs raw size: <compressed/original>
---

Keep the entire briefing under 4000 characters. Prioritize hard rules and session state — trim preferences and project context if needed to stay within budget.
```

## After Agent Returns

1. Read the briefing and use it as session context.
2. If the housekeeping section lists duplicates or stale entries, note them but do NOT auto-delete — mention them to the user only if relevant or if they ask about suda health.

## Rules

1. **Never load raw suda JSON into the main context.** That's the whole point of this skill.
2. **Hard rules must be preserved verbatim.** Summarization is for preferences, not mandates.
3. **Model is Sonnet.** This is summarization work, not complex reasoning.
4. **Keep briefing under 4K chars.** If larger, the agent should trim preferences first.
5. **Current-directory awareness.** The agent must check pwd and filter accordingly.
