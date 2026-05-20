---
name: loki-test-desktop
description: Test and verify desktop applications on macOS using the loki CLI automation tool. Use when user mentions loki, testing desktop apps, macOS app testing, accessibility testing, UI automation, verifying app behavior, clicking buttons, taking screenshots, inspecting UI trees, or checking UI elements on a macOS desktop application.
---

# Testing Desktop Apps with loki

Automate and verify macOS desktop application UI using the `loki` CLI.

## Before Testing: Confirm the App Rendered

**CRITICAL — a blank window is a real bug, not a tool limitation.** loki drives
Tauri, Electron, and WebKit apps reliably: `click`, `tree`, `screenshot`, and
`type` all work. Before testing any behavior, confirm the app actually rendered:

1. Run `loki tree <WINDOW_ID>` — the content area must have children.
2. A webview app whose `AXWebArea` has **zero children**, or a window whose tree
   is only the title bar, is genuinely broken (blank / failed render).

If the tree is empty, **the app is broken — diagnose and report the breakage.**
Never report "loki can't see the DOM", "the webview composites blank", or
"verification not possible" — those are not real loki limitations. The only
documented loki/Tauri limitation is webview reload (see the Tauri Apps gotcha);
every other interaction is testable. If you are tempted to call verification
impossible, screenshot + dump the tree and report what you actually observed.

## Quick Start

```bash
loki check-permission
loki launch com.apple.Calculator
loki wait-window --bundle-id com.apple.Calculator
WINDOW_ID=$(loki windows --bundle-id com.apple.Calculator -f json | jq -r '.[0].window_id')
loki tree "$WINDOW_ID"
loki find "$WINDOW_ID" --role AXButton --title "5"
loki click-element "$WINDOW_ID" --role AXButton --title "5"
loki screenshot --window "$WINDOW_ID" --output /tmp/screenshot.png
loki kill com.apple.Calculator
```

## Setup Checklist

1. Accessibility permission is granted to your terminal (System Settings > Privacy & Security > Accessibility)
2. Verify with `loki check-permission` (should print "granted")
3. If denied, run `loki request-permission` and grant access, then restart terminal
4. The target application is running

## Global Flags

| Flag | Env var | Default | Description |
|------|---------|---------|-------------|
| `--format` / `-f` | `LOKI_FORMAT` | `text` | Output format: `text` or `json` |
| `--timeout` / `-t` | `LOKI_TIMEOUT` | `5000` | Default timeout in milliseconds |

## Common Operations

### Discover Windows

```bash
loki windows                                  # All windows
loki windows --bundle-id com.apple.Safari     # By bundle ID
loki windows --title "Calculator"             # By title glob
loki windows --pid 12345                      # By PID
```

Each window has a numeric `window_id` used by other commands.

### Inspect UI Elements

```bash
loki tree <WINDOW_ID>                         # Full accessibility tree
loki tree <WINDOW_ID> --depth 3               # Limit depth
loki tree <WINDOW_ID> --flat                  # Flat list
loki find <WINDOW_ID> --role AXButton         # Find by role
loki find <WINDOW_ID> --title "Save"          # Find by title
loki find <WINDOW_ID> --id "submit-btn"       # Find by identifier
```

Use `tree` first to understand the UI hierarchy, then `find` to locate specific elements.

### Click Elements

```bash
loki click 100 200                            # Click at coordinates
loki click 100 200 --double                   # Double click
loki click 100 200 --right                    # Right click
loki click-element <WINDOW_ID> --title "OK"   # Click by element query
loki click-element <WINDOW_ID> --role AXButton --title "Save"
```

### Type Text and Key Combos

```bash
loki type "Hello, world"                      # Type into focused app
loki type "Hello" --window <WINDOW_ID>        # Target specific window
loki key cmd+s                                # Key combo
loki key cmd+shift+a --window <WINDOW_ID>     # Targeted key combo
loki key return                               # Press Enter
loki key tab                                  # Press Tab
```

Modifier names: `cmd`, `shift`, `ctrl`, `alt`/`option`.

### Take Screenshots

```bash
loki screenshot --window <WINDOW_ID> --output /tmp/screenshot.png
loki screenshot --screen --output /tmp/fullscreen.png
```

Then read the PNG file with the Read tool to visually inspect the app.

### Wait for UI Changes

```bash
loki wait-for <WINDOW_ID> --role AXButton --title "Done"
loki wait-for <WINDOW_ID> --title "Success" --timeout 10000
loki wait-gone <WINDOW_ID> --title "Loading..."
loki wait-window --bundle-id com.apple.TextEdit
loki wait-title <WINDOW_ID> "*.txt"
```

### App Lifecycle

```bash
loki launch com.apple.Calculator
loki launch /Applications/Safari.app
loki app-info com.apple.Calculator
loki kill com.apple.Calculator
loki kill --force com.apple.Calculator
```

## Verification Workflow

1. **Screenshot** the initial state
2. **Inspect** the UI with `tree` or `find` to locate elements
3. **Interact** using `click-element`, `type`, `key`
4. **Wait** for expected UI changes with `wait-for`
5. **Screenshot** again and compare
6. **Verify** element presence with `find` or `wait-for`

## Scripting Pattern

```bash
# Launch app, find window, interact, verify
loki launch com.apple.TextEdit
loki wait-window --bundle-id com.apple.TextEdit
WINDOW=$(loki windows --bundle-id com.apple.TextEdit -f json | jq -r '.[0].window_id')
loki type "Hello" --window "$WINDOW"
loki key cmd+s --window "$WINDOW"
loki screenshot --window "$WINDOW" --output after-save.png
```

## Gotchas

### Permissions
- **"permission denied" errors**: Grant Accessibility access in System Settings, then **restart your terminal**.
- **check-permission says denied but you granted it**: The binary path may differ. Re-grant for the specific terminal app.

### Element Selection
- **Role matching is case-insensitive**: `button`, `AXButton`, and `BUTTON` all work.
- **Title matching supports globs**: `--title "Untitled*"` matches "Untitled" and "Untitled - Edited".
- **Use `tree --flat` for a quick element list** instead of the hierarchical tree.

### Input
- **Keyboard input uses System Events**: Reliable across apps but requires the target app to be in the foreground.
- **Use `--window` or `--pid` with `type` and `key`**: This activates the target app before sending input.
- **Double and right click are separate flags**: `--double` and `--right` on the `click` command.

### Screenshots
- **Default output is `loki-screenshot.png` in the current directory**: Use `--output` to specify a path.
- **`--screen` captures all displays**: Use `--window <ID>` for a specific window.
- **A WebGL/GPU sub-region may screenshot blank — but never the whole window.** A WebGL canvas, xterm.js terminal, or 3D viewer can capture as a solid-colored rectangle while rendering fine on screen. This caveat covers only that GPU-composited *region* — it does NOT explain an entirely blank window. To tell them apart, run `loki tree <WINDOW_ID>`: if the tree still lists the app's buttons and text, only the GPU region failed to capture (harmless — verify via the tree instead). If the tree shows an empty `AXWebArea` or no app content, **the app is genuinely broken** — report the breakage; do not blame the screenshot or call verification impossible.

### Tauri Apps
- **Build a testable app with `tauri build`, not `cargo build`.** `pnpm tauri build` builds the frontend and embeds it into a production binary, producing `target/release/bundle/macos/<Name>.app`. A plain `cargo build` produces a *dev* binary with **no embedded frontend** — it expects a running dev server and renders blank when launched standalone. The `.app` bundle exists only after `tauri build`.
- **Launch via the `.app` bundle**, not the bare binary: `open target/release/bundle/macos/<Name>.app` (or `pnpm tauri dev`). Running `target/release/<name>` directly may render blank because it lacks the bundle resource context.
- **Never modify the user's installed app.** Do not copy a binary or bundle over `/Applications/<Name>.app`, and do not re-sign the installed app. Test the freshly-built bundle in place from `target/release/bundle/macos/<Name>.app`. Overwriting `/Applications` is a destructive change to the user's environment — if a test truly requires it, ask the user first.
- **Webview reload (Cmd+R) cannot be triggered via loki keyboard shortcuts.** Tauri v2 does not expose webview reload via standard keyboard shortcuts by default. If testing reload-resilience behavior, you cannot simulate it with `loki key cmd+r`. Options: (1) test manually and ask the user to confirm, (2) add a Tauri command in the app that forces a webview reload, (3) verify the code path exists (reattach logic compiles and is wired up) without exercising it live.
- **Devtools steal keyboard shortcuts.** If Cmd+Alt+I or Cmd+Shift+I opens browser devtools in a Tauri app, subsequent keyboard shortcuts (Cmd+D, Cmd+K, etc.) may be captured by devtools instead of the app. Close devtools before testing keyboard interactions, or use `click-element` instead.

### Empty Results
- **`loki windows` returns an empty JSON array `[]`** when no windows match the filter -- it does not error. Always check the array length before extracting `.[0].window_id`.
- **`loki find` returns `[]`** when no elements match. The exit code is still 0. Use `wait-for` if you need to block until an element appears.

### Timeouts
- **`wait-for`, `wait-gone`, `wait-window`, and `wait-title` exit with code 3 on timeout.** Always check the exit code or use `set -e` in scripts to catch timeout failures.
- **`jq` is required** for the JSON parsing patterns shown in Quick Start and Scripting Pattern. Ensure it is installed.

### Button Titles
- **Accessibility titles may differ from visible labels.** For example, Calculator buttons show "+", "-", etc. on screen but their accessibility titles are "Add", "Subtract", "Multiply", "Divide". Always use `loki find` or `loki tree --flat` to discover the actual titles before writing click commands.

## Reference

See [REFERENCE.md](REFERENCE.md) for complete command documentation.
