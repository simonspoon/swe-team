# khora Command Reference and Gotchas

## Purpose

The full khora CLI command table and the gotchas accumulated from real web-verification
runs. Loaded by the `web-verify` SKILL.md when a workflow step needs the full command
surface or hits an edge case.

## Command Reference

| Command | Description |
|---------|-------------|
| `launch [--visible]` | Start Chrome, return session ID |
| `navigate <session> <url>` | Go to URL |
| `find <session> <selector>` | Find elements by CSS selector |
| `click <session> <selector>` | Click an element |
| `type <session> <selector> <text>` | Type text into element |
| `screenshot <session> [-o path]` | Capture screenshot |
| `text <session> <selector>` | Get text content |
| `attribute <session> <selector> <attr>` | Get attribute value |
| `wait-for <session> <selector> [--timeout ms]` | Wait for element |
| `wait-gone <session> <selector> [--timeout ms]` | Wait for disappearance |
| `console <session>` | Read console messages |
| `eval <session> <js>` | Execute JavaScript |
| `kill <session>` | Close browser |
| `status [session]` | Check session(s) |

## Gotchas

### Element Selection
- **CSS selectors only** — no XPath, no accessibility labels
- **`find` returns all matches** — use specific selectors to narrow results
- **Dynamic content** — use `wait-for` before `find` or `text` on dynamically loaded elements

### Navigation
- **Each `navigate` creates a new tab** — previous tab content is preserved but the new tab becomes active
- **URL must include protocol** — use `https://example.com`, not just `example.com`

### Screenshots
- **Full page** by default — captures the entire scrollable content
- **Headless mode** — screenshots work identically in headless and headed modes

### Timeouts
- Default 5000ms for all commands
- Override per-command: `--timeout 15000`
- Override globally: `KHORA_TIMEOUT=15000`
- Override format globally: `KHORA_FORMAT=json`
- **Timeout errors**: `wait-for` and `wait-gone` exit with a non-zero status if the timeout expires. Always handle this — if a wait fails mid-workflow, `kill` the session before returning an error.

### Click Behavior
- **Click can block during navigation.** If clicking a link triggers cross-origin navigation (e.g., clicking a link to an external site), the click command may hang until the navigation completes or times out. Use `--timeout` to limit wait time, or use `eval` with `element.click()` for more control.

### Error Recovery
- **Always kill sessions on failure.** If any command fails mid-workflow, run `khora kill "$SESSION"` before reporting the error. Orphaned Chrome processes consume memory.
- **Use `--format json`** when you need to parse output programmatically (e.g., extracting session ID from `launch`, checking element counts from `find`). Plain text output is fine for `text` and `eval` where you just need the value.
- **Error messages can be verbose.** Invalid CSS selectors and JavaScript errors include raw CDP error details. The key information is usually in the `description` or `message` field.

### Multiple Sessions
- **Only one session at a time.** khora uses a shared Chrome profile directory with a SingletonLock, so launching a second session while one is running will fail. Kill the current session before launching a new one.
- Always `kill` sessions when done to avoid orphaned Chrome processes

### SingletonLock Issues
- If `launch` fails with "SingletonLock: File exists", a previous Chrome process left a stale lock file
- Fix: `rm -f /private/var/folders/*/T/chromiumoxide-runner/SingletonLock` (the exact path is in the error message)
- This commonly happens after a crash or if `kill` didn't fully clean up
- Always run `khora kill` before removing the lock — the session might still be alive

### Stale Sessions
- `khora status` may show sessions whose Chrome process has already died
- `khora kill` on a dead session will error with "session expired or Chrome process died"
- To clean up stale session records: remove files from `~/.khora/sessions/`
