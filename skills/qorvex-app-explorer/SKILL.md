---
name: qorvex-app-explorer
description: Systematically explore and map an iOS application's UI using qorvex on a simulator or physical device. Produces screen hierarchy, user flows, feature listings, behavior references, and reusable automation scripts. Use when mapping an app, exploring app functionality, discovering screens, building a screen map, creating app documentation, reverse-engineering app UI, or generating qorvex automation scripts.
---

# App Explorer

Systematically explore an iOS app via qorvex to produce a complete functional map.

## Prerequisites

A qorvex session must be active with a target set. If not, set one up:

```bash
qorvex start                        # simulator (or: qorvex start -d <UDID> for physical)
qorvex set-target <BUNDLE_ID>
qorvex start-target                 # launch the app (simulator only)
```

Verify the session is live before exploring:

```bash
qorvex status
qorvex screenshot 2>/dev/null | base64 -d > /tmp/explorer_screen.png
```

Read the screenshot to confirm the app is visible.

## Exploration Protocol

Follow this protocol in order. Each phase builds on the previous.

### Phase 1: Initial Survey

1. Screenshot the launch screen and read it visually.
2. Run `qorvex screen-info` to get the full element tree.
3. Record the **screen name** (derive from nav bar title, header text, or prominent labels).
4. Record all **interactive elements** — buttons, links, tabs, text fields, switches, cells.
5. Record all **static content** — labels, images, section headers.
6. Note the **navigation structure** — tab bar, nav bar, sidebar, hamburger menu.

### Phase 2: Systematic Screen Discovery

Use a breadth-first strategy. Maintain a queue of unexplored navigation targets.

For each screen:

1. **Screenshot** and **screen-info** — capture visual + element tree.
2. **Identify exits** — every tappable element that could navigate to a new screen (buttons, cells, tab items, nav links, list rows).
3. **Tap each exit** one at a time:
   - Screenshot + screen-info the destination.
   - If it's a new screen, add it to the map and queue its exits.
   - Navigate back (tap back button, swipe right, or tap originating tab).
   - Confirm you returned to the expected screen via screenshot.
4. **Handle modals/sheets** — if a tap presents a modal or action sheet, record it as a child of the current screen, dismiss it, then continue.
5. **Scroll for more content** — `qorvex swipe up` to reveal content below the fold. Re-run screen-info after scrolling. Repeat until no new elements appear.

**Navigation patterns to try:**
- Tab bar items (bottom tabs)
- Navigation bar buttons (left/right)
- List/table cells
- Buttons and links in content
- Long-press — not natively supported by qorvex; skip unless future versions add it
- Swipe gestures (left on cells for actions, pull-to-refresh)
- Settings/gear icons
- Profile/avatar taps

### Phase 3: Interaction Testing

For each screen with input elements:

1. **Text fields** — tap the field, use `send-keys` to enter sample text, observe validation or changes. Dismiss keyboard with `swipe down`.
2. **Switches/toggles** — record current state with `get-value`, tap to toggle, record new state.
3. **Pickers/dropdowns** — tap to open, screenshot options, select one, observe changes.
4. **Buttons** — tap non-destructive buttons, observe what happens (navigation, alerts, state changes).
5. **Search bars** — enter search terms, observe results filtering.
6. **Pull-to-refresh** — `qorvex swipe down` from top of scrollable content.

Record the **behavior** of each interaction: what changed on screen, what navigation occurred, what feedback appeared.

### Phase 4: Flow Identification

From the screen map and interactions, identify end-to-end user flows:

- **Onboarding/first-run** — if applicable, uninstall and reinstall to capture.
- **Authentication** — login, signup, password reset, logout.
- **Primary task flows** — the main things the app lets users do (e.g., create a post, place an order, send a message).
- **Settings/configuration** — preferences, account management, notifications.
- **Error states** — what happens with no network, invalid input, empty states.

### Phase 5: Output Generation

Produce all output artifacts in a single directory. Default: `/tmp/app-explorer/<bundle-id>/`.

```bash
OUTPUT_DIR="/tmp/app-explorer/<bundle-id>"
mkdir -p "$OUTPUT_DIR/screenshots" "$OUTPUT_DIR/scripts"
```

If the directory already exists from a previous run, overwrite its contents (the exploration produces a fresh map).

## Output Artifacts

Generate these files in the output directory. See [OUTPUT-FORMAT.md](OUTPUT-FORMAT.md) for templates.

| File | Contents |
|------|----------|
| `screen-hierarchy.md` | Tree of all screens with parent-child navigation relationships |
| `user-flows.md` | Step-by-step flows for key user journeys |
| `features.md` | Categorized feature listing with screen locations |
| `behaviors.md` | Element interaction behaviors — what each control does |
| `scripts/` | Reusable qorvex automation scripts (bash) for each flow — see Script Generation below |
| `screenshots/` | Named screenshots for each discovered screen |

## Script Generation

Prefer generating scripts from the qorvex action log rather than writing them by hand.

**Important:** `qorvex log` outputs human-readable text. `qorvex convert` requires JSONL (one JSON object per line). Use `qorvex -f json log` to get JSON, then convert the JSON array to JSONL:

```bash
# Dump the session log as JSONL (convert JSON array to one-object-per-line)
qorvex -f json log | python3 -c "import sys,json; [print(json.dumps(e)) for e in json.load(sys.stdin)]" > "$OUTPUT_DIR/session-log.jsonl"

# Convert the full log to a replayable shell script
qorvex convert "$OUTPUT_DIR/session-log.jsonl" > "$OUTPUT_DIR/scripts/full-session.sh"
```

To create per-flow scripts, use `qorvex comment` to mark flow boundaries during exploration:

```bash
qorvex comment "BEGIN: login flow"
# ... exploration actions for login ...
qorvex comment "END: login flow"
```

Then extract the relevant JSONL lines between the comment markers and convert each segment individually. Hand-edit the generated scripts to add `wait-for` calls and remove exploratory dead ends.

## Rules

1. **Always screenshot before and after** navigation or interaction. Visual confirmation prevents false mapping.
2. **Use `-l` (label) for taps** unless you have a known accessibility ID from screen-info.
3. **Dismiss keyboard** with `swipe down` after any text input before tapping other elements.
4. **Wait after navigation** — use `wait-for` on an expected element of the destination screen before running screen-info.
5. **Don't tap destructive actions** — skip "Delete Account", "Sign Out" (unless specifically asked), or anything that could lose state. Record them as available but untested.
6. **Handle dead ends** — if a tap leads nowhere or errors, record it and move on. Don't get stuck.
7. **Name screens consistently** — use the nav bar title or most prominent heading. If none, use a descriptive name like "Settings > Notifications".
8. **Track visited screens** — maintain a set of visited screen signatures (title + key elements) to detect cycles.
9. **Base64 decode screenshots** — always pipe through `base64 -d`: `qorvex screenshot 2>/dev/null | base64 -d > /tmp/file.png`
10. **Launch target app before screen-info** — screen-info is very slow on SpringBoard.

## Exploration Strategies

See [EXPLORATION.md](EXPLORATION.md) for detailed strategies for complex apps.
