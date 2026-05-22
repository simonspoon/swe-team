# Risk-Weighted Gate

## Purpose

The single human checkpoint in an otherwise autonomous lifecycle: the `FLAG:`
prefix mechanics, who writes the flag and who reads it, when the checkpoint
fires, and what the checkpoint presents. Loaded by the lifecycle SKILL.md
workflow for step 4 — applying the risk-weighted gate after the planned stage.

## Content

### Autonomous by default

The team is autonomous by default. It runs from intake to commit without asking
the user to approve intermediate steps. A clear task — one with no flag — runs
straight through and receives zero interruptions. Human attention is spent only
where risk is flagged, never as a blanket per-stage approval.

### The single checkpoint

There is exactly one human checkpoint. After the planned stage, and ONLY when
SCOUT or PLANNER has flagged ambiguity or high blast radius, MAESTRO pauses and
presents the user with a 3-line approach summary before continuing.

The checkpoint is evaluated when MAESTRO validates the planned-to-ready gate,
AFTER the ADVERSARY pre-build verdict has been resolved. If that verdict
triggers a rollback — KILL or DEMOTE — the plan is being reworked and the task
leaves the planned-to-ready transition, so no checkpoint is presented; the
checkpoint is reached only once the pre-build verdict resolves cleanly.

### The FLAG prefix mechanics

The flag is a concrete signal, not a vibe. SCOUT and PLANNER raise it by
recording a limbo note on the task with a structured, machine-detectable prefix:

- `FLAG: AMBIGUITY` — the task's intent or scope is genuinely unclear.
- `FLAG: HIGH-BLAST-RADIUS` — the change reaches far enough that a wrong call is
  expensive.

The signal is written by SCOUT or PLANNER and read by MAESTRO — no agent infers
the flag from free prose. When MAESTRO validates the planned gate, it scans the
task's limbo notes for that prefix:

- If a `FLAG:` note is present, MAESTRO triggers the checkpoint.
- If none is present, MAESTRO continues autonomously.

### The checkpoint content

The checkpoint, when it fires, presents the user with a 3-line approach summary
after the planned stage and before the task continues. It is a brief, scannable
summary of the planned approach — not the full plan — sized so the user can make
a fast keep-or-redirect call. Once the user responds, MAESTRO continues driving
the lifecycle.

This is the risk-weighted gate: human attention is spent only where risk is
flagged, never as a blanket per-stage approval.
