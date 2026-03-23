---
name: skill-trainer
description: Validate and harden skills through automated testing and weak-model calibration. Use when you want to test a skill, train a skill, validate skill instructions, calibrate a skill for weaker models, or stress-test a skill before deployment. Triggers on skill training, skill testing, skill validation, skill calibration, train skill, test skill.
---

# Skill Trainer — Test, Validate, Harden

Actively exercise a skill's documented commands and workflows, find where instructions break, fix the docs, then validate that a weaker model (Haiku) can follow them correctly.

## Prerequisites

- cmux must be running (`cmux ping` → `PONG`) — needed for Haiku validation
- The target skill must exist in `~/.claude/skills/`
- The `/swe-team:cmux-control` skill must be available (for Haiku validation step)

## Before Starting: Reduce Approval Friction

Training runs many CLI commands. Before Phase 2, advise the user to pre-approve relevant commands in their permission settings. For example, if testing a skill that wraps `limbo`, the user should allow `limbo` commands. Similarly for `cmux` commands during Phase 3.

## When to Use

- After creating a new skill (pair with `/swe-team:skill-creator`)
- After significant edits to an existing skill
- When a skill worked for you (Opus) but you want to confirm it works for weaker models
- When `/swe-team:skill-reflection` identified issues and you've applied fixes

## Workflow Overview

The training loop has 3 phases. **Each phase is a separate unit of work.** You MUST output results and STOP after each phase. Do NOT combine phases or proceed without user go-ahead.

### Phase 1: Test Generation
Read reference/test-generation.md, then:
1. Read the target skill's SKILL.md and all reference files
2. Identify every command, pattern, and workflow documented
3. Generate 8-12 test scenarios covering: core operations, edge cases, multi-step workflows, and cleanup
4. **Output the full numbered test list** — every test with name, category, and description
5. **STOP. Wait for user approval before Phase 2.**

### Phase 2: Self-Test Execution
Read reference/test-execution.md, then:
1. Run each test scenario yourself (as Opus)
2. Record pass/fail and any issues found
3. For each failure, categorize it (read reference/failure-analysis.md)
4. Fix skill docs based on findings
5. Re-run failed tests to confirm fixes
6. **Stop after 2 rounds of fix-and-retest.** If tests still fail after 2 rounds, note the issue and move on.
7. **Be suspicious of 100% pass rates.** If all tests pass, note any places where you used your own knowledge to fill gaps in the docs — those gaps ARE findings even if the test "passed."
8. **Output the full results table** — every test, every result
9. **STOP. Wait for user go-ahead before Phase 3.**

### Phase 3: Haiku Validation
Read reference/haiku-validation.md, then:
1. Select 3-5 tests that exercise the skill's core patterns
2. Spin up a Haiku Claude Code session via cmux
3. Send each task to Haiku and observe its execution
4. Capture the transcript and analyze it
5. Fix any remaining doc issues
6. Produce the final Training Report

## Important Rules

1. **Three phases = three separate responses.** Never combine them.
2. **Fix docs, not code.** You're improving the skill's instructions, not the underlying tools.
3. **2 rounds max** for self-testing. Diminishing returns are real.
4. **1 Haiku run** is usually enough. Only re-run if you made significant doc changes.
5. **Report findings** after each phase — don't silently fix and move on.
6. **Don't over-test.** 8-12 scenarios for Phase 2, 3-5 for Phase 3. Quality over quantity.
7. **Clean up** any workspaces, browsers, or temp files you create during testing.
8. **Test the docs, not the tool.** If you fill a doc gap with your own knowledge, that's a finding to report.

## Output: Training Report

After all phases, produce a summary using this EXACT format:

```
## Training Report: [skill-name]

### Phase 1: Test Scenarios
| # | Test Name | Category | What It Tests |
|---|-----------|----------|---------------|

### Phase 2: Self-Test Results
| # | Test | R1 Result | Issue Found | Fix Applied | R2 Result |
|---|------|-----------|-------------|-------------|-----------|

### Phase 3: Haiku Validation
| # | Task Sent to Haiku | What Haiku Did | Result | Doc Fix |
|---|-------------------|----------------|--------|---------|

### Doc Changes Made
- [file]: [what changed and why]

### Findings (doc gaps filled by model knowledge)
- [any tests where you used knowledge beyond what docs stated]

### Remaining Issues
- [anything that couldn't be fixed, with explanation]

### Verdict: [READY / NEEDS WORK / BLOCKED]
```
