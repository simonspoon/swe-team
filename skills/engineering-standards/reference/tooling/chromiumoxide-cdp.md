# Chromiumoxide CDP Library
Last updated: 2026-03-22
Last researched: 2026-03-22
Sources: experience (khora project), https://crates.io/crates/chromiumoxide

## Summary

chromiumoxide is the most actively maintained Rust crate for Chrome DevTools Protocol (CDP) automation. It provides async/tokio-native Browser and Page abstractions over WebSocket-based CDP communication. v0.9.1 (Feb 2026) is current, with 1.5M+ downloads.

## Key Principles

- **Async-only** — requires tokio with rt-multi-thread. The handler must be spawned as a background task (`tokio::spawn`) that pumps events from the browser.
- **Browser lifecycle** — `Browser::launch()` spawns Chrome, `Browser::connect()` attaches to existing. Both return `(Browser, Handler)`.
- **Page management** — `browser.new_page(url)` creates a tab and navigates. `browser.pages()` lists tracked pages. `page.evaluate(js)` runs JavaScript.

## Practical Guidance

### Reconnection pattern (CLI tools)

When building a CLI where each invocation reconnects to a running Chrome instance:

1. `Browser::connect(ws_url)` only tracks pages created AFTER the connection
2. **Must call `browser.fetch_targets().await`** after connect to discover existing tabs
3. Wait ~50ms after fetch_targets before using `pages()` — targets aren't immediately ready
4. Use `page.url().await` to identify the right tab (prefer non-blank, non-chrome:// pages)

### Navigation on reconnected sessions

- `page.goto(url)` may time out on reconnected pages due to event listener attachment issues
- **Use `browser.new_page(url)` instead** — creates a fresh tab at the target URL in one step
- This means each `navigate` creates a new tab; subsequent commands find it via URL matching

### Session persistence

For CLI tools where launch/navigate/kill are separate invocations:
- Save WebSocket URL to a file on `launch`
- Reconnect via `Browser::connect(ws_url)` on each command
- `std::mem::forget(client)` in launch to keep Chrome alive after the process exits
- Chrome continues running independently; the handler task is what keeps the connection alive

### Handler pattern

```rust
let (browser, mut handler) = Browser::launch(config).await?;
let handle = tokio::spawn(async move {
    while let Some(event) = handler.next().await {
        if event.is_err() { break; }
    }
});
```

### Element interaction via JavaScript

chromiumoxide's `Element` type is limited. For rich element info (bounding box, attributes, visibility), use `page.evaluate()` with JavaScript that returns structured JSON, then deserialize client-side.

### evaluate() type constraints

- Accepts `&str`, `String`, or `EvaluateParams` — NOT `&String`
- For String variables, pass `js.as_str()` or just `js` (moved)

## Crate Stack

| Purpose | Crate | Version |
|---------|-------|---------|
| CDP client | chromiumoxide | 0.9 |
| Async runtime | tokio | 1.x (rt-multi-thread) |
| Event stream | futures | 0.3 (StreamExt) |
| Chrome discovery | which | 8.x |

## Related Topics

- [Rust CLI Patterns](../architecture/rust-cli-patterns.md)
