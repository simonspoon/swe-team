# New Project Workflow

For building new systems or major feature sets from scratch.

> **Note:** All `limbo add` calls require `--action`, `--verify`, `--result` flags. All `limbo status <id> done` calls require `--outcome`. Examples below use abbreviated form for readability — fill in the structured fields for each task when creating.

## Task Hierarchy Pattern

```
Project Root
├── Infrastructure
│   ├── Project setup
│   ├── Dependencies
│   └── CI/CD config
├── Core Features
│   ├── Feature A
│   │   ├── Design
│   │   ├── Implement
│   │   └── Test
│   └── Feature B
│       ├── Design
│       ├── Implement
│       └── Test
├── Integration
│   ├── API contracts
│   └── Integration tests
└── Documentation
    ├── README
    └── API docs
```

## External Tool Discovery

Before creating implementation tasks that use external CLI tools:

1. **Check if installed:** `which <tool>` or `<tool> --version`
2. **Get command help:** `<tool> --help` and `<tool> <subcommand> --help`
3. **Test actual output:** Run a real command and inspect output format
4. **Document in task:** Include exact command syntax in task description

Example for CLI tool:
```bash
# Discover axe CLI
axe --help                    # List subcommands
axe describe-ui --help        # Get actual flags
axe describe-ui --udid $UDID | head -50  # See real output format
```

**Do NOT assume API shape from documentation or memory - verify first.**

## Step-by-Step

### 1. Create Root Task

```bash
limbo add "Project: <name>"              # → abcd
```

### 2. Add Infrastructure Tasks

```bash
limbo add "Infrastructure setup" --parent abcd              # → efgh
limbo add "Initialize project structure" --parent efgh       # → ijkl
limbo add "Configure dependencies" --parent efgh             # → mnop
limbo add "Set up CI/CD" --parent efgh                       # → qrst
```

### 3. Add Feature Tasks

For each major feature:

```bash
limbo add "Feature: User Authentication" --parent abcd      # → uvwx

limbo add "Design auth flow" --parent uvwx                   # → yzab
limbo add "Implement auth logic" --parent uvwx               # → cdef
limbo add "Write auth tests" --parent uvwx                   # → ghij

# Set dependencies
limbo block yzab cdef   # Implement blocked by Design
limbo block cdef ghij   # Tests blocked by Implement
```

### 4. Add Integration & Docs

```bash
limbo add "Integration" --parent abcd                        # → klmn
limbo add "Documentation" --parent abcd                      # → opqr
```

### 5. Identify Parallel Work

Initial parallel tasks (no dependencies):
- Project structure setup
- Design tasks for independent features

```bash
limbo list --status todo
```

### 6. Execution Order

Independent tasks (no `blockedBy`) can be executed in any order. The external orchestrator picks up unblocked leaf tasks automatically.

## Example: REST API Project

```bash
limbo add "REST API for User Management"                  # → abcd

# Infrastructure
limbo add "Infrastructure" --parent abcd                   # → efgh
limbo add "Init Node.js project" --parent efgh             # → ijkl
limbo add "Configure TypeScript" --parent efgh             # → mnop
limbo add "Set up Express" --parent efgh                   # → qrst

# Features
limbo add "User CRUD endpoints" --parent abcd              # → uvwx
limbo add "Design user schema" --parent uvwx               # → yzab
limbo add "Implement endpoints" --parent uvwx              # → cdef
limbo add "Write endpoint tests" --parent uvwx             # → ghij

# Dependencies
limbo block ijkl mnop   # TS after Node init
limbo block mnop qrst   # Express after TS
limbo block yzab cdef   # Impl after design
limbo block cdef ghij   # Tests after impl
```

Execution order (based on dependencies):
1. ijkl, yzab (init + design — no blockers)
2. mnop, cdef (unblocked after step 1)
3. qrst, ghij (unblocked after step 2)

Back to [INDEX.md](INDEX.md) | [SKILL.md](../SKILL.md)
