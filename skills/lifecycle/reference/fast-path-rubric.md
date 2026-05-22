# Fast-Path Rubric

## Purpose

The machine-checkable rubric that decides whether a task is trivial or full,
who proposes and who confirms the sizing, what a trivial task skips, and the
explicit gate overrides that keep a trivial task from stalling. Loaded by the
lifecycle SKILL.md workflow for step 1 — sizing the task.

## Content

### Who sizes the task

Not every task needs the full eight-stage lifecycle. SCOUT, grounded in the
codebase, proposes a sizing — trivial or full. MAESTRO confirms it.

### The 4 trivial criteria

A task is trivial when ALL of the following hold:

- It touches no more than 2 files.
- It makes no public API or signature change.
- It adds no new dependency.
- It is not security-sensitive.

If any one condition fails, the task is full and runs the complete lifecycle.

The rubric is machine-checkable on purpose — file count, API surface, dependency
set, and security sensitivity are all concrete, inspectable facts, not judgment
calls.

### What a trivial task skips

A trivial task skips RISK and both ADVERSARY passes — the pre-build pass and the
pre-ship pass. It still runs SCOUT, PLANNER, ENGINEER, REVIEWER, VERIFIER, and
COMMITTER.

### Trivial gate overrides

Skipping those passes changes two gates. The skips are explicit gate overrides
for a trivial task — not a stalled gate.

**planned-to-ready override.** Because a trivial task runs no ADVERSARY
pre-build pass, the planned-to-ready gate has no verdict to resolve. For a
trivial task that gate is simply skipped: the task still advances from planned
to ready, just without an ADVERSARY verdict. A trivial task is never stuck
waiting on a gate it does not run.

**in-review-to-done override.** Because a trivial task runs no ADVERSARY
pre-ship pass, the in-review-to-done gate drops its ADVERSARY-pre-ship-clear
input for a trivial task: that gate is satisfied by REVIEWER APPROVE and
VERIFIER PASS or SKIPPED alone.
