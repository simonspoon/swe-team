---
name: simplify
description: Analyze code for unnecessary complexity using a catalog of 7 refactoring patterns, then apply focused fixes. IMPORTANT — do NOT use agents for this skill. Do all work inline in the main thread. Use when simplifying code, refactoring, cleaning up, reducing complexity, extracting modules, removing duplication, or improving code structure.
---

# Simplify

Analyze code for unnecessary complexity and apply focused refactorings that preserve behavior. Conservative by default: only change what is clearly an improvement.

## Critical Constraints (MUST follow — read before doing anything)

1. **NEVER use agents or sub-agents for analysis.** This overrides the "Route to agents" rule from CLAUDE.md. The simplify skill is a single-concern task that analyzes ONE file at a time — it does NOT qualify for agent routing. Do NOT launch Agent() calls. Do NOT create "Code Reuse Review", "Code Quality Review", "Efficiency Review", or any other agent. You MUST do all analysis yourself in the main conversation thread by walking through the 7-pattern checklist. If you catch yourself about to launch an agent, STOP and do the work inline instead.
2. **Only look for the 7 patterns listed in the Analysis Workflow.** Do not report security issues, performance problems, style preferences, or anything outside the 7-pattern catalog. This is a structural simplification tool, not a general code reviewer.
3. **Use the exact output format shown in Step 3 of the Analysis Workflow.** Do not invent your own format. Do not use emoji severity markers. Do not use CRITICAL/HIGH/MEDIUM/LOW categories.

## Prerequisites

- Invoke `/swe-team:software-engineering` first to load project conventions and preferences.
- Project must have tests. If no tests exist, write them before refactoring (invoke `/swe-team:test-engineer`).

## Activation Protocol

1. Invoke `/swe-team:software-engineering` to load project conventions. If the user's message indicates it was already invoked in this conversation, skip this step.
2. Determine scope: specific files, staged changes, or a module/class the user identified. If the user says "simplify everything" or gives no specific target, ask them to identify the files or module to analyze. Do not scan the entire codebase unprompted.
3. Run the Analysis Workflow (which starts by reading the refactoring catalog, THEN the target code).
5. Present findings to the user. Wait for approval before applying changes.
6. Run the Refactoring Workflow for each approved change.
7. Invoke `/swe-team:test-engineer` to verify all tests pass after changes.
8. Invoke `/swe-team:code-reviewer` to review the refactored code.

## Analysis Workflow

### Step 1: Read the Refactoring Catalog

Before reading any target code, read `reference/refactoring-catalog.md` now. This file defines the ONLY 7 patterns you are allowed to report. You must have the catalog in your context before analyzing code.

### Step 2: Read the Target Code

Read the target files. For each file, note:
- Total lines and number of functions/methods/classes.
- Any function over 60 lines or class over 200 lines (these are signals for God Object/God Function — see catalog).
- Import/dependency count.

### Step 3: Check Each Pattern and Report (do this yourself — NO agents)

Check the code against each of the 7 catalog patterns below. For each one, determine: present or absent? Then output your findings using EXACTLY this table format (use the pattern names exactly as written, do not rename them, do not add other issue types):

```
## Simplification Analysis: [scope]

### Pattern Checklist
1. God Object / God Function — [FOUND at file:lines / NOT FOUND]
2. Callback Hell — [FOUND at file:lines / NOT FOUND]
3. Hardcoded Dependencies — [FOUND at file:lines / NOT FOUND]
4. Dead Code — [FOUND at file:lines / NOT FOUND]
5. Code Duplication — [FOUND at file:lines / NOT FOUND]
6. Over-Abstraction — [FOUND at file:lines / NOT FOUND]
7. Overly Clever Code — [FOUND at file:lines / NOT FOUND]

### Opportunities Found

| # | Pattern | Location | Severity | Risk |
|---|---------|----------|----------|------|
(one row per FOUND pattern — use the exact pattern name from the checklist)

### Recommended Order
1. [#N] Pattern — reason to do this first.
2. [#N] Pattern — reason.
```

**Detection criteria for each pattern:**
1. **God Object / God Function** — class with 5+ unrelated responsibilities, or function over 60 lines doing multiple distinct tasks.
2. **Callback Hell** — 3+ levels of nested callbacks or promise chains.
3. **Hardcoded Dependencies** — classes that instantiate their own dependencies internally (e.g., `DatabaseClient("...")` or `SmtpMailer("...")` inside `__init__`). Makes testing impossible without monkey-patching.
4. **Dead Code** — unused functions, unreachable branches, commented-out code.
5. **Code Duplication** — near-identical code blocks in 2+ places.
6. **Over-Abstraction** — interfaces with 1 implementation, unnecessary factories.
7. **Overly Clever Code** — one-liners that take 30+ seconds to understand.

**Only report patterns from the 7 above.** Do not report security issues, performance optimizations, input validation, SQL efficiency, error handling, or any other concerns. This skill is for structural simplification only.

## Refactoring Workflow

Execute one refactoring at a time. Do not batch unrelated changes.

### Step 1: Verify Tests Exist

Before touching any code, confirm tests cover the behavior being refactored. Do this by:
1. Finding test files for the target module (check `tests/`, `__tests__/`, `*_test.*`, `*.spec.*` patterns).
2. Running the test suite to confirm tests pass before any changes.

```bash
# Run existing tests for the target module
# Use project's test runner (detect from package.json, pyproject.toml, Makefile, etc.)
```

If tests are missing for the target code, write them first. The refactoring must not change behavior, and tests are the proof.

### Step 2: Apply the Refactoring

Follow the specific pattern guidance in reference/refactoring-catalog.md. For every refactoring:

- Make the smallest change that accomplishes the goal.
- Preserve all public interfaces unless the user explicitly approved breaking them.
- Preserve error handling behavior (error types, messages, propagation).
- Preserve logging and observability (log levels, message format, metric names).
- Update imports and callers in the same change — no broken intermediate states.

### Step 3: Verify

Run tests immediately after each refactoring. Do not proceed to the next refactoring until tests pass.

```bash
# Run the full test suite, not just the changed module's tests
# Other modules may depend on the refactored code
```

If tests fail:
1. Check if the failure is a real behavior change (revert and rethink the approach).
2. Check if the failure is a test that was testing implementation details, not behavior (update the test).
3. If unclear, ask the user.

**If the refactoring extracted new modules or files**, invoke `/swe-team:test-engineer` to generate unit tests for each newly created module. Existing tests only cover the original code — the new modules need their own tests.

### Step 4: Report

Use this EXACT format for each completed refactoring (do not use a different format):

```
## Refactoring Complete: [pattern name]

**Changed**: [list of files modified]
**What**: [1-2 sentences describing the change]
**Why**: [concrete benefit — fewer lines, clearer responsibility, easier testing]
**Tests**: [PASS — X tests ran, Y passed] or [FAIL — details]
**Preserved**: [key behaviors confirmed unchanged]
```

## Safety Rules

1. **Never refactor without tests.** If tests do not exist, write them first.
2. **Never change behavior.** Refactoring means same inputs produce same outputs, same side effects, same errors.
3. **One refactoring per commit.** Each change should be independently revertible.
4. **Do not over-abstract.** Extracting a small helper function used once is not simplification. Introducing a design pattern where a plain function works is not simplification. Exception: extracting a cohesive group of methods from a God Object into a separate module IS simplification, even if each extracted module is used by only one caller.
5. **Preserve the team's style.** Match existing conventions (from software-engineering preferences), not textbook ideals.
6. **When in doubt, leave it.** A refactoring you are unsure about is not "clearly an improvement."
7. **Small files are not always simple.** Do not split a cohesive 300-line file into six 50-line files that require cross-file reading to understand.

## Quick Mode

For small changes (the target code being analyzed is a single function or under 30 lines of code), skip the formal analysis report. Instead:
1. Read the code.
2. Identify the single obvious improvement.
3. Verify tests exist.
4. Apply the change.
5. Run tests.
6. Report the result inline.

## Reference

- **Refactoring patterns and examples** — Read reference/refactoring-catalog.md
