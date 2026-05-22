# Common Workflows

Step-by-step patterns for typical xaku terminal tasks.

## 1. Run a Command and Read Output

```bash
# Create workspace
xaku new-workspace --cwd /path/to/project
# Returns: workspace:N

# Send command
xaku send --workspace workspace:N "cargo test"
xaku send-key --workspace workspace:N Enter

# Wait for output, then read
sleep 5
xaku read-screen --workspace workspace:N --scrollback --lines 50
```

## 2. Start a Dev Server

```bash
# Create workspace with server command
xaku new-workspace --cwd /path/to/project --command "npm run dev" --name "dev-server"
# Returns: workspace:N

# Wait for startup, read output to confirm
sleep 5
xaku read-screen --workspace workspace:N --lines 20
# Look for "http://localhost:3000" or similar

# To test in browser, use the web-verify skill:
# SESSION=$(khora --format json launch | jq -r .id)
# khora navigate "$SESSION" "http://localhost:3000"
# khora screenshot "$SESSION" -o /tmp/app.png
```

## 3. Run Claude Code in a New Terminal

```bash
# Create workspace
xaku new-workspace --cwd /path/to/project
# Returns: workspace:N

# One-shot prompt
xaku send --workspace workspace:N 'claude -p "explain the architecture"'
xaku send-key --workspace workspace:N Enter

# Wait for response
sleep 15
xaku read-screen --workspace workspace:N --scrollback --lines 100
```

## 4. Interactive REPL Testing

```bash
# Start REPL
xaku new-workspace --cwd /path --command "python3"
# Returns: workspace:N

# Wait for REPL prompt
sleep 3

# Send commands
xaku send --workspace workspace:N "import json"
xaku send-key --workspace workspace:N Enter
sleep 1
xaku send --workspace workspace:N "json.dumps({'test': True})"
xaku send-key --workspace workspace:N Enter

# Read output
sleep 1
xaku read-screen --workspace workspace:N --lines 10

# Exit REPL
xaku send-key --workspace workspace:N Ctrl-d
```

## 5. Multi-Terminal Setup (Frontend + Backend + Tests)

```bash
# Create workspace for the project
xaku new-workspace --cwd /path/to/project --name "full-stack"
# Returns: workspace:N (surface:1 is the first terminal)

# Add second terminal for backend
xaku new-surface --workspace workspace:N
# Returns: surface:2

# Add third terminal for tests
xaku new-surface --workspace workspace:N
# Returns: surface:3

# Send commands to each terminal by surface ref
xaku send --surface surface:1 "cd frontend && npm run dev"
xaku send-key --surface surface:1 Enter

xaku send --surface surface:2 "cd backend && cargo run"
xaku send-key --surface surface:2 Enter

xaku send --surface surface:3 "npm test -- --watch"
xaku send-key --surface surface:3 Enter

# Read output from any terminal
sleep 5
xaku read-screen --surface surface:2 --lines 20
```

## 6. TUI Application Testing

```bash
# Launch TUI
xaku new-workspace --cwd /path --command "htop"
# Returns: workspace:N

# Wait for TUI to render
sleep 2
xaku read-screen --workspace workspace:N --lines 40

# Send keys to interact
xaku send --workspace workspace:N "q"          # press 'q' (quit htop)
xaku send-key --workspace workspace:N Enter    # confirm
xaku send-key --workspace workspace:N Ctrl-c   # interrupt

# Arrow keys work directly
xaku send-key --workspace workspace:N Up
xaku send-key --workspace workspace:N Down
```

## 7. Run Tests and Monitor Output

```bash
# Create workspace
xaku new-workspace --cwd /path/to/project --name "tests"
# Returns: workspace:N

# Start test run
xaku send --workspace workspace:N "npm test"
xaku send-key --workspace workspace:N Enter

# Periodically check output
sleep 10
xaku read-screen --workspace workspace:N --scrollback --lines 100

# When done, clean up
xaku close-workspace --workspace workspace:N
```

## Tips

1. **Shell init takes time.** After `new-workspace`, wait 1-3 seconds before reading output. Heavy .zshrc configs (plugins, starship prompt) can take longer.

2. **Use `--scrollback --lines N`** for long-running commands to see historical output.

3. **Use `--surface` for multi-terminal setups** where you need to target specific terminals.

4. **Always clean up** when done:
   ```bash
   xaku close-workspace --workspace workspace:N
   ```

5. **For browser testing**, use the `web-verify` skill. xaku handles terminals only.
