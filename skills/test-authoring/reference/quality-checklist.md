# Test Quality Checklist

## Purpose

The checklist applied when writing tests or running a test-quality audit. Loaded by
the `test-authoring` SKILL.md "What Do You Need?" audit mode and the "Write the Tests"
workflow step.

## Content

When auditing or writing tests, verify:

1. **Assertions are specific** — not just "no error thrown."
2. **Tests are independent** — no shared mutable state, no ordering dependency.
3. **Mocks are minimal** — only mock what you must (network, filesystem, time).
4. **Edge cases covered** — empty, null/None, zero, negative, boundary, unicode.
5. **Error paths tested** — invalid input, timeouts, permission denied.
6. **No test pollution** — cleanup after tests that create files/state.
7. **Deterministic** — no flaky tests from timing, randomness, or external services.
8. **Fast** — unit tests complete in seconds, not minutes.
