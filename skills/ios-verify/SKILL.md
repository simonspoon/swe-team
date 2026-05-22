---
name: ios-verify
description: Test and verify iOS applications running in the simulator or on physical devices using the qorvex CLI automation tool. Use when user mentions qorvex, testing iOS apps, simulator testing, physical device testing, WiFi device automation, UI automation, verifying app behavior, tapping buttons, taking screenshots, or checking UI elements on an iOS simulator or real device.
triggers:
  - verify the iOS app
  - test this app in the simulator
  - QA the iOS UI
  - automate this iOS app with qorvex
---

# Testing iOS Apps with qorvex

Automate and verify iOS application UI on simulators and physical devices using the `qorvex` CLI.

## Quick Start (Simulator)

```bash
qorvex start
qorvex set-target com.example.myapp
qorvex screenshot 2>/dev/null | base64 -d > /tmp/screenshot.png
qorvex screen-info
qorvex tap -l "Submit"
```

## Quick Start (Physical Device)

```bash
# Find the device UDID
qorvex list-physical-devices

# Start session — builds agent, deploys to device, connects automatically
qorvex start -d <UDID>

# Set target and interact
qorvex set-target <BUNDLE_ID>
qorvex screenshot 2>/dev/null | base64 -d > /tmp/screenshot.png
```

`qorvex start -d` handles the full pipeline: foreground agent build (with signing), server start, device selection, agent deployment, and connection. No separate `start-agent` needed.

## Setup Checklist

### Simulator
1. A simulator is booted (`xcrun simctl list devices booted`)
2. The app is installed and running on the simulator
3. Start a qorvex session with `qorvex start`
4. Set the target bundle ID with `qorvex set-target <BUNDLE_ID>`

### Physical Device
1. Device and Mac are on the same WiFi network
2. **UI Automation** is enabled on device: Settings > Developer > Enable UI Automation
3. Device is **unlocked** and stays unlocked during testing
4. Per-user signing config is set in `~/.qorvex/config.json` (see below)
5. Find the device UDID with `qorvex list-physical-devices`
6. Start a qorvex session with `qorvex start -d <UDID>`
7. Set the target bundle ID with `qorvex set-target <BUNDLE_ID>`

### Per-User Signing Config (`~/.qorvex/config.json`)

Physical devices require code signing. Since qorvex is open-source, signing config is per-user (NOT in the repo). Create or edit `~/.qorvex/config.json`:

```json
{
  "agent_source_dir": "/path/to/qorvex/qorvex-agent",
  "development_team": "YOUR_TEAM_ID",
  "agent_bundle_id": "com.yourorg.qorvex.agent"
}
```

| Field | Required | Description |
|-------|----------|-------------|
| `agent_source_dir` | Yes | Path to the Swift agent project directory |
| `development_team` | Yes (physical) | Apple Development Team ID (find in Xcode > Settings > Accounts) |
| `agent_bundle_id` | If needed | Override bundle ID when default `com.qorvex.agent` is claimed by another team |

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

Returns JSON array of elements with `type`, `label`, `id`, `frame`, and `value` fields, followed by a summary line (e.g., `40 elements`). If parsing the JSON programmatically, strip the last line first. Use this to discover element labels and IDs before interacting.

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

After typing, the keyboard stays visible and covers the bottom of the screen. **Dismiss it before tapping other elements:**

```bash
qorvex swipe down   # dismisses keyboard
```

### Wait for Elements

```bash
qorvex wait-for -l "Success"                  # Default 5s timeout
qorvex wait-for -l "Loading complete" -o 10000  # Custom timeout
qorvex wait-for-not -l "Loading..."            # Wait to disappear
```

### Get Element Value

```bash
qorvex get-value -l "Username"
```

### Swipe the Screen

```bash
qorvex swipe up|down|left|right
```

### Manage the Target App

```bash
# Simulator only:
qorvex start-target    # Launch the app
qorvex stop-target     # Terminate the app

# Physical device:
xcrun devicectl device process launch --device <UDID> <BUNDLE_ID>
xcrun devicectl device process terminate --device <UDID> <BUNDLE_ID>
```

**Note:** After `start-target`, the app may take a moment to fully render its UI. Use `wait-for` on a known element before interacting, rather than immediately calling `screen-info` or `tap`.

## Verification Workflow

1. **Screenshot** the initial state
2. **Inspect** the UI with `screen-info` to find elements
3. **Interact** using `tap`, `send-keys`, `swipe`
4. **Wait** for expected UI changes with `wait-for`
5. **Screenshot** again and compare
6. **Verify** element values with `get-value` or `screen-info`

## Home Screen / SpringBoard

First terminate the foreground app, then navigate to SpringBoard:

```bash
xcrun simctl terminate <udid> <bundle_id>     # simulator
qorvex set-target com.apple.springboard
qorvex swipe up               # go to home screen
qorvex screenshot 2>/dev/null | base64 -d > /tmp/homescreen.png
```

**Important:** `swipe up` alone won't go to the home screen if a foreground app is still running — it will swipe within that app. Terminate the app first.

**Do NOT use `xcrun simctl sendkey`** — this subcommand does not exist.

To terminate an app:

```bash
xcrun simctl terminate <udid> <bundle_id>     # simulator
xcrun devicectl device process terminate --device <UDID> <BUNDLE_ID>  # physical
```

## Gotchas

### Element Selection
- **Tap fails with "not found"**: Use `-l` (label) instead of ID matching. Run `screen-info` first.
- **Multiple elements with same label**: Use `-T` to filter by type (e.g., `-T Button`).
- **Label matching is exact, not substring**: `get-value -l "Tapped:"` will NOT find `"Tapped: 3"`. Use `screen-info` and grep, or use the element's accessibility ID.
- **Tapping a label doesn't focus the input**: A `StaticText` label is separate from the `TextField` below it. Use `screen-info` to find the actual `TextField` or `SecureTextField` and tap by its ID.

### Keyboard & Layout
- **Keyboard covers elements**: After tapping a text field, dismiss the keyboard with `qorvex swipe down` before tapping anything below it.
- **Switch/Toggle tap lands on label**: iOS Switch frames span the full row. Use `qorvex tap-location` targeting the right side (from `screen-info` frame: `x + width - 30, y + height/2`).

### Physical Device Specific
- **`start-target` / `stop-target` are simulator-only.** Use `xcrun devicectl` for physical devices.
- **`screen-info` is very slow on SpringBoard.** Always launch your target app BEFORE calling `screen-info`.
- **Latency is ~1-2s per command** over WiFi. This is normal.
- **Agent deploy takes 30-60s** on first run. Timeout is 120s. If it still times out, ensure device is **unlocked** and retry.
- **Hostname**: Use `<Name>.local` (Bonjour), NOT `<Name>.coredevice.local`.
- **`list-physical-devices` shows "Unknown"**: Run `xcrun devicectl list devices` to confirm device name.

### Development
- **Dev builds vs installed binary**: Use `cargo run --bin qorvex --` instead of `qorvex`. The `--` separator is required before flags.
- **Screenshot is base64**: Always pipe through `base64 -d` to get PNG.
- **Stale session**: Run `qorvex status` to check; `qorvex start` to restart.

## Reference

- `reference/commands.md` — the complete qorvex CLI command documentation. Read it
  when a workflow step needs the full command surface or option detail.
- `reference/troubleshooting.md` — device connectivity, code signing, and common
  errors. Read it when a workflow step hits a connectivity or signing failure.
