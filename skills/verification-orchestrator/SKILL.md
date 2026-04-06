---
name: verification-orchestrator
description: Unified verification pipeline that auto-detects project type (iOS, desktop, web) and routes to the appropriate QA tool (qorvex, loki, khora). Use when the user asks to verify, test, or QA their application and the specific platform is not yet known, or when multiple platforms need verification.
---

# Verification Orchestrator

Route verification work to the right QA tool based on what the project actually is.

## Step 1: Detect Project Type

Scan the current working directory and up to 3 levels deep for platform indicators. Common project layouts nest platform files (e.g., `app/src-tauri/tauri.conf.json` for Tauri, `app/vite.config.ts` for web frontends).

### iOS Indicators
Look for ANY of:
- `*.xcodeproj` or `*.xcworkspace` directories
- `Info.plist` in the project root or a subdirectory
- `Package.swift` containing `iOS`, `.iOS`, or `iphoneos`
- `Podfile` or `Cartfile`
- Directories named `*.app` inside a build folder with `Info.plist` containing `LSRequiresIPhoneOS`

If detected: **platform = ios**

### Desktop (macOS) Indicators
Look for ANY of:
- `tauri.conf.json` or `tauri.conf.json5` (Tauri app -- also implies web)
- `electron-builder.yml`, `electron-builder.json`, or `electron.vite.config.*` (Electron -- also implies web)
- `*.app` bundle in build output (e.g., `target/release/bundle/macos/*.app`, `dist/*.app`)
- `Package.swift` without iOS indicators (pure macOS Swift app)
- `*.xcodeproj` with macOS deployment target and no iOS target
- `Cargo.toml` with dependencies on `cocoa`, `objc`, `winit`, `tao`, or `wry`

If detected: **platform = desktop**

### Web Indicators
Look for ANY of:
- `index.html` in root or `public/` or `src/`
- `package.json` with dependencies matching: `react`, `vue`, `svelte`, `next`, `nuxt`, `angular`, `vite`, `webpack`, `astro`, `remix`, `solid`
- `vite.config.*`, `webpack.config.*`, `next.config.*`, `nuxt.config.*`, `svelte.config.*`, `astro.config.*`
- `tsconfig.json` with `"jsx"` or `"dom"` in compiler options
- `dist/` or `build/` containing `.html` files

If detected: **platform = web**

### Multi-Platform Detection

Some frameworks span multiple platforms:
- **Tauri**: desktop + web (verify both)
- **Electron**: desktop + web (verify both)
- **Capacitor/Ionic**: web + ios (verify both)
- **React Native**: ios (use qorvex for simulator/device testing)

When multiple platforms are detected, verify ALL of them.

### Detection Failed

If no platform indicators are found:
1. Tell the user: "Could not auto-detect project type from directory contents."
2. List the three options: iOS (qorvex), Desktop (loki), Web (khora)
3. Ask which platform(s) to verify
4. Do NOT guess or proceed without confirmation

## Step 2: Check Tool Availability

Before routing, verify the required tool is installed.

```bash
# For iOS
command -v qorvex

# For desktop
command -v loki

# For web
command -v khora
```

If a required tool is missing, report clearly:

| Platform | Tool |
|----------|------|
| iOS | `qorvex` must be installed and on PATH |
| Desktop | `loki` must be installed and on PATH |
| Web | `khora` must be installed and on PATH |

Do NOT proceed with a platform whose tool is missing. If other platforms were also detected and their tools ARE available, proceed with those and note the gap.

## Step 3: Route to QA Skill(s)

For each detected platform, invoke the corresponding skill's verification workflow.

### iOS -> qorvex-test-ios

Follow the qorvex verification workflow:
1. `qorvex start` (simulator) or `qorvex start -d <UDID>` (physical device)
2. `qorvex set-target <BUNDLE_ID>` -- determine bundle ID from project files
3. Screenshot, inspect, interact, verify per the qorvex skill

### Desktop -> loki-test-desktop

Follow the loki verification workflow:
1. `loki check-permission` -- ensure accessibility access
2. Launch the app if not running, find the window
3. Screenshot, inspect tree, interact, verify per the loki skill

### Web -> khora-test-web

Follow the khora verification workflow:
1. Determine the local dev server URL (check `package.json` scripts, running processes)
2. Start a dev server if needed
3. `khora launch`, navigate, screenshot, inspect, verify per the khora skill
4. **Always `khora kill "$SESSION"` when done** — orphaned Chrome blocks the user's browser
5. Verify cleanup: `khora status` should show no active sessions

## Step 4: Produce Verification Report

After all platforms are verified, produce a single report in this format:

```
## Verification Report

**Project:** <project name or directory>
**Platforms detected:** <ios, desktop, web>
**Date:** <current date>

### iOS (qorvex)
- **Status:** PASS | FAIL | SKIPPED (tool not installed)
- **App:** <bundle ID>
- **Target:** Simulator | Device (<device name>)
- **Checks performed:**
  - <what was verified>
- **Issues found:**
  - <any issues, or "None">
- **Screenshots:** <paths to saved screenshots>

### Desktop (loki)
- **Status:** PASS | FAIL | SKIPPED (tool not installed)
- **App:** <bundle ID or app name>
- **Checks performed:**
  - <what was verified>
- **Issues found:**
  - <any issues, or "None">
- **Screenshots:** <paths to saved screenshots>

### Web (khora)
- **Status:** PASS | FAIL | SKIPPED (tool not installed)
- **URL:** <tested URL>
- **Checks performed:**
  - <what was verified>
- **Issues found:**
  - <any issues, or "None">
- **Screenshots:** <paths to saved screenshots>

### Summary
- **Platforms verified:** <count>/<total detected>
- **Overall:** PASS | FAIL | PARTIAL (some platforms skipped)
```

Only include sections for platforms that were detected. Do not include sections for platforms that were not relevant to the project.

## Rules

- This skill is a router. It detects and dispatches. The actual verification logic lives in the individual QA skills (qorvex-test-ios, loki-test-desktop, khora-test-web).
- Always check tool availability before attempting to use a tool.
- When multiple platforms are detected, verify all of them -- do not pick one arbitrarily.
- Save all screenshots to `/tmp/verify-<platform>-<timestamp>.png` for consistency.
- If the user specifies a platform explicitly (e.g., "verify the web app"), skip detection and route directly.
- **Always clean up after QA tools.** After khora: `khora kill` + verify with `khora status`. After qorvex/loki: close any sessions opened. Orphaned processes block user workflows.
