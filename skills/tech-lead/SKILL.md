---
name: tech-lead
description: Single-task code executor — implements one task, verifies, returns (no commits).
triggers:
  - (dispatched by project-manager only)
---

# Tech Lead Skill

Reference material for the tech-lead agent when executing a single task dispatched by the project-manager.

## Prerequisite Check

Before doing anything else, verify the project builds:

```bash
# Detect project type and run build
[ -f "Cargo.toml" ] && cargo check 2>&1 | tail -3
[ -f "package.json" ] && pnpm build 2>&1 | tail -3
[ -f "go.mod" ] && go build ./... 2>&1 | tail -3
```

If the project doesn't build before you start, note it — that's pre-existing, not your fault.

## Implementation by Task Type

Understand the kind of task you're executing. This affects your approach.

**Feature** — adding new functionality:
- Read existing patterns in surrounding code before writing
- Match naming, error handling, and logging conventions
- Add tests if the task's `--verify` field requires them

**Bug fix** — fixing broken behavior:
- Verify the bug exists first (reproduce it)
- Identify root cause before applying a fix
- Write a regression test that fails without the fix, passes with it

**Change request** — modifying existing behavior:
- Understand the current behavior completely before changing it
- Make the minimal change to achieve the goal
- When rewriting a function, enumerate what the old code did (timing, logging, error format, return shape) and preserve those behaviors unless the task explicitly says to change them

**New project** — building a new system:
- Follow the project scaffold conventions from `/swe-team:software-engineering`
- Get the skeleton building and running before adding features

See [workflows/INDEX.md](workflows/INDEX.md) for detailed task templates.

## Verification

Every task must be verified before returning results to the PM. Use the deepest verification level possible.

### Verification Depth Ladder

| Level | Name | What it catches | When sufficient |
|-------|------|----------------|-----------------|
| 1 | Import check | Syntax errors only | Never — too shallow |
| 2 | Compile/build | Type errors, missing deps | Only for trivial config changes |
| 3 | Static analysis | Types match, signatures correct | Non-runnable code (TUI, GUI) |
| 4 | Runtime test | Logic bugs, runtime crashes | Most code tasks |
| 5 | Full integration | End-to-end with real deps | Critical paths, APIs |

**Minimum: Level 3. Prefer Level 4+.**

### Verification Checklist

1. **Format**: Run the project formatter (`cargo fmt`, `prettier --write .`, `black .`)
2. **Build**: Full project build — not just the file you changed
3. **Test**: Run relevant tests. If the task specifies tests, run those. If you wrote new tests, run them.
4. **Smoke test**: Actually execute the code path with sample input. "It compiles" is never sufficient.

### By language

```bash
# Rust
cargo fmt && cargo build && cargo test && cargo run -- --help

# TypeScript/JS
pnpm format && pnpm build && pnpm test

# Go
gofmt -w . && go build ./... && go test ./...

# Python
black . && uv run pytest
```

### Common runtime failures to check for

- **Missing framework init**: CoreGraphics/AppKit APIs crash without `NSApplication.shared`
- **Pipe deadlocks**: `Process.waitUntilExit()` before reading stdout/stderr (Swift)
- **Data contract mismatches**: Producer sends different fields than consumer expects — both compile, deserialization fails at runtime
- **Permission errors**: Screen capture, network, file access — only surface at runtime
- **Platform-specific paths**: `/bin/sh`, `/tmp`, Unix-only APIs — fail on other platforms

## What You Don't Do

- **No commits.** The PM commits after its own verification.
- **No limbo commands.** No `limbo claim`, `limbo status`, `limbo note`. The PM manages all task state.
- **No scope expansion.** Mention adjacent discoveries in your return, don't act on them.
- **No subagent dispatch for code writing.** You are the code writer. Use Explore agents for research only.

## When Things Go Wrong

| Situation | Action |
|-----------|--------|
| Test failure you can fix | Fix it, re-verify, continue |
| Test failure you can't diagnose | Return to PM with failure details |
| Task contradicts existing code | Return to PM, explain the contradiction |
| Missing dependency or tool | Return to PM, explain what's needed |
| Task is too coarse to execute | Return to PM with findings and suggested decomposition |
| Task is ambiguous | Return to PM with your interpretation and what's unclear |

Do not guess at ambiguous intent. Return to the PM and let it decide.
