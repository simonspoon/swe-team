---
name: test-strategy
description: >
  Test strategy expert. ALWAYS invoke this skill when deciding what to test and which
  framework to use, before any test is written. Produces a concrete test strategy with
  real, runnable commands. Triggers: test strategy, what to test, plan test cases,
  detect test framework, test plan, decide testing approach.
triggers:
  - design a test strategy for this change
  - what should we test here
  - plan the test cases
  - which test framework does this project use
  - decide the testing approach before implementation
---

# Test Strategy

Decide what to test and how, before any test is written. Detects the project's test
framework and plans the concrete test cases — the strategy that the `test-authoring`
skill then implements.

## Activation Protocol

Engage this skill at the refined-to-planned stage, or whenever a task needs a test plan
before implementation. Before starting, have in hand the task `acceptance-criteria` and
the `affected-areas` — what success looks like and which code will change. The output is
a strategy: the framework in use and the concrete cases to cover, with real runnable
commands. Writing the tests themselves belongs to the `test-authoring` skill.

## Workflow

1. **Detect the framework** — identify the project's test framework and language. See
   `reference/framework-detection.md` for the detection commands and the
   recommend-a-framework fallback.
2. **Plan the test cases** — for each affected unit, decide which cases must be covered
   and which commands will run them.

### Plan the Test Cases

For each public function or affected unit, plan:

- **Happy path**: Normal inputs produce expected outputs.
- **Edge cases**: Empty inputs, zero values, boundary values, max/min.
- **Error cases**: Invalid inputs, missing data, failed dependencies.
- **Integration points**: Interactions with other components.

Name the concrete command that will run each group of cases (e.g. `uv run pytest tests/`,
`cargo test`). The strategy must contain real, runnable commands — not placeholders. Hand
the framework and the planned cases to the `test-authoring` skill, which writes and runs
the tests.

## Reference

- `reference/framework-detection.md` — the framework-detection commands and the
  recommend-a-framework fallback. Read it for step 1.
