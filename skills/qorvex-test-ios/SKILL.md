---
name: qorvex-test-ios
description: Test and verify iOS applications running in the simulator using the qorvex CLI automation tool. Use when user mentions qorvex, testing iOS apps, simulator testing, UI automation, verifying app behavior, tapping buttons, taking screenshots, or checking UI elements in an iOS simulator.
---

# Testing iOS Apps with qorvex

Automate and verify iOS application UI in the simulator using the `qorvex` CLI.

## Quick Start

```bash
# Start a qorvex session
qorvex start

# Target your app
qorvex set-target com.example.myapp

# Take a screenshot (outputs base64 PNG)
qorvex screenshot 2>/dev/null | base64 -d > /tmp/screenshot.png

# Inspect the UI hierarchy
qorvex screen-info

# Tap a button by label
qorvex tap -l "Submit"
```

## Setup Checklist

Before testing, ensure:
1. A simulator is booted (`xcrun simctl list devices booted`)
2. The app is installed and running on the simulator
3. Start a qorvex session with `qorvex start`
4. Set the target bundle ID with `qorvex set-target <BUNDLE_ID>`

## Common Operations

### Take and View a Screenshot

```bash
qorvex screenshot 2>/dev/null | base64 -d > /tmp/screenshot.png
```

Then read `/tmp/screenshot.png` with the Read tool to visually inspect the app.

### Inspect UI Elements

```bash
qorvex screen-info
```

Returns JSON array of elements with `type`, `label`, `id`, `frame`, and `value` fields. Use this to discover element labels and IDs before interacting.

### Tap an Element

```bash
# By accessibility ID (default)
qorvex tap "submitButton"

# By accessibility label (use -l flag)
qorvex tap -l "Click me"

# By label filtered to a specific type
qorvex tap -l "Save" -T Button

# At specific coordinates
qorvex tap-location 200 500
```

**Important:** Default matching is by accessibility ID. Use `-l` for label matching. Use `screen-info` first to find the correct selector.

### Type Text

```bash
qorvex send-keys "Hello World"
```

### Wait for Elements

```bash
# Wait for element to appear (default 5s timeout)
qorvex wait-for -l "Success"

# Custom timeout
qorvex wait-for -l "Loading complete" -o 10000

# Wait for element to disappear
qorvex wait-for-not -l "Loading..."
```

### Get Element Value

```bash
qorvex get-value -l "Username"
```

### Swipe the Screen

```bash
qorvex swipe up
qorvex swipe down
qorvex swipe left
qorvex swipe right
```

### Manage the Target App

```bash
qorvex start-target    # Launch the app
qorvex stop-target     # Terminate the app
```

## Verification Workflow

Follow this pattern when verifying app behavior:

1. **Screenshot** the initial state
2. **Inspect** the UI with `screen-info` to find elements
3. **Interact** using `tap`, `send-keys`, `swipe`
4. **Wait** for expected UI changes with `wait-for`
5. **Screenshot** again and compare
6. **Verify** element values with `get-value` or `screen-info`

## Complete Example: Test a Counter Button

```bash
# Setup
qorvex start
qorvex set-target com.companyname.samplemauiapp

# Verify initial state
qorvex screenshot 2>/dev/null | base64 -d > /tmp/before.png
qorvex screen-info   # Find the button label

# Interact
qorvex tap -l "Click me"

# Verify the button text changed
qorvex wait-for -l "Clicked 1 time"
qorvex screenshot 2>/dev/null | base64 -d > /tmp/after.png

# Check the action log
qorvex log
```

## Gotchas

- **Tap fails with "not found"**: You likely need `-l` (label) instead of ID matching
- **Screenshot is base64**: Always pipe through `base64 -d` to get PNG
- **Multiple elements with same label**: Use `-T` to filter by type (e.g., `-T Button`)
- **Stale session**: Run `qorvex status` to check; `qorvex start` to restart
- **Architecture**: On Intel Macs, build for `iossimulator-x64`; on Apple Silicon, `iossimulator-arm64`

## Reference

See [REFERENCE.md](REFERENCE.md) for complete command documentation.
