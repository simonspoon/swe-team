---
name: adversarial-review
description: >
  Attack a task at one of two stages and produce a verdict. The pre-build pass
  attacks the plan at planned-to-ready; the pre-ship pass attacks the real
  git diff at in-review. Both passes produce one verdict from the vocabulary
  KILL, DEMOTE, REVISE, PASS, which gates or rolls back the task.
  Triggers: adversarial review, attack the plan, attack the diff, pre-build
  verdict, pre-ship verdict.
triggers:
  - run the adversarial pre-build pass on this plan
  - run the adversarial pre-ship pass on this diff
  - attack this plan before it is built
  - attack this code before it ships
  - produce a KILL/DEMOTE/REVISE/PASS verdict
---

# Adversarial Review

ADVERSARY runs twice in a full task, against two different artifacts at two
different stages. It is not one role; it is two passes. ADVERSARY loads this
skill for both passes. The verdict vocabulary for both passes is KILL, DEMOTE,
REVISE, PASS.

## Activation Protocol

This protocol is NOT linear — it does not load every reference file. ADVERSARY
is dispatched for exactly one pass at a time, and the Activation Protocol routes
to the reference file for that pass:

- **If invoked for the pre-build pass** (planned-to-ready transition): load
  [reference/pre-build-pass.md](reference/pre-build-pass.md). The artifact under
  attack is the plan; no code or diff exists yet.
- **If invoked for the pre-ship pass** (in-review stage): load
  [reference/pre-ship-pass.md](reference/pre-ship-pass.md). The artifact under
  attack is the real `git diff` of the actual change.

Both passes then load [reference/verdict-rubric.md](reference/verdict-rubric.md)
to convert findings into exactly one verdict — KILL, DEMOTE, REVISE, or PASS.

Determine which pass you are running from the dispatch instruction and the
task's current stage, then load only the matching pass file plus the
verdict rubric. Do not load the other pass's file.

## Workflow

1. **Route to the pass.** Identify whether this is the pre-build pass or the
   pre-ship pass and load the matching reference file — see the Activation
   Protocol branch above:
   [reference/pre-build-pass.md](reference/pre-build-pass.md) for pre-build,
   [reference/pre-ship-pass.md](reference/pre-ship-pass.md) for pre-ship.
2. **Re-ground against the artifact.** For the pre-build pass, read the plan
   inputs from limbo. For the pre-ship pass, run the real `git diff` and read
   the changed files — never a summary, the report, or a remembered
   description. The matching pass file states exactly what to read.
3. **Attack the artifact.** Work the attack vectors for the pass and record
   every finding against a specific, nameable target.
4. **Issue one verdict.** Convert the findings into exactly one of KILL,
   DEMOTE, REVISE, or PASS, and state its gate effect for this pass. See
   [reference/verdict-rubric.md](reference/verdict-rubric.md).

## Reference

- [reference/pre-build-pass.md](reference/pre-build-pass.md) — the pre-build
  pass: inputs, attack vectors, and the no-diff-yet stage. Loaded by the
  Activation Protocol when ADVERSARY is invoked for the pre-build pass.
- [reference/pre-ship-pass.md](reference/pre-ship-pass.md) — the pre-ship pass:
  the hard requirement to run the real `git diff` and read the changed files,
  and the attack vectors. Loaded by the Activation Protocol when ADVERSARY is
  invoked for the pre-ship pass.
- [reference/verdict-rubric.md](reference/verdict-rubric.md) — the
  KILL/DEMOTE/REVISE/PASS decision-tree and the gate effect of every verdict.
  Loaded by both passes.
