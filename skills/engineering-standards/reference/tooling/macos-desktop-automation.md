# macOS Desktop Automation APIs
Last updated: 2026-03-22
Last researched: 2026-03-22
Sources: experience (Loki project — desktop QA automation CLI)

## Summary

Patterns for automating macOS desktop apps from Rust CLIs. Covers window discovery, accessibility tree inspection, input injection, and screenshot capture. Key lesson: CGEvent keyboard input is unreliable for cross-process use; System Events via osascript is the proven approach.

## Key Principles

- **Window discovery**: `CGWindowListCopyWindowInfo` returns all windows with IDs, PIDs, titles, bounds. Use `core-graphics` crate (0.25+). Window IDs are stable within a session.
- **Accessibility tree**: `AXUIElementCreateApplication(pid)` + `AXUIElementCopyAttributeValue` for tree walking. Requires Accessibility permission. Use raw FFI via `#[link(name = "ApplicationServices", kind = "framework")]` — high-level crates are insufficient.
- **Element labels are NOT always in `title`**: Many apps (Calculator, system dialogs) put labels in `description` or `identifier` fields, not `title`. Always check title → description → identifier as fallback chain.
- **Mouse input**: CGEvent mouse events (click at coordinates) work reliably regardless of focus — they're coordinate-based. Use `core-graphics` crate.
- **Keyboard input**: CGEvent keyboard injection (`CGEventPost` to HID) DOES NOT work reliably when the calling process (terminal) retains focus. Events get lost or go to the wrong app. `CGEventPostToPid` also fails for most apps that check focus state. **Use System Events via osascript instead**: `tell application "System Events" to keystroke "text"` and `key code N using {modifiers}`.
- **App activation**: Use `osascript -e 'tell application "System Events" to set frontmost of (first process whose unix id is PID) to true'` before sending keyboard input. Allow 100-200ms for activation to complete.
- **Bundle IDs are case-sensitive in some APIs**: `open -b` is case-insensitive, but `lsappinfo -app` is case-sensitive. Always implement case-insensitive fallback for bundle ID lookups.

## Practical Guidance

### Crate stack for Rust
- `core-graphics = { version = "0.25", features = ["elcapitan"] }` — CGEvent, CGWindowList, screenshots. The `elcapitan` feature enables `post_to_pid`.
- `core-foundation = "0.10"` — CFString, CFArray, CFDictionary for Obj-C bridging
- `image = "0.25"` (png feature) — CGImage BGRA→RGBA conversion + PNG encoding

### Screenshot approach
Use `CGWindowListCreateImage` with window ID — direct API, no subprocess, returns CGImage. Convert BGRA pixel data to RGBA before encoding as PNG.

### Accessibility permission
Call `AXIsProcessTrusted()` / `AXIsProcessTrustedWithOptions()` via FFI. Link against ApplicationServices framework. Map `kAXErrorAPIDisabled` to a permission-denied error with a helpful message directing users to System Settings > Privacy & Security > Accessibility.

### Architecture for cross-platform
Three-crate workspace: core (types + trait), platform impl (macos/windows/linux), CLI. The `DesktopDriver` trait abstracts all platform operations. CLI conditionally compiles the right backend.

## Related Topics
- [Rust CLI patterns](../architecture/rust-cli-patterns.md)
