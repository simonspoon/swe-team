# Tauri v2 + SolidJS Desktop Apps
Last updated: 2026-04-03
Last researched: 2026-03-20
Sources: crates.io, npm, tauri.app docs, GitHub releases

## Summary

Tauri v2 is a lightweight desktop app framework (Rust backend + web frontend). SolidJS is a first-class official template. The combination gives a fast, small binary with reactive UI.

## Current Versions

| Component | Version | Notes |
|-----------|---------|-------|
| tauri (core) | 2.10.3 | |
| tauri-cli | 2.10.0 | |
| create-tauri-app | 4.7.0 | |
| solid-js | 1.9.11 | Do NOT use 2.0-beta (released Mar 3, 2026) |

## Scaffold Command

```bash
pnpm create tauri-app my-app --template solid-ts
```

## Key Architecture Points

- **Frontend↔Backend IPC**: Use Tauri's native `invoke` — it's JSON-RPC-like, no extra deps needed
- **External process↔Tauri**: Embed an axum WebSocket server in the Tauri backend for external clients (e.g., CLI tools)
- **WebSocket server**: `axum 0.8` with `axum::extract::ws` — wraps tungstenite with stable API
- **WebSocket client**: `tokio-tungstenite 0.28.0` — pin to 0.28, 0.29 just shipped (Mar 17, 2026)
- **JSON-RPC**: `jsonrpsee 0.26` if you need full spec compliance; pin minor version (breaks on minor bumps). For simple cases, roll lightweight JSON-RPC over raw WS.

## Prerequisites (macOS)

- Xcode Command Line Tools
- Rust via rustup
- Node.js LTS
- pnpm

## Cargo Workspace with Tauri

Tauri's scaffold creates `src-tauri/` inside the frontend project. To use a Cargo workspace with shared crates:

1. Scaffold normally, then wrap in workspace
2. Root `Cargo.toml` declares workspace members including `app/src-tauri`
3. Shared crates (core, protocol) go in `crates/`
4. Both CLI and Tauri backend depend on shared crates via path deps

## Event System (Rust → Frontend)

- Import `tauri::Emitter` to use `emit()` on `AppHandle`
- `app.handle().clone()` gives an owned `AppHandle` that is `Clone + Send + Sync`
- `handle.emit("event-name", payload)?` — payload must be `Serialize + Clone`
- Frontend listens via `listen<T>("event-name", callback)` from `@tauri-apps/api/event`
- Frontend responds via `invoke()` (not `emit()`) — invoke gives typed return values
- Always call the `UnlistenFn` returned by `listen()` in `onCleanup()`

## Spawning Async Tasks (axum server, background work)

- **Prefer `tauri::async_runtime::spawn`** over `std::thread::spawn` + separate runtime
- Avoids "no reactor running" panics from mismatched tokio contexts
- Clone `AppHandle` in `setup()`, move into the spawned task
- For request/response patterns across tasks: use `tokio::sync::oneshot` channels stored in shared state

## Webview Lifecycle and State Persistence

- **`beforeunload` cannot await async work.** Calling `invoke()` from a `beforeunload` handler is fire-and-forget — the page unloads before the Rust side processes it. Do NOT rely on `beforeunload` as the sole save point.
- **Use debounced eager saves.** Save state to disk (via `invoke`) on every meaningful mutation (debounced ~2s). This keeps the persisted state fresh so it survives hard reloads, crashes, and `beforeunload` races.
- **Tauri's Rust process survives webview reloads.** `app.manage()` state is `'static` and app-scoped — it persists across webview destruction/recreation. Use this for data that must outlive the frontend (e.g., PTY sessions, background tasks).
- **`onCleanup` is not guaranteed on hard crash.** SolidJS `onCleanup` fires on graceful unmount but not on `kill -9` or webview crash. Design Rust-side cleanup (sweeps, TTLs) for resources that JS may fail to release.
- **tauri-plugin-pty read loop is JS-side.** The `readData()` loop in `tauri-pty`'s JS API is the sole PTY output consumer. If the webview dies, the loop dies. For reload-resilient terminals, move the read pump to a Rust-side thread with a scrollback buffer and use Tauri events for output streaming.

## DOM Capture (Screenshots)

- `html-to-image` 1.11.13 (npm) — `toPng(element, { pixelRatio })` returns base64 data URL
- WKWebView (macOS) may silently drop CSS background-images in SVG foreignObject
- Base64 PNG via IPC: strip `data:image/png;base64,` prefix, send via `invoke()`
- For large payloads (2-4MB), JSON serialization works but benchmark if latency matters

## CI/CD & Release

- **CI on Linux** requires system deps: `libwebkit2gtk-4.1-dev libappindicator3-dev librsvg2-dev patchelf`
- **macOS universal binary**: `--target universal-apple-darwin` (needs both `aarch64-apple-darwin` and `x86_64-apple-darwin` targets installed)
- **Use `tauri-apps/tauri-action@v0`** with `tagName: ${{ github.ref_name }}` — this uploads .dmg, .msi, .deb, .AppImage directly to the GitHub Release
- **Do NOT use artifact upload/download for Tauri bundles** — the bundle paths are deeply nested (`target/**/release/bundle/**/*.dmg`) and download-artifact with `merge-multiple` flattens incorrectly. Let tauri-action handle uploads directly.
- **App version in Cargo.toml should use `version.workspace = true`** to stay in sync with the workspace

## Related Topics

- [Rust CLI Patterns](../architecture/rust-cli-patterns.md)
