---
name: lifecycle
description: >
  The 8-stage task machine MAESTRO drives from intake to commit. Defines the
  stage sequence and per-transition gate criteria, the rollback rules when a
  gate fails, the risk-weighted human checkpoint, the fast-path rubric for
  trivial tasks, and the decompose-and-fan-out logic for large features.
  Triggers: drive a task lifecycle, validate a stage gate, roll back a task,
  size a task, decompose a feature.
triggers:
  - drive a task through its lifecycle
  - validate the gate for this stage transition
  - roll a task back after a failed gate
  - size this task against the fast-path rubric
  - decompose a feature into child tasks
---

# Lifecycle

The 8-stage task machine. MAESTRO loads this skill on every task and uses it to
drive the task one stage at a time, validate each gate, roll the task back when
a gate fails, decide whether the user is checkpointed, size the task, and
fan out a decomposed feature across concurrent ENGINEER dispatches.

## Activation Protocol

MAESTRO engages this skill the moment a task enters the team and keeps it loaded
for the whole lifecycle. Before driving any transition, have in hand:

- the task's current `status` (the stage it sits in)
- the limbo record for the task — `approach`, `risks`, `acceptance-criteria`,
  `test-strategy`, `report`, and all `notes`
- the verdicts and limbo output of the last agent dispatched

MAESTRO dispatches exactly one agent per task at a time, reads that agent's
limbo output, re-grounds against the limbo record, validates the gate for the
current transition, and only then advances or rolls back. It authors zero
technical content itself.

## Workflow

1. **Size the task FIRST.** Before driving any transition or validating any
   gate, confirm SCOUT's proposed sizing against the machine-checkable fast-path
   rubric. Sizing decides whether the trivial gate overrides apply — and whether
   the ADVERSARY passes run at all — so it must be settled before the stage
   machine is walked. See [reference/fast-path-rubric.md](reference/fast-path-rubric.md).
2. **Walk the stage machine.** Identify the current stage, the agent that owns
   the next transition, and the exact gate criterion that must hold before the
   task advances. See [reference/stage-machine.md](reference/stage-machine.md).
3. **Roll back on a failed gate.** When a gate fails, do not force the task
   forward — apply the rollback rules: the rollback table, the REVISE procedure,
   KILL determinism, and the COMMITTER failure path. See
   [reference/rollback-rules.md](reference/rollback-rules.md).
4. **Apply the risk-weighted gate.** After the planned stage, scan the task's
   limbo notes for a `FLAG:` prefix. Checkpoint the user only when a flag is
   present; otherwise continue autonomously. See
   [reference/risk-weighted-gate.md](reference/risk-weighted-gate.md).
5. **Decompose and fan out.** When a feature is too large for one task, split it
   into child tasks with explicit dependencies and dispatch independent leaves'
   ENGINEER steps concurrently. See
   [reference/decompose-fan-out.md](reference/decompose-fan-out.md).

## Reference

- [reference/fast-path-rubric.md](reference/fast-path-rubric.md) — the 4
  machine-checkable trivial criteria and the trivial gate overrides. Read it for
  step 1.
- [reference/stage-machine.md](reference/stage-machine.md) — the 8 stages, the 7
  verbatim gate criteria, and per-transition agent ownership. Read it for step 2.
- [reference/rollback-rules.md](reference/rollback-rules.md) — the rollback
  table, the REVISE procedure and its multi-field dependency-ordering rule,
  KILL determinism, and the COMMITTER failure path. Read it for step 3.
- [reference/risk-weighted-gate.md](reference/risk-weighted-gate.md) — the
  `FLAG:` prefix mechanics, the autonomous-by-default rule, and the 3-line
  approach-summary checkpoint. Read it for step 4.
- [reference/decompose-fan-out.md](reference/decompose-fan-out.md) —
  decomposition into child tasks and concurrent ENGINEER fan-out. Read it for
  step 5.
