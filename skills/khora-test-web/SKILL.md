---
name: khora-test-web
description: Test and verify web applications using the khora CLI automation tool. Use when user mentions khora, testing web apps, browser testing, Chrome automation, verifying web pages, clicking buttons, taking screenshots, checking page content, or UI verification of web applications.
---

# Testing Web Apps with khora

Automate and verify web application UI using the `khora` CLI via Chrome DevTools Protocol.

## CRITICAL: Always Clean Up Chrome Sessions

**Every khora workflow MUST end with session cleanup, whether it succeeds or fails.**

Orphaned headless Chrome processes block the user's normal Chrome browser from opening.

```bash
# 1. Always kill your session when done
khora kill "$SESSION"

# 2. If anything fails mid-workflow, kill before returning error
khora kill "$SESSION" 2>/dev/null; echo "Error: <describe failure>"

# 3. Nuclear cleanup — if sessions are stale or Chrome won't open
pkill -f chromiumoxide-runner 2>/dev/null
rm -f /private/var/folders/*/T/chromiumoxide-runner/SingletonLock 2>/dev/null
```

**Wrap every khora workflow in this pattern:**
```bash
SESSION=$(khora --format json launch | jq -r .id)
# ... do work ...
khora kill "$SESSION"  # ALWAYS — even if commands above failed
```

## Quick Start

```bash
SESSION=$(khora --format json launch | jq -r .id)
khora navigate "$SESSION" "https://your-app.com"
khora screenshot "$SESSION" -o /tmp/screenshot.png
khora text "$SESSION" "h1"
khora kill "$SESSION"
```

## Setup Checklist

1. Chrome or Chromium is installed (auto-detected)
2. Or set `CHROME_PATH` to a custom Chrome binary
3. No special permissions needed (unlike desktop automation)

## Common Operations

### Launch and Navigate

```bash
# Headless (default, for CI/agents)
SESSION=$(khora --format json launch | jq -r .id)

# Headed (for debugging)
SESSION=$(khora --format json launch --visible | jq -r .id)

# Navigate
khora navigate "$SESSION" "https://your-app.com"
```

### Take and View a Screenshot

```bash
khora screenshot "$SESSION" -o /tmp/screenshot.png
```

Then read `/tmp/screenshot.png` with the Read tool to visually inspect the page.

### Inspect Elements

```bash
# Find elements by CSS selector (JSON for parsing)
khora --format json find "$SESSION" "button.submit"

# Get text content
khora text "$SESSION" "h1"
khora text "$SESSION" ".error-message"

# Get attribute values
khora attribute "$SESSION" "a.nav-link" "href"
khora attribute "$SESSION" "img" "src"
```

### Interact with Elements

```bash
# Click
khora click "$SESSION" "button.submit"

# Type text into input
khora type "$SESSION" "input[name=email]" "test@example.com"
```

### Wait for Elements

```bash
# Wait for element to appear (default 5s timeout)
khora wait-for "$SESSION" ".success-message"

# Custom timeout
khora wait-for "$SESSION" ".slow-content" --timeout 15000

# Wait for element to disappear
khora wait-gone "$SESSION" ".loading-spinner"
```

### Execute JavaScript

```bash
# Get page title
khora eval "$SESSION" "document.title"

# Count elements
khora eval "$SESSION" "document.querySelectorAll('li').length"

# Check app state
khora eval "$SESSION" "JSON.stringify(window.__APP_STATE__)"
```

**Important:** The expression MUST return a value. Expressions that return `undefined` (like `console.log(...)`) will error with "No value found". Append a return value if needed: `console.log('debug'); true`

### Read Console Logs

```bash
khora console "$SESSION"
```

### Session Management

```bash
# List all sessions
khora status

# Check specific session
khora status "$SESSION"

# Clean up
khora kill "$SESSION"
```

## Verification Workflow

1. **Launch** Chrome and get session ID
2. **Navigate** to the target URL
3. **Wait** for key elements to load with `wait-for`
4. **Screenshot** and visually inspect
5. **Verify** text content with `text` and `attribute`
6. **Interact** using `click`, `type`
7. **Wait** for expected UI changes
8. **Screenshot** again and compare
9. **Kill** the session — `khora kill "$SESSION"`
10. **Verify cleanup** — `khora status` should show no active sessions

If ANY step (2-8) fails, skip directly to step 9. Do not leave sessions running.

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

## Reference

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
