---
name: session-wrap
description: End-of-session skill that commits dirty repos, opportunistically captures memorable learnings into simaris, and optionally improves skills.
---

# Session Wrap

End-of-session cleanup. Commits outstanding work, captures anything worth remembering into simaris, and optionally improves skills if requested. Session *events* are logged by the ivara-capture hook (`hooks/hooks.json`), but ivara is session telemetry — it does NOT write knowledge units to simaris. Capture into simaris is explicit.

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

## Phase 2: Opportunistic Memory Capture

Scan the session for anything worth keeping. Capture only the non-obvious:

- **User correction or confirmed non-obvious choice** → `simaris add --type preference --tags <project>,<topic> "<one-line rule>"`
- **Reusable rule / how-to with a clear trigger** → `simaris add --type procedure --trigger "<when it fires>" --check "<verification>" "<body>"`
- **Surprising fact about the system** → `simaris add --type fact --tags <topic> --evidence "<source>" "<claim>"`
- **Hard-won insight worth a name** → `simaris add --type lesson --context "<situation>" "<body>"`

Skip if nothing surprising came up. Don't capture restatements of CLAUDE.md, code that's already in the repo, or session-local task state.

Before adding, search for duplicates: `simaris search "<keywords>" --type <type> --json`. If a similar unit exists, prefer `simaris edit <id>` or skip.

## Phase 3: Skill Improvements (only if requested)

Only run this phase if the user explicitly asks for skill improvements. For each issue:

1. Read the skill's SKILL.md
2. Categorize: structure, clarity, guardrails, templates, or critical requirements
3. Apply the fix directly — keep SKILL.md focused (~100 lines)
4. Validate links and frontmatter

Skip this phase entirely if no skill issues were found. Don't force it.

## Phase 4: Confirm

Tell the user:
- Repos committed/pushed (if any)
- Memories captured (list slugs/headlines, if any)
- Skill improvements applied (if any)

Keep it brief.

## Rules

1. **Capture only the non-obvious.** Restating CLAUDE.md or code already in the repo is noise. If a senior engineer reading the unit would think "I already knew that," don't store it.
2. **Search before adding.** Run `simaris search` first to avoid duplicates.
3. **Skill improvements are opt-in.** Only run Phase 3 if the user explicitly requests it.
