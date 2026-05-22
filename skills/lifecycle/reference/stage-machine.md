# Stage Machine

## Purpose

The 8-stage task machine, the gate criterion for each of the 7 transitions, and
the agent that owns each transition. Loaded by the lifecycle SKILL.md workflow
for step 2 — walking the stage machine and validating the gate for the current
transition.

## Content

### The 8 stages

A task moves through eight limbo stages, in order:

```
captured -> refined -> planned -> ready -> in-progress -> in-review -> done -> commit
```

MAESTRO dispatches ONE agent at a time. After each agent returns, MAESTRO reads
that agent's limbo output, re-grounds against the limbo record, validates the
gate for the current transition, and then either advances the task or rolls it
back.

### The 7 stage gates

A gate is the condition that must hold before MAESTRO advances a task out of a
stage. The gate criteria are quoted at specification precision — they are not
paraphrased and must not be softened.

| Transition | Gate criterion |
|------------|----------------|
| captured to refined | SCOUT has produced at least one testable acceptance criterion. |
| refined to planned | A concrete `approach` exists, the test-strategy contains real test commands, and the `risks` field is populated. |
| planned to ready | The ADVERSARY pre-build verdict is resolved. |
| ready to in-progress | ENGINEER picks up the task and begins implementation. |
| in-progress to in-review | The build is green. |
| in-review to done | REVIEWER verdict is APPROVE, VERIFIER verdict is PASS or SKIPPED, and the ADVERSARY pre-ship pass is clear. |
| done to commit | COMMITTER stages, commits, verifies, and notes the SHA. |

### REVIEWER COMMENT is advisory

A REVIEWER COMMENT verdict is advisory only: it is not APPROVE and does not on
its own satisfy the in-review-to-done gate, but it does not block the task and
does not roll it back. When the REVIEWER verdict is COMMENT, the gate is decided
by the remaining inputs (the in-review-to-done gate requires an explicit APPROVE
verdict from REVIEWER; a COMMENT does not satisfy it, so a standalone COMMENT
pass leaves the task at in-review until an APPROVE is recorded), and the comments
are kept as limbo notes.

### Agent ownership per transition

Each transition is driven by the agent that owns the stage being left. MAESTRO
dispatches that agent, then validates the gate before advancing.

| Transition | Owning agent | What the agent delivers |
|------------|--------------|-------------------------|
| captured to refined | SCOUT | Investigates the codebase, writes at least one testable acceptance criterion, proposes a sizing. |
| refined to planned | PLANNER and RISK | PLANNER writes the `approach` and the test-strategy; RISK writes the `risks` field only. |
| planned to ready | ADVERSARY (pre-build pass) | Attacks the plan; produces a verdict that gates the transition. |
| ready to in-progress | ENGINEER | Picks up the task and begins implementation. |
| in-progress to in-review | ENGINEER | Implements, writes tests, self-verifies until the build is green, writes a `report` note. |
| in-review to done | REVIEWER, VERIFIER, ADVERSARY (pre-ship pass) | REVIEWER reviews the diff, VERIFIER runs the artifact, ADVERSARY attacks the real `git diff`. |
| done to commit | COMMITTER | Stages, writes the message, commits, verifies the commit landed, notes the SHA. |

MAESTRO owns the limbo `status` field across every transition — it advances or
rolls back the task; no other agent changes `status`.
