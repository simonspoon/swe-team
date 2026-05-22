---
name: test-authoring
description: >
  Test authoring expert. ALWAYS invoke this skill when writing, generating, running,
  or analyzing tests. Do NOT write test files or run test suites directly — use this skill.
  Triggers: write tests, generate tests, run tests, test coverage, unit tests, integration
  tests, e2e tests, pytest, vitest, jest, cargo test, check test quality.
triggers:
  - write the tests for this code
  - generate unit tests
  - run the existing test suite
  - analyze test coverage
  - audit test quality
---

# Test Authoring

Write, run, and analyze tests once the test strategy is decided. Covers test
generation, suite execution, coverage analysis, and quality auditing across
languages and frameworks.

## Activation Protocol

Engage this skill when a task needs tests written, an existing suite run, coverage
analyzed, or test quality audited. Before starting, have in hand the test strategy —
which framework is in use and which cases must be covered. Choosing the framework
and planning the test cases belong to the `test-strategy` skill; this skill takes
that strategy as input and produces the actual tests.

Steps:

1. Confirm the framework and target cases from the test strategy (or the `test-strategy`
   skill output).
2. Read `reference/frameworks.md` for the framework-specific commands and patterns.
3. Determine the operational mode (see "What Do You Need?" below).
4. Execute the appropriate workflow.

## What Do You Need?

**Generate tests for existing code:**
1. Read the source file(s) to understand behavior.
2. Identify public API, edge cases, error paths.
3. Generate tests following project conventions.
4. Run the tests to verify they pass.

**Run existing tests:**
1. Confirm the framework from the test strategy.
2. Run the appropriate command (see reference/frameworks.md).
3. Parse and report results in this format:
   ```
   ## Test Results
   - **Framework**: [framework in use]
   - **Total**: X tests | **Passed**: X | **Failed**: X | **Skipped**: X
   - **Duration**: Xs
   ### Failures (if any)
   - `test_name` — [reason for failure]
   ```

**Analyze coverage:**
1. Run tests with coverage enabled.
2. Identify uncovered lines and branches.
3. Report gaps with specific file:line references.
4. Suggest tests for uncovered paths.

**Audit test quality:**
1. Read existing tests.
2. Check for each item in the Test Quality Checklist (reference/quality-checklist.md).
3. Report findings in this format:
   ```
   ## Test Quality Audit
   | Check | Status | Notes |
   |-------|--------|-------|
   | Specific assertions | PASS/WARN/FAIL | [details] |
   | Test independence | ... | ... |
   ...
   ### Improvements
   1. [Specific suggestion with file:line reference]
   ```

## Write Tests Workflow

### Analyze the Code

Read the target file. Extract:
- Public functions/methods and their signatures
- Input types, return types, side effects
- Error conditions and edge cases
- Dependencies that need mocking

### Write the Tests

**Check the target Python version before using modern syntax.** If the project's pyproject.toml, setup.cfg, or CI config specifies Python 3.8 or 3.9, avoid 3.10+ features like `match` statements and `X | Y` union types — use `Union[X, Y]` and `if/elif` instead.

Follow the project's existing test style. If no existing tests, use these conventions:

- One test file per source file.
- Test file naming: `test_<module>.py` (Python), `<module>.test.ts` (JS/TS), inline `#[cfg(test)]` (Rust).
- Use descriptive test names that state the scenario and expected outcome.
- Arrange-Act-Assert pattern.
- Minimize mocking -- prefer real dependencies when fast and deterministic.

### Verify

Run the generated tests. All must pass before delivering.

**IMPORTANT: Always use the project's package manager to run tests.** This ensures the correct Python/Node version and dependencies are available. Do NOT use bare `python -m pytest` -- use `uv run pytest` for Python projects.

```bash
# Run using the framework named in the test strategy
uv run pytest tests/          # Python (ALWAYS use uv run, not bare python/pytest)
pnpm vitest run                # JS/TS (vitest)
pnpm jest                      # JS/TS (jest)
cargo test                     # Rust
go test ./...                  # Go
```

If any test fails, diagnose and fix it. Common causes:
- Import path wrong (check project structure)
- Missing fixture or setup (add to test file)
- Incorrect assertion (re-read source behavior)
- Missing dependency (install it, don't skip the test)

## Coverage Analysis Workflow

### Run Coverage

See reference/frameworks.md for per-framework commands. Note: for pytest coverage, `--cov=<path>` should point to the source directory (e.g., `--cov=src` if source is in `src/`, or `--cov=mypackage` if the package is at the project root).

### Parse Results

Extract:
- Overall coverage percentage
- Per-file coverage
- Uncovered lines (file:line format)
- Uncovered branches

### Report

```
## Coverage Report

**Overall: XX%**

### Gaps (files below threshold)
| File | Coverage | Uncovered Lines |
|------|----------|-----------------|
| src/auth.py | 45% | 23-31, 45-52 |

### Suggested Tests
1. [file:line] — Test [scenario] to cover [uncovered path].
2. ...
```

## Reference

- **Framework commands and patterns** — Read reference/frameworks.md for the per-language
  run and coverage commands and the test file patterns.
- **Test quality checklist** — Read reference/quality-checklist.md when writing tests or
  running a quality audit.
