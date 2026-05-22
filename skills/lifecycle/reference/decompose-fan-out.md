# Decompose and Fan-Out

## Purpose

How MAESTRO splits a large feature into child tasks with explicit dependencies,
and how it fans out work concurrently — the concurrency mechanism, what it is
scoped to, and why non-ENGINEER agents are never parallelized across leaves.
Loaded by the lifecycle SKILL.md workflow for step 5 — decomposing a feature
and dispatching its leaves.

## Content

### When to decompose

A feature too large for a single task is decomposed into child limbo tasks with
explicit dependencies between them.

- Independent leaves — child tasks with no dependency on each other — are
  dispatched concurrently.
- Dependent leaves — child tasks where one needs another's output — run
  sequentially in dependency order.

### The concurrency mechanism

The concurrency mechanism is concrete. MAESTRO achieves parallelism by emitting
multiple Task tool calls in a SINGLE turn; the runtime then runs those
dispatched calls concurrently. The batched dispatch is scoped to ENGINEER
(implementation) steps: independent leaves at the ready-to-in-progress stage run
their ENGINEERs in parallel. Parallelism is therefore the batched dispatch of
independent ENGINEER steps in one turn — it is not a separate orchestration
layer and not unbounded per-leaf concurrency.

### Concurrency is scoped to ENGINEER steps ONLY

The batched-dispatch concurrency applies to ENGINEER steps and ENGINEER steps
alone. The other agents — PLANNER, RISK, ADVERSARY, REVIEWER, VERIFIER, SCOUT,
COMMITTER — are NEVER dispatched in parallel across leaves. They are serialized,
one leaf at a time.

The reason is the one-writer-per-field constraint. Each limbo field has exactly
one owning agent; running two instances of a non-ENGINEER agent concurrently
across leaves would risk one-writer-per-field violations — two writers racing on
the same kind of field. ENGINEER steps batch safely because each independent
leaf is its own task with its own fields; the non-ENGINEER agents stay
serialized to keep field ownership clean.

### Each leaf runs its own lifecycle

This bounds what runs in parallel. MAESTRO still drives each leaf's lifecycle
itself: it batches the independent ENGINEER steps across leaves into a single
turn, reads the returns, and advances each leaf one stage at a time. Where leaf
lifecycles cannot be cleanly batched into one turn, those steps are serialized.

Decomposition does not waive the lifecycle for any child. Each child task runs
its own stage machine, its own gates, and its own rollback rules, all driven by
MAESTRO.
