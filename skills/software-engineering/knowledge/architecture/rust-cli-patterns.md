# Rust CLI Architecture Patterns
Last updated: 2026-03-15
Sources: experience (dante project — Kraken trading CLI)

## Summary

Patterns for structuring Rust CLI applications that make one request per invocation, such as API wrappers and developer tools. Favors simplicity: blocking HTTP, untyped responses for external APIs, and clear module separation.

## Key Principles

- **Blocking over async for CLIs** — A CLI that makes 1-2 HTTP calls per run gains nothing from async. Avoiding tokio eliminates a dependency and removes `async`/`.await` from every function signature.
- **Untyped returns for external API wrappers** — Return `serde_json::Value` instead of modeling every response struct. External APIs evolve independently; typed structs create brittleness. Add typed structs per-endpoint only when specific field access is needed.
- **Separate auth from HTTP** — Keep signing/auth logic in its own module with a pure function signature (`fn sign(secret, path, nonce, data) -> Result<String>`). This makes it unit-testable against known test vectors.
- **Global output mode flag** — Use clap's `global = true` for flags like `--json` so they work regardless of subcommand position.

## Practical Guidance

### Module structure

| Module | Responsibility |
|--------|---------------|
| `cli.rs` | clap derive definitions (Parser + Subcommand) |
| `client.rs` | HTTP client struct with methods per API endpoint |
| `auth.rs` | Request signing / credential handling |
| `models.rs` | Request parameter types, enums used as CLI args |
| `output.rs` | Human-readable vs JSON formatting, dispatches on command name |
| `error.rs` | Unified error enum via thiserror |
| `main.rs` | Parse args, dispatch to client, format output |

### Error handling pattern

```rust
// Unified enum with thiserror
#[derive(Debug, Error)]
pub enum AppError {
    #[error("HTTP error: {0}")]
    Http(#[from] reqwest::Error),
    #[error("API error: {}", messages.join(", "))]
    Api { code: String, messages: Vec<String> },
    #[error("Auth error: {0}")]
    Auth(String),
    #[error("Serialization error: {0}")]
    Serialization(#[from] serde_json::Error),
}

// main.rs: propagate with ?, format at top level
fn main() {
    let cli = Cli::parse();
    match run(&cli) {
        Ok(val) => output::print_result(&val, cli.json, cmd_name(&cli.command)),
        Err(err) => { output::print_error(&err, cli.json); std::process::exit(1); }
    }
}
```

### When to use typed response structs

- Start with `serde_json::Value` for all responses
- Add typed structs only when human-readable formatting needs specific fields
- Never model the full API response — only the fields you access

### Recommended crate stack

| Purpose | Crate | Version | Notes |
|---------|-------|---------|-------|
| CLI parsing | `clap` (derive) | 4.x | Use `ValueEnum` for enums as positional args |
| HTTP | `reqwest` (blocking) | 0.13.x | `query` feature is opt-in since 0.13. Only use async if the CLI does parallel requests |
| Serialization | `serde` + `serde_json` | 1.x | |
| Errors | `thiserror` | 2.x | |
| Crypto signing | `hmac`, `sha2`, `base64` | 0.12/0.10/0.22 | If the API needs request signing |

> For current version details and upgrade guidance, see [Rust Dependency Management](../tooling/rust-dependency-management.md)

### Feature-gated optional subsystems

When adding a heavy optional subsystem (e.g., an embedded HTTP server) to a CLI:

- Gate the module with `#[cfg(feature = "...")]` on the `mod` declaration in main.rs
- Gate enum variants that reference the feature's types with the same `#[cfg(feature = "...")]`
- Declare heavy deps as `optional = true` and use `dep:` syntax in the feature list:
  ```toml
  [features]
  paper = ["dep:axum", "dep:tokio", "dep:uuid"]

  [dependencies]
  axum = { version = "0.8", optional = true }
  ```
- This keeps the base binary lean — users who don't need the feature don't pay for the compile time or binary size

### Transparent backend routing via constructors

When adding an alternate backend (e.g., paper trading server alongside real API):

- Add a new constructor to the client struct (`paper(url)`) alongside existing ones (`public()`, `authenticated()`)
- Create a single routing helper that checks the env var and returns the right client:
  ```rust
  fn private_client() -> Result<Client, Error> {
      match env::var("ALTERNATE_URL") {
          Ok(url) => Ok(Client::paper(&url)),
          Err(_) => Client::authenticated(),
      }
  }
  ```
- Replace all direct `Client::authenticated()` calls with the helper
- No output formatters, CLI parsing, or other code needs to change — the alternate backend returns compatible response shapes

### Mixing blocking reqwest with async axum

When an axum handler needs to call `reqwest::blocking`:

- Use `tokio::task::spawn_blocking` to avoid blocking the async runtime
- The blocking client does the HTTP call inside the spawned task
- Handle the `JoinError` from `spawn_blocking` gracefully (return error response, don't unwrap)

### Testing strategy

- **Unit test auth signing** against known test vectors — this is the most critical test
- **Manual smoke tests** for public endpoints (no credentials needed)
- **Private endpoint tests** require real API credentials via env vars
- Use inline `#[cfg(test)]` modules, not separate test files, for unit tests

## Related Topics

- [Rust Dependency Management](../tooling/rust-dependency-management.md)
- [Rust Testing Strategies](../testing/rust-testing-strategies.md)
