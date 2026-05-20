---
name: global-backlog
description: DEPRECATED — limbo no longer supports a global backlog. The `-g` / `--global` flags have been removed from the limbo CLI. Do not invoke this skill; if the user asks about a "global backlog", tell them the feature was removed and ask where they want cross-project tasks tracked instead.
---

# global-backlog — DEPRECATED

**This skill is non-functional.** As of the current limbo CLI, there is no `-g` or `--global` flag on any subcommand. Running `limbo -g …` or `limbo --global …` will fail with:

```
Error: unknown shorthand flag: 'g' in -g
```

There is no global `~/.limbo/` store managed by the limbo binary anymore — only project-local `.limbo/` directories work.

## What to do instead

If the user asks about a "global backlog" or "cross-project tasks":

1. Tell them the global-backlog feature was removed from limbo.
2. Ask where they want cross-project work tracked now (e.g., a dedicated project-local limbo in some shared repo, a notes file, or another tool).
3. Do **not** attempt to call `limbo -g …` — every command will error.

If the user wants to manage tasks for the *current* project, use plain `limbo` commands (no `-g`) against the local `.limbo/` directory.
