---
name: test-engineer
description: >
  Test engineering expert. ALWAYS invoke this skill when writing, generating, running,
  or analyzing tests. Do NOT write test files or run test suites directly — use this skill.
  Triggers: write tests, generate tests, run tests, test coverage, unit tests, integration
  tests, e2e tests, pytest, vitest, jest, cargo test, check test quality.
---

# Test Engineer

Generate, run, and analyze tests across languages and frameworks. Covers unit, integration, and end-to-end testing with coverage analysis and gap detection.

## Prerequisites

- Project must have a test framework configured (or you will set one up).
- For coverage: framework-specific coverage tooling installed.

## Activation Protocol

1. Detect the project language and test framework (see "Framework Detection" below).
2. Read `reference/frameworks.md` for framework-specific commands and patterns.
3. Determine the task type (see "What Do You Need?" below).
4. Execute the appropriate workflow.

## Framework Detection

Run these checks to identify the test setup:

```bash
# Python
test -f pyproject.toml && grep -q "pytest" pyproject.toml && echo "pytest"
test -f setup.cfg && grep -q "pytest" setup.cfg && echo "pytest"

# JavaScript/TypeScript
test -f package.json && grep -q "vitest" package.json && echo "vitest"
test -f package.json && grep -q "jest" package.json && echo "jest"

# Rust
test -f Cargo.toml && echo "cargo test"

# Go
test -f go.mod && echo "go test"
```

If no framework found, detect the project language by file extensions (`.py` = Python, `.ts`/`.js` = JS/TS, `.rs` = Rust, `.go` = Go) and recommend:
- **Python** → pytest (add to pyproject.toml `[dependency-groups] dev = ["pytest"]`)
- **JavaScript/TypeScript** → vitest (add to package.json devDependencies)
- **Rust** → cargo test (built-in, no setup needed)
- **Go** → go test (built-in, no setup needed)

If multiple frameworks are detected (e.g., monorepo with Python + JS), handle each independently — detect, generate, and run tests for each framework separately.

## What Do You Need?

**Generate tests for existing code:**
1. Read the source file(s) to understand behavior.
2. Identify public API, edge cases, error paths.
3. Generate tests following project conventions.
4. Run the tests to verify they pass.

**Run existing tests:**
1. Detect framework.
2. Run the appropriate command (see reference/frameworks.md).
3. Parse and report results in this format:
   ```
   ## Test Results
   - **Framework**: [detected framework]
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
2. Check for each item in the Test Quality Checklist below.
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

## Test Generation Workflow

### Step 1: Analyze the Code

Read the target file. Extract:
- Public functions/methods and their signatures
- Input types, return types, side effects
- Error conditions and edge cases
- Dependencies that need mocking

### Step 2: Plan Test Cases

For each public function, plan:
- **Happy path**: Normal inputs produce expected outputs.
- **Edge cases**: Empty inputs, zero values, boundary values, max/min.
- **Error cases**: Invalid inputs, missing data, failed dependencies.
- **Integration points**: Interactions with other components.

### Step 3: Write Tests

**Check the target Python version before using modern syntax.** If the project's pyproject.toml, setup.cfg, or CI config specifies Python 3.8 or 3.9, avoid 3.10+ features like `match` statements and `X | Y` union types — use `Union[X, Y]` and `if/elif` instead.

Follow the project's existing test style. If no existing tests, use these conventions:

- One test file per source file.
- Test file naming: `test_<module>.py` (Python), `<module>.test.ts` (JS/TS), inline `#[cfg(test)]` (Rust).
- Use descriptive test names that state the scenario and expected outcome.
- Arrange-Act-Assert pattern.
- Minimize mocking -- prefer real dependencies when fast and deterministic.

### Step 4: Verify

Run the generated tests. All must pass before delivering.

**IMPORTANT: Always use the project's package manager to run tests.** This ensures the correct Python/Node version and dependencies are available. Do NOT use bare `python -m pytest` -- use `uv run pytest` for Python projects.

```bash
# Detect and run using the appropriate framework
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

### Step 1: Run Coverage

See reference/frameworks.md for per-framework commands. Note: for pytest coverage, `--cov=<path>` should point to the source directory (e.g., `--cov=src` if source is in `src/`, or `--cov=mypackage` if the package is at the project root).

### Step 2: Parse Results

Extract:
- Overall coverage percentage
- Per-file coverage
- Uncovered lines (file:line format)
- Uncovered branches

### Step 3: Report

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

## Test Quality Checklist

When auditing or writing tests, verify:

1. **Assertions are specific** — not just "no error thrown."
2. **Tests are independent** — no shared mutable state, no ordering dependency.
3. **Mocks are minimal** — only mock what you must (network, filesystem, time).
4. **Edge cases covered** — empty, null/None, zero, negative, boundary, unicode.
5. **Error paths tested** — invalid input, timeouts, permission denied.
6. **No test pollution** — cleanup after tests that create files/state.
7. **Deterministic** — no flaky tests from timing, randomness, or external services.
8. **Fast** — unit tests complete in seconds, not minutes.

## Reference

- **Framework commands and patterns** — Read reference/frameworks.md
