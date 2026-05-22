---
name: web-verify
description: Test and verify web applications using the khora CLI automation tool. Use when user mentions khora, testing web apps, browser testing, Chrome automation, verifying web pages, clicking buttons, taking screenshots, checking page content, or UI verification of web applications.
triggers:
  - verify the web app
  - test this web page in a browser
  - QA the web UI
  - browser-automate this page with khora
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

## Reference

- `reference/commands.md` — the full khora CLI command table and the gotchas
  (element selection, navigation, screenshots, timeouts, click behavior, error
  recovery, multiple sessions, SingletonLock, stale sessions). Read it for the
  full command surface and when a workflow step hits an edge case.
