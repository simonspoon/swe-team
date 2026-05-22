# Rust Testing Strategies (2025-2026)
Last updated: 2026-03-14
Sources: https://nexte.st/, https://mutants.rs/, https://lib.rs/crates/proptest, https://rust-cli.github.io/book/tutorial/testing.html, https://alexwlchan.net/2025/testing-rust-cli-apps-with-assert-cmd/

## Summary

The Rust testing ecosystem has matured around a few key tools beyond `#[test]`: nextest for faster/smarter test execution, proptest for property-based testing, cargo-mutants for mutation testing, and assert_cmd for CLI integration tests. The community favors a pragmatic testing pyramid — strong unit tests on core logic, property tests on invariants, and lightweight integration tests for CLI/IO boundaries.

## Key Tools

### cargo-nextest
- Drop-in replacement for `cargo test` with parallel execution, retries, slow-test detection
- Expression language for filtering tests by name/binary/platform
- JUnit XML export for CI integration
- Install: `cargo install cargo-nextest`

### proptest
- Property-based testing (inspired by Python's Hypothesis)
- Generates arbitrary inputs and finds minimal failing cases
- Best for: pure functions with invariants (e.g., "signing then verifying always succeeds")
- Passive maintenance but feature-complete

### cargo-mutants
- Mutation testing: replaces function bodies and checks if tests catch it
- Surfaces untested logic — "which functions could be deleted without a test failing?"
- Works with both `cargo test` and nextest
- Install: `cargo install cargo-mutants`

### assert_cmd + predicates
- Black-box integration testing for CLI binaries
- Finds the compiled binary, runs it with args, asserts on stdout/stderr/exit code
- Best practice: keep tests flat and readable, avoid wrapper abstractions
- Pair with `predicates` crate for expressive assertions

### trycmd
- File-driven CLI testing — test cases in `.toml`/`.md` files
- Good for snapshot-style testing of CLI output
- Lower maintenance than hand-written assert_cmd tests for large CLIs

## Testing Pyramid for CLI Projects

1. **Unit tests** (`#[cfg(test)]` inline) — core logic: auth, parsing, validation
2. **Property tests** (proptest) — invariants on pure functions
3. **Integration tests** (`tests/` dir, assert_cmd) — end-to-end CLI behavior
4. **Mutation testing** (cargo-mutants) — periodic audit of test quality

## Practical Guidance

- Start with unit tests on the most critical/complex logic
- Add assert_cmd integration tests for happy-path CLI invocations
- Use proptest when functions have clear invariants (encode/decode, serialize/deserialize roundtrips)
- Run cargo-mutants periodically (not in CI — it's slow) to find gaps
- Use nextest in CI for speed and better output
- Aim for readable tests over DRY tests — repetition in tests is fine

## Related Topics
- [Rust CLI Patterns](../architecture/rust-cli-patterns.md)
