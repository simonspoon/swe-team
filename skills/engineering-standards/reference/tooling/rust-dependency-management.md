# Rust Dependency Management
Last updated: 2026-03-15
Last researched: 2026-03-15
Sources: https://crates.io, https://releases.rs/

## Summary

Guidance for auditing and updating Rust project dependencies. Covers semver behavior for pre-1.0 crates, current stable versions of commonly used crates, and the workflow for safe upgrades.

## Current Stable Versions (as of 2026-03-15)

| Crate | Latest Stable | Notes |
|-------|--------------|-------|
| reqwest | 0.13.2 | `query` and `form` are now opt-in features (not default). Add to `features = [...]` |
| clap | 4.x | Stable, derive macro is the standard approach |
| serde | 1.x | Stable, no breaking changes expected |
| serde_json | 1.x | Stable |
| thiserror | 2.x | Major bump from 1.x was mostly internal; derive macro API unchanged |
| hmac | 0.12.x | Stable within RustCrypto ecosystem |
| sha2 | 0.10.x | Stable within RustCrypto ecosystem |
| base64 | 0.22.x | Stable |
| tokio | 1.x | Stable |
| wiremock | 0.6.x | Stable |
| assert_cmd | 2.x | Stable |
| proptest | 1.x | Stable, passively maintained |

## Key Principles

- **Pre-1.0 semver**: Minor version bumps (0.12 → 0.13) ARE breaking changes. Always check changelogs before bumping.
- **Post-1.0 semver**: Minor bumps are backwards-compatible. Patch bumps are bug fixes.
- **Cargo version specs**: `"0.13"` resolves to `>=0.13.0, <0.14.0`. `"1"` resolves to `>=1.0.0, <2.0.0`.
- **`cargo update`** only updates within the version spec in Cargo.toml. To cross a breaking boundary, edit Cargo.toml first.

## Upgrade Workflow

1. Run `cargo outdated` (install via `cargo install cargo-outdated`) to see what's behind
2. Check changelogs for any crate crossing a pre-1.0 minor or post-1.0 major boundary
3. Update Cargo.toml version specs
4. Run `cargo update` to regenerate Cargo.lock
5. Run `cargo build` to catch compile errors
6. Run `cargo test` to verify behavior
7. Review any new deprecation warnings

## Common Breaking Change Patterns

- **Feature flags becoming opt-in** (e.g., reqwest 0.13 `query` feature) — build succeeds but runtime fails or methods missing
- **TLS backend changes** — reqwest moved from native-tls to rustls by default in 0.13
- **Type signature changes** — return types or trait bounds changing
- **Renamed methods** — old names often soft-deprecated first, then removed

## Rust Toolchain

| Component | Latest Stable | Last checked |
|-----------|--------------|-------------|
| rustc | 1.94.0 | 2026-03-15 |

- Edition 2024 requires rustc 1.85+
- Homebrew Rust often lags; prefer `rustup` for timely updates

## Related Topics

- [Rust CLI Patterns](../architecture/rust-cli-patterns.md)
