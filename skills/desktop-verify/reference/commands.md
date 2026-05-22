# loki Command Reference

## Purpose

The complete reference for every loki CLI command. Loaded by the `desktop-verify`
SKILL.md when a workflow step needs the full command surface or option detail.

## Global Options

All commands accept these options:

| Option | Env var | Default | Description |
|--------|---------|---------|-------------|
| `-f, --format <FORMAT>` | `LOKI_FORMAT` | `text` | Output format: `text` or `json` |
| `-t, --timeout <TIMEOUT>` | `LOKI_TIMEOUT` | `5000` | Default timeout in milliseconds |

## Permission Commands

### check-permission

Check if accessibility permission is granted.

```bash
loki check-permission
loki check-permission -f json    # {"granted": true}
```

### request-permission

Open the system prompt to grant accessibility permission.

```bash
loki request-permission
```

## Window Commands

### windows

List open windows, optionally filtered.

```bash
loki windows
loki windows --title "Calculator"
loki windows --bundle-id com.apple.Safari
loki windows --pid 12345
```

| Option | Description |
|--------|-------------|
| `--title <PATTERN>` | Filter by title (glob pattern) |
| `--bundle-id <ID>` | Filter by bundle identifier |
| `--pid <PID>` | Filter by process ID |

## App Lifecycle Commands

### launch

Launch an application by bundle ID or path.

```bash
loki launch com.apple.Calculator
loki launch /Applications/Safari.app
loki launch com.apple.TextEdit --args /tmp/test.txt
loki launch com.apple.Calculator --wait false
```

| Option | Description | Default |
|--------|-------------|---------|
| `--args <ARGS>...` | Arguments to pass to the app | none |
| `--wait <BOOL>` | Wait for app to finish launching | `true` |

### kill

Kill an application.

```bash
loki kill com.apple.Calculator
loki kill --force com.apple.Calculator
```

| Option | Description |
|--------|-------------|
| `--force` | Send SIGKILL instead of SIGTERM |

### app-info

Get info about a running application.

```bash
loki app-info com.apple.Calculator
loki app-info 12345              # By PID
```

Returns PID, name, bundle ID, and whether the app is active.

## Accessibility Tree Commands

### tree

Dump the accessibility tree for a window.

```bash
loki tree <WINDOW_ID>
loki tree <WINDOW_ID> --depth 3
loki tree <WINDOW_ID> --flat
```

| Option | Description |
|--------|-------------|
| `--depth <N>` | Maximum tree depth |
| `--flat` | Output as flat element list instead of tree |

### find

Find elements in a window's accessibility tree.

```bash
loki find <WINDOW_ID> --role AXButton
loki find <WINDOW_ID> --title "Save"
loki find <WINDOW_ID> --role AXButton --title "OK"
loki find <WINDOW_ID> --id "submit-button"
loki find <WINDOW_ID> --role AXButton --index 0
```

| Option | Description |
|--------|-------------|
| `--role <ROLE>` | Match by accessibility role (case-insensitive, AX prefix optional) |
| `--title <PATTERN>` | Match by title/label/description (glob pattern) |
| `--id <ID>` | Match by accessibility identifier (exact) |
| `--index <N>` | Select the Nth match (0-based) |

## Input Commands

### click

Click at absolute screen coordinates.

```bash
loki click <X> <Y>
loki click 100 200
loki click 100 200 --double
loki click 100 200 --right
```

| Option | Description |
|--------|-------------|
| `--double` | Double click |
| `--right` | Right click |

### click-element

Click the center of a UI element found by query.

```bash
loki click-element <WINDOW_ID> --title "OK"
loki click-element <WINDOW_ID> --role AXButton --title "Save"
loki click-element <WINDOW_ID> --id "submit-button"
```

| Option | Description |
|--------|-------------|
| `--role <ROLE>` | Match by role |
| `--title <PATTERN>` | Match by title |
| `--id <ID>` | Match by identifier |

### type

Type a string of text.

```bash
loki type "Hello, world"
loki type "Hello" --window <WINDOW_ID>
loki type "Hello" --pid 12345
```

| Option | Description |
|--------|-------------|
| `--pid <PID>` | Target process ID (activates app first) |
| `--window <WINDOW_ID>` | Target window (resolves PID automatically) |

### key

Press a key combination.

```bash
loki key cmd+s
loki key cmd+shift+a
loki key return
loki key tab
loki key cmd+s --window <WINDOW_ID>
```

| Option | Description |
|--------|-------------|
| `--pid <PID>` | Target process ID |
| `--window <WINDOW_ID>` | Target window |

Modifier names: `cmd`/`command`/`super`, `shift`, `ctrl`/`control`, `alt`/`option`/`opt`.

Special keys: `return`/`enter`, `tab`, `space`, `delete`/`backspace`, `escape`/`esc`, `up`, `down`, `left`, `right`, `home`, `end`, `pageup`, `pagedown`, `f1`-`f12`.

## Screenshot Commands

### screenshot

Capture a screenshot.

```bash
loki screenshot --window <WINDOW_ID>
loki screenshot --screen
loki screenshot --window <WINDOW_ID> --output result.png
```

| Option | Description | Default |
|--------|-------------|---------|
| `--window <ID>` | Capture specific window | none |
| `--screen` | Capture full screen | `false` |
| `-o, --output <PATH>` | Output file path | `loki-screenshot.png` |

## Wait Commands

All wait commands poll until the condition is met or timeout expires.

### wait-for

Wait for an element to appear.

```bash
loki wait-for <WINDOW_ID> --role AXButton --title "Done"
loki wait-for <WINDOW_ID> --title "Success" --timeout 10000
```

### wait-gone

Wait for an element to disappear.

```bash
loki wait-gone <WINDOW_ID> --title "Loading..."
loki wait-gone <WINDOW_ID> --role AXProgressIndicator --timeout 15000
```

### wait-window

Wait for a window to appear.

```bash
loki wait-window --title "Document"
loki wait-window --bundle-id com.apple.TextEdit --timeout 10000
```

### wait-title

Wait for a window title to match a pattern.

```bash
loki wait-title <WINDOW_ID> "Saved"
loki wait-title <WINDOW_ID> "*.txt" --timeout 5000
```

| Option | Description | Default |
|--------|-------------|---------|
| `--timeout <MS>` | Override timeout | global `--timeout` |

## Utility Commands

### completions

Generate shell completions.

```bash
loki completions bash > ~/.bash_completion.d/loki
loki completions zsh > ~/.zfunc/_loki
loki completions fish > ~/.config/fish/completions/loki.fish
```

## Element Roles

Common accessibility roles used with `--role`:

| Role | Description |
|------|-------------|
| `AXWindow` | Application window |
| `AXButton` | Clickable button |
| `AXTextField` | Text input field |
| `AXStaticText` | Text label |
| `AXScrollArea` | Scrollable container |
| `AXToolbar` | Toolbar |
| `AXMenuBar` | Menu bar |
| `AXMenuItem` | Menu item |
| `AXCheckBox` | Checkbox |
| `AXRadioButton` | Radio button |
| `AXPopUpButton` | Dropdown/popup |
| `AXSlider` | Slider control |
| `AXTabGroup` | Tab group |
| `AXTable` | Table view |
| `AXImage` | Image element |
| `AXGroup` | Generic container |
