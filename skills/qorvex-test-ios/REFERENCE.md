# qorvex Command Reference

Complete reference for all qorvex CLI commands.

## Global Options

All commands accept these options:

| Option | Description | Default |
|--------|-------------|---------|
| `-s, --session <NAME>` | Session name | `default` (or `$QORVEX_SESSION`) |
| `-f, --format <FORMAT>` | Output format: `text` or `json` | `text` |
| `-q, --quiet` | Suppress non-essential output | off |

## Session Management

### start

Start server, session, and agent in one step.

```bash
qorvex start
```

### start-session

Start an automation session (auto-starts agent if configured).

```bash
qorvex start-session
```

### start-agent

Start or connect to the automation agent.

```bash
qorvex start-agent
```

### stop

Stop the server for this session.

```bash
qorvex stop
```

### status

Get current session state.

```bash
qorvex status
```

### list-sessions

List all running qorvex sessions.

```bash
qorvex list-sessions
```

## Target App Management

### set-target

Set the target application bundle ID.

```bash
qorvex set-target <BUNDLE_ID>
qorvex set-target com.example.myapp
qorvex set-target com.example.myapp --tag "setup"
```

| Option | Description |
|--------|-------------|
| `--tag <TAG>` | Annotate the action log entry |

### start-target

Launch the target application.

```bash
qorvex start-target
```

### stop-target

Terminate the target application.

```bash
qorvex stop-target
```

## Interaction Commands

### tap

Tap an element by accessibility ID or label.

```bash
qorvex tap <SELECTOR>
qorvex tap "submitButton"          # By ID (default)
qorvex tap -l "Submit"             # By label
qorvex tap -l "Save" -T Button    # By label, filtered to Button type
qorvex tap -l "OK" -o 10000       # With 10s timeout
qorvex tap -l "Done" --no-wait    # Single attempt, no retry
```

| Option | Description | Default |
|--------|-------------|---------|
| `-l, --label` | Match by accessibility label instead of ID | off (matches by ID) |
| `-T, --type <TYPE>` | Filter by element type (e.g., Button, TextField) | none |
| `--no-wait` | Skip retry, attempt tap once | off |
| `-o, --timeout <MS>` | Timeout in ms for retrying | `5000` |
| `--tag <TAG>` | Annotate the action log entry | none |

### tap-location

Tap at specific screen coordinates.

```bash
qorvex tap-location <X> <Y>
qorvex tap-location 200 500
```

### send-keys

Send keyboard input to the focused element.

```bash
qorvex send-keys <TEXT>
qorvex send-keys "Hello World"
```

### swipe

Swipe the screen in a direction.

```bash
qorvex swipe <DIRECTION>
qorvex swipe up
qorvex swipe down
qorvex swipe left
qorvex swipe right
```

## Query Commands

### screenshot

Capture a screenshot. Outputs base64-encoded PNG to stdout.

```bash
# Raw base64 output
qorvex screenshot

# Decode to PNG file
qorvex screenshot 2>/dev/null | base64 -d > /tmp/screenshot.png
```

### screen-info

Get UI hierarchy information. Returns JSON array of elements.

```bash
qorvex screen-info
```

Each element contains:

| Field | Description |
|-------|-------------|
| `type` | Element type: Application, NavigationBar, StaticText, Button, Image, TextField, Other |
| `label` | Accessibility label (human-readable text) |
| `id` | Accessibility identifier (developer-set ID) |
| `value` | Current value (for inputs, sliders, etc.) |
| `frame` | Position and size: `{x, y, width, height}` |

### get-value

Get the value of an element by ID or label.

```bash
qorvex get-value <SELECTOR>
qorvex get-value "usernameField"      # By ID
qorvex get-value -l "Username"        # By label
```

| Option | Description |
|--------|-------------|
| `-l, --label` | Match by accessibility label |
| `-T, --type <TYPE>` | Filter by element type |
| `-o, --timeout <MS>` | Timeout in ms |

### wait-for

Wait for an element to appear.

```bash
qorvex wait-for <SELECTOR>
qorvex wait-for "successLabel"         # By ID
qorvex wait-for -l "Success"          # By label
qorvex wait-for -l "Done" -o 10000   # 10s timeout
```

### wait-for-not

Wait for an element to disappear.

```bash
qorvex wait-for-not <SELECTOR>
qorvex wait-for-not -l "Loading..."
qorvex wait-for-not -l "Spinner" -o 15000
```

## Logging Commands

### comment

Log a comment to the session action log.

```bash
qorvex comment <TEXT>
qorvex comment "Starting login flow test"
```

### log

Get action log history.

```bash
qorvex log
```

Output format:
```
[HH:MM:SS] Action { details } - Success|Failure("reason")
```

### convert

Convert a JSONL action log to a shell script.

```bash
qorvex convert <INPUT_FILE>
```

## Simulator Commands

### list-devices

List available simulator devices.

```bash
qorvex list-devices
```

### boot-device

Boot a simulator device.

```bash
qorvex boot-device <DEVICE_ID>
```

## Element Types

Common element types returned by `screen-info`:

| Type | Description |
|------|-------------|
| `Application` | The app root element |
| `NavigationBar` | Navigation bar |
| `Button` | Tappable button |
| `StaticText` | Text label |
| `TextField` | Text input field |
| `SecureTextField` | Password input field |
| `Image` | Image element |
| `ScrollView` | Scrollable container |
| `Table` | Table/list view |
| `Cell` | Table/list cell |
| `Switch` | Toggle switch |
| `Slider` | Slider control |
| `Other` | Other element types (scroll indicators, etc.) |
