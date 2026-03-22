---
name: khora-test-web
description: Test and verify web applications using the khora CLI automation tool. Use when user mentions khora, testing web apps, browser testing, Chrome automation, verifying web pages, clicking buttons, taking screenshots, checking page content, or UI verification of web applications.
---

# Testing Web Apps with khora

Automate and verify web application UI using the `khora` CLI via Chrome DevTools Protocol.

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
9. **Kill** the session

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

### Multiple Sessions
- Each `launch` creates an independent Chrome instance
- Sessions don't share state, cookies, or cache
- Always `kill` sessions when done to avoid orphaned Chrome processes

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
