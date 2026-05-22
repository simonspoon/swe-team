# Test Framework Detection

## Purpose

The commands that identify a project's test framework and the recommend-a-framework
fallback when none is configured. Loaded by the `test-strategy` SKILL.md "Detect the
framework" workflow step.

## Content

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

If no framework found, detect the project language by file extensions (`.py` = Python,
`.ts`/`.js` = JS/TS, `.rs` = Rust, `.go` = Go) and recommend:

- **Python** → pytest (add to pyproject.toml `[dependency-groups] dev = ["pytest"]`)
- **JavaScript/TypeScript** → vitest (add to package.json devDependencies)
- **Rust** → cargo test (built-in, no setup needed)
- **Go** → go test (built-in, no setup needed)

If multiple frameworks are detected (e.g., monorepo with Python + JS), handle each
independently — plan a separate strategy for each framework.
