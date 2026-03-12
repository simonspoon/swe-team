---
name: qorvex-test-ios
description: Test and verify iOS applications running in the simulator or on physical devices using the qorvex CLI automation tool. Use when user mentions qorvex, testing iOS apps, simulator testing, physical device testing, WiFi device automation, UI automation, verifying app behavior, tapping buttons, taking screenshots, or checking UI elements on an iOS simulator or real device.
---

# Testing iOS Apps with qorvex

Automate and verify iOS application UI on simulators and physical devices using the `qorvex` CLI.

## Quick Start (Simulator)

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

### Simulator
1. A simulator is booted (`xcrun simctl list devices booted`)
2. The app is installed and running on the simulator
3. Start a qorvex session with `qorvex start`
4. Set the target bundle ID with `qorvex set-target <BUNDLE_ID>`

### Physical Device (WiFi)
1. Device and Mac are on the same WiFi network
2. **UI Automation** is enabled on device: Settings > Developer > Enable UI Automation
3. Device is **unlocked** and stays unlocked during testing
4. App is code-signed for the physical device (see [troubleshooting.md](troubleshooting.md#code-signing-errors))
5. Find the device UDID with `qorvex list-physical-devices`
6. Start a qorvex session with `qorvex start --device <UDID>`
7. Set the target bundle ID with `qorvex set-target <BUNDLE_ID>`

## Physical Device Workflow (WiFi)

After completing the Physical Device setup checklist above:

```bash
# 1. List physical devices — find the UDID
qorvex list-physical-devices

# 2. Start session with the device selected
qorvex start --device <UDID>

# 3. Start the agent (builds + deploys + connects over WiFi)
qorvex start-agent
# ⚠️ This can take 30-60s on physical devices. If it times out:
#   - Ensure device is UNLOCKED
#   - Retry — first attempt often fails with LaunchServicesDataMismatch
#   - If agent is already running on device, start-agent detects and reuses it

# 4. Set target app
qorvex set-target <BUNDLE_ID>

# 5. Launch the app — start-target is SIMULATOR ONLY
# On physical devices, use devicectl instead:
xcrun devicectl device process launch --device <UDID> <BUNDLE_ID>

# 6. Now use tap, screenshot, screen-info, etc. as normal
qorvex screenshot 2>/dev/null | base64 -d > /tmp/screenshot.png
```

### Physical Device Gotchas

- **`start-target` / `stop-target` are simulator-only.** Use `xcrun devicectl device process launch` / `xcrun devicectl device process terminate` for physical devices.
- **`screen-info` is very slow on SpringBoard.** Always launch your target app BEFORE calling `screen-info`. The home screen has thousands of elements and can hang for minutes.
- **Latency is ~1-2s per command** over WiFi (vs near-instant on simulator). This is normal.
- **Agent timeout on first deploy**: The first `start-agent` after a clean build often takes longer. If it times out, just retry.

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

After typing, the keyboard stays visible and covers the bottom of the screen. **Dismiss it before tapping other elements:**

```bash
qorvex swipe down   # dismisses keyboard
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
# Simulator only:
qorvex start-target    # Launch the app
qorvex stop-target     # Terminate the app

# Physical device:
xcrun devicectl device process launch --device <UDID> <BUNDLE_ID>
xcrun devicectl device process terminate --device <UDID> <BUNDLE_ID>
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

## Home Screen / SpringBoard

To verify things outside an app (app icons, home screen layout, notifications):

```bash
# Switch qorvex target to SpringBoard
qorvex set-target com.apple.springboard

# Dismiss a foreground app (go to home screen)
qorvex swipe up

# Screenshot the home screen
qorvex screenshot 2>/dev/null | base64 -d > /tmp/homescreen.png

# Inspect home screen elements
qorvex screen-info
```

**Do NOT use `xcrun simctl sendkey`** — this subcommand does not exist. Use `qorvex swipe up` to dismiss apps instead.

To terminate a specific app before returning to the home screen:

```bash
xcrun simctl terminate <udid> <bundle_id>
qorvex set-target com.apple.springboard
qorvex swipe up
```

## Gotchas

- **Tap fails with "not found"**: You likely need `-l` (label) instead of ID matching
- **Screenshot is base64**: Always pipe through `base64 -d` to get PNG
- **Multiple elements with same label**: Use `-T` to filter by type (e.g., `-T Button`)
- **Stale session**: Run `qorvex status` to check; `qorvex start` to restart
- **Architecture**: On Intel Macs, build for `iossimulator-x64`; on Apple Silicon, `iossimulator-arm64`
- **Physical device hostname**: Use `<Name>.local` (Bonjour), NOT `<Name>.coredevice.local`
- **`start-target` is simulator-only**: On physical devices, use `xcrun devicectl device process launch`
- **`screen-info` on SpringBoard is very slow**: Launch target app first, then query
- **Keyboard covers tab bar / buttons**: After tapping a text field, the on-screen keyboard hides elements behind it. Dismiss the keyboard before tapping anything below it. Use `qorvex swipe down` to dismiss, then retry the tap. Do NOT attempt to tap obscured elements — they will fail with "not found".
- **Switch/Toggle elements don't respond to tap**: iOS Switch accessibility frames span the full row width (label + switch). The tap center lands on the label area, not the switch control. Workaround: use `qorvex tap-location` with coordinates targeting the right side of the switch (use `screen-info` frame data: `x + width - 30, y + height/2`).
- **`list-physical-devices` shows "Unknown" for device name**: usbmuxd doesn't always have the human-readable name. Run `xcrun devicectl list devices` to confirm the device name, model, and connection type.
- **Label matching is exact, not substring**: `get-value -l "Tapped:"` will NOT find an element with label `"Tapped: 3"`. For dynamic labels that include their value, use `screen-info` and grep for the text, or use the element's accessibility ID instead.
- **Tapping a label doesn't focus the input field**: A `StaticText` element (e.g., "Password" above a text field) is a separate element from the field itself. Tapping it does nothing useful. Use `screen-info` to find the actual `TextField` or `SecureTextField` element and tap it by accessibility ID.
- **Dev builds vs installed binary**: When running from the repo (not installed), use `cargo run --bin qorvex --` instead of `qorvex`. The `--` separator is required before flags like `-l`, `-T`, `-o`.

## Troubleshooting

See [troubleshooting.md](troubleshooting.md) for device connectivity, code signing, and common errors.

## Reference

See [REFERENCE.md](REFERENCE.md) for complete command documentation.
