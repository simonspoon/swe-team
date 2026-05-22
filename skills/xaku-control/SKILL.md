---
name: xaku-control
description: Control terminals via the xaku headless terminal multiplexer. Use when you need to spawn interactive terminals, start Claude Code sessions, run REPLs/TUIs, read terminal output, send commands, or manage terminal sessions. For browser automation, use the web-verify skill instead. Triggers on xaku, terminal control, spawn terminal, interactive shell, screen reading, run command in terminal.
---

# xaku Control — Headless Terminal Automation

Control terminal sessions from Claude Code via the xaku headless terminal multiplexer. Use this skill to spin up shells, run commands in other terminals, start Claude Code sessions, interact with REPLs/TUIs, and read results back.

For **browser automation**, use the **web-verify** skill instead.

## Prerequisites

- xaku is installed (`which xaku`)
- Daemon auto-starts on first use — no manual setup needed

## Key Concepts

**Hierarchy:** Workspace > Surface

- **Workspace** = a named group of terminal sessions (like a project context).
- **Surface** = a single terminal session within a workspace.
- **Refs** = short identifiers like `workspace:1`, `surface:3`.

**Output from creation commands:**
- `xaku new-workspace` returns `workspace:N`
- `xaku new-surface` returns `surface:N`
- `xaku new-pane` returns `surface:N` (alias for new-surface)

## Quick Reference

### Orientation

```bash
xaku identify              # Show current workspace/surface context
xaku tree                  # Show all workspaces and surfaces
xaku list-workspaces       # List all workspace refs and names
xaku current-workspace     # Show active workspace
xaku ping                  # Check daemon is running
```

### Terminal Operations

Read reference/terminal-operations.md for full details.

```bash
# Create a new workspace with a shell
xaku new-workspace --cwd /path/to/project
# Returns: workspace:N

# Create a workspace and run a command
xaku new-workspace --cwd /path --command "npm run dev"

# Add another terminal to an existing workspace
xaku new-surface --workspace workspace:N

# Send a command (does NOT press Enter)
xaku send --workspace workspace:N "ls -la"
# Press Enter
xaku send-key --workspace workspace:N Enter

# Read terminal screen
xaku read-screen --workspace workspace:N --lines 30

# Read with scrollback
xaku read-screen --workspace workspace:N --scrollback --lines 100
```

### Cleanup

```bash
xaku close-surface --surface surface:N       # Close one terminal
xaku close-workspace --workspace workspace:N # Close workspace + all terminals
xaku daemon stop                             # Stop the daemon
```

## Common Workflows

Read reference/common-workflows.md for step-by-step patterns including:
- Running commands and reading output
- Starting dev servers (+ browser testing via khora)
- Running Claude Code in a new terminal
- Interactive REPL testing
- Multi-terminal setups
- TUI application testing

## Important Rules

1. **`send` does NOT press Enter.** Always follow with `send-key ... Enter`.
2. **Save refs** from creation commands for later use.
3. **Both `--workspace` and `--surface` work** for send/send-key/read-screen. Use `--workspace` to target the active surface in a workspace.
4. **Clean up** workspaces when done — don't leave orphaned terminals.
5. **Shell init takes time.** After `new-workspace`, wait briefly (sleep 1-2s) before reading output if the shell has heavy init (.zshrc plugins, etc.).
6. **For browser automation**, use the `web-verify` skill — xaku handles terminals only.

## Known Issues

Read reference/known-issues.md for details.
