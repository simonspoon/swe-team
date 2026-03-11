# Orchestration Index

| Pattern | Use When | Link |
|---------|----------|------|
| **Parallel Dispatch** | Multiple independent tasks ready | [parallel.md](parallel.md) |
| **Dependencies** | Tasks must wait for others | [dependencies.md](dependencies.md) |
| **Recovery** | Resuming interrupted project | [recovery.md](recovery.md) |
| **Templates** | Writing subagent prompts, verification depth | [templates.md](templates.md) |

## Key Principles

1. **Maximize parallelism** - All independent tasks in one dispatch
2. **Respect dependencies** - Never start blocked tasks
3. **Clear ownership** - Each task claimed by one agent
4. **Progress visibility** - Use notes and status updates

Back to [SKILL.md](../SKILL.md)
