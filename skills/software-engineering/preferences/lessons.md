# Lessons Learned

<!-- Entry format:
## [Lesson Title]
Recorded: [date]
Context: [what happened]
Lesson: [what was learned]
Impact: [how this should influence future decisions]
-->

## Prefer stdlib over heavyweight deps for simple operations
Recorded: 2026-03-15
Context: Used `chrono` crate just for `Utc::now().timestamp_millis()` in the paper trading server. Code review caught that `std::time::SystemTime` already does the same thing — and the codebase already had this pattern in `auth::nonce()`.
Lesson: Before adding a dependency, check if stdlib or an existing crate in the project already provides the needed functionality. Heavyweight crates for trivial operations add compile time and dependency surface for no benefit.
Impact: When generating timestamps, durations, or simple time math, default to `std::time`. Only reach for chrono when doing calendar arithmetic, timezone conversions, or formatted date strings.

## Mutex poison recovery in long-running services
Recorded: 2026-03-15
Context: Paper trading server used `.lock().unwrap()` on a `Mutex<PaperState>`. If any handler panicked while holding the lock, the mutex would poison and all subsequent requests would panic — bricking the server.
Lesson: In server contexts where a poisoned mutex shouldn't kill the process, use `.lock().unwrap_or_else(|e| e.into_inner())` to recover the inner data. Similarly, handle `JoinError` from `spawn_blocking` gracefully instead of unwrapping.
Impact: For any shared mutable state behind a Mutex in a server, default to poison recovery. Only use bare `.unwrap()` on mutex locks in short-lived CLI contexts where a panic is acceptable.
