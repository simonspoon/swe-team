# Verdict Rubric

## Purpose

The decision-tree that converts ADVERSARY's findings into exactly one verdict —
KILL, DEMOTE, REVISE, or PASS — and the gate effect of every verdict on each
pass. Loaded by the adversarial-review SKILL.md for both the pre-build pass and
the pre-ship pass.

## Content

### The verdict vocabulary

Every ADVERSARY pass — pre-build or pre-ship — produces exactly one verdict from
this vocabulary. There are no partial verdicts.

- **KILL** — the change is unsalvageable as planned: a fundamental flaw in the
  approach (pre-build) or in the built artifact (pre-ship).
- **DEMOTE** — correctible implementation-level issues exist, but they do not
  invalidate the plan or the approach.
- **REVISE** — specific, nameable findings that the owning agent can address in
  place, without a stage rollback.
- **PASS** — no blocking findings. The gate input is satisfied.

### The decision tree

Evaluate the conditions in order — KILL first, then DEMOTE, then REVISE, then
PASS. The first condition that holds is the verdict.

1. **KILL** — Does the change have a fundamental flaw that makes it
   unsalvageable as planned (pre-build) or as built (pre-ship)? If yes, the
   verdict is KILL.
2. **DEMOTE** — Are there implementation-level issues that are correctible but
   real, without invalidating the plan or approach? If yes, the verdict is
   DEMOTE.
3. **REVISE** — Are there specific, nameable findings the owning agent can fix
   in place? If yes, the verdict is REVISE.
4. **PASS** — None of the above held: there are no blocking findings. The
   verdict is PASS.

A verdict must be one of these four — no partial verdicts.

### Gate effect of every verdict

Each verdict has a defined effect on the lifecycle. The effect is stated for
EVERY verdict, including PASS.

| Verdict | Gate effect — pre-build pass (planned-to-ready) | Gate effect — pre-ship pass (in-review) |
|---------|--------------------------------------------------|------------------------------------------|
| PASS | Resolves the planned-to-ready gate and advances the task to `ready`. PASS is the verdict that clears the gate. | Satisfies the ADVERSARY pre-ship input to the in-review-to-done gate (the gate also requires REVIEWER APPROVE and VERIFIER PASS or SKIPPED). |
| REVISE | No stage rollback. Resolved in place per the REVISE procedure in `lifecycle/reference/rollback-rules.md`; the gate is re-evaluated after one ADVERSARY re-run of the SAME pass. | No stage rollback. Resolved in place per the REVISE procedure in `lifecycle/reference/rollback-rules.md`; the gate is re-evaluated after one ADVERSARY re-run of the SAME pass. |
| DEMOTE | Rolls the task back to `planned` — code does not exist yet, so the plan is reworked in place; there is no `in-progress` stage before code. | Rolls the task back to `in-progress` for ENGINEER to fix the built artifact. |
| KILL | Rolls the task back to `planned` — the plan failed and must be reworked. | Rolls the task back to `refined` — the built change is unsalvageable against the requirements and must be re-scoped from its acceptance criteria forward. |

PASS is not merely "no findings recorded" — it is the verdict that resolves and
advances the gate. KILL, DEMOTE, and REVISE each map to their own rollback or
in-place-revise destination above, given per verdict per pass.

KILL rollback destination per pass, stated explicitly:

- A KILL on the pre-build pass rolls the task back to `planned`.
- A KILL on the pre-ship pass rolls the task back to `refined`.

DEMOTE is pass-aware, mirroring KILL — it is NOT a single pass-agnostic
`in-progress` destination:

- A DEMOTE on the pre-build pass rolls the task back to `planned`. The pre-build
  pass fires at the planned-to-ready transition, when code does not exist yet;
  there is no `in-progress` stage to roll back to, so the plan is reworked in
  place at `planned`.
- A DEMOTE on the pre-ship pass rolls the task back to `in-progress` for
  ENGINEER to fix the built artifact.

This resolves the blueprint S4.2 table's terse single-row `DEMOTE (ADVERSARY) ->
in-progress` entry and is consistent with the blueprint's own pass-split
treatment of KILL. REVISE on either pass forces no rollback and is resolved in
place per the REVISE procedure.

### Trivial tasks run NO ADVERSARY pass

A trivial task — one that meets all four fast-path criteria — skips RISK and
both ADVERSARY passes. Because no pre-build pass and no pre-ship pass run for a
trivial task, ADVERSARY issues NO verdict at all for it — and in particular
ADVERSARY never issues a PASS for a trivial task.

MAESTRO must not conflate "no ADVERSARY PASS was issued" with "the gate is
blocked." For a trivial task the planned-to-ready gate has no ADVERSARY verdict
to resolve and the in-review-to-done gate drops its ADVERSARY-pre-ship-clear
input — both are explicit gate overrides for trivial tasks, not stalled gates.
The absence of an ADVERSARY verdict on a trivial task is expected, not a gate
failure.
