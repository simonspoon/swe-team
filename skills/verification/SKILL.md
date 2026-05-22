---
name: verification
description: Unified verification router that auto-detects project type (iOS, desktop, web) and routes to the appropriate QA skill (web-verify, desktop-verify, ios-verify). Use when the user asks to verify, test, or QA their application and the specific platform is not yet known, or when multiple platforms need verification.
triggers:
  - verify this application
  - QA the build
  - check my work on this app
  - run platform verification
---

# Verification

Route verification work to the right QA skill based on what the project actually is.
This is a router: it detects the platform and dispatches; the actual verification logic
lives in the platform skills.

## Activation Protocol

Engage this skill when a task needs QA and the platform is not yet fixed, or when more
than one platform must be verified. Before starting, have in hand the built artifact (or
the dev-server setup) and the project root.

## Workflow

1. **Detect the project type.** Scan the working directory for platform indicators
   (iOS, desktop, web) and resolve multi-platform frameworks. See
   `reference/platform-detection.md`.
2. **Check tool availability.** Confirm the QA tool for each detected platform is on
   PATH before routing. See `reference/platform-detection.md`.
3. **Route to the QA skill(s).** For each detected platform, invoke the matched skill's
   verification workflow:
   - iOS -> `ios-verify`
   - desktop -> `desktop-verify`
   - web -> `web-verify`

   A single-platform project loads exactly one verify skill. A multi-platform project
   (Tauri = web + desktop) loads the matched set — verify all detected platforms, do not
   pick one arbitrarily. If the user names a platform explicitly, skip detection and
   route directly.
4. **Produce the verification report.** After all platforms are verified, emit one
   combined report. See the report format in `reference/platform-detection.md`.

## Rules

- This skill is a router. It detects and dispatches. The actual verification logic lives
  in the platform skills (`web-verify`, `desktop-verify`, `ios-verify`).
- Always check tool availability before attempting to use a tool.
- Save all screenshots to `/tmp/verify-<platform>-<timestamp>.png` for consistency.
- **Always clean up after QA tools.** Orphaned processes block user workflows.

## Reference

- `reference/platform-detection.md` — the platform-detection indicators, the
  tool-availability checks, the per-platform routing detail, and the verification
  report format. Read it for steps 1, 2, 3, and 4.
