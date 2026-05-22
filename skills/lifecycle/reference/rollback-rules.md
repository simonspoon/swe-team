# Rollback Rules

## Purpose

What MAESTRO does when a gate fails: the rollback table, the REVISE procedure
and its general multi-field dependency-ordering rule, KILL determinism by pass,
and the COMMITTER failure path. Loaded by the lifecycle SKILL.md workflow for
step 3 — rolling a task back after a failed gate.

## Content

### The rollback table

When a gate fails, MAESTRO rolls the task back rather than forcing it forward:

| Trigger | Rolls back to |
|---------|---------------|
| REQUEST_CHANGES (REVIEWER) | in-progress |
| FAIL (VERIFIER) | in-progress |
| DEMOTE (ADVERSARY), pre-build pass | planned |
| DEMOTE (ADVERSARY), pre-ship pass | in-progress |
| KILL (ADVERSARY), pre-build pass | planned |
| KILL (ADVERSARY), pre-ship pass | refined |
| COMMITTER failure | resolved by MAESTRO; re-dispatch COMMITTER, or block the task |

DEMOTE is pass-aware, exactly like KILL. A pre-ship DEMOTE fires at the
in-review stage, so it rolls the task back to `in-progress` for ENGINEER to fix.
A pre-build DEMOTE fires at the planned-to-ready transition, when the task is at
`planned` and code does not exist yet — there is no `in-progress` stage to roll
back to, so it rolls the task back to `planned` for re-planning in place. This
resolves the blueprint S4.2 table's terse single-row `DEMOTE (ADVERSARY) ->
in-progress` entry, which is impossible for the pre-build pass, and is consistent
with how the blueprint itself splits KILL by pass.

A REVIEWER COMMENT verdict is not a rollback trigger. It is advisory only: the
task neither rolls back nor is forced forward by a COMMENT — the comments are
recorded as limbo notes and the in-review-to-done gate is decided by the other
verdicts.

### KILL determinism by pass

KILL is deterministic by pass. A KILL on the ADVERSARY pre-build pass
(planned to ready) rolls the task back to `planned` — the plan failed and the
planning specialists must rework it. A KILL on the ADVERSARY pre-ship pass
(in-review) rolls the task back to `refined` — the built change is unsalvageable
against the requirements, and the task must be re-scoped from its acceptance
criteria forward.

### The REVISE procedure

A REVISE verdict does not by itself force a stage rollback; it is resolved in
place before the gate is re-evaluated. The resolution is a defined sequence
MAESTRO drives:

1. MAESTRO re-dispatches the agent that owns the flagged content. The owning
   agent is determined by the field-to-owner mapping below — it is the
   authoritative dispatcher list and no owner is omitted: SCOUT owns
   `acceptance-criteria`, PLANNER owns `approach` and `test-strategy`, RISK owns
   `risks`, and ENGINEER owns `code` and the `report`. Plan-level findings on
   the pre-build pass route to SCOUT, PLANNER, or RISK; code-level findings on
   the pre-ship pass route to ENGINEER.
2. The owning agent revises only its own field, addressing the REVISE findings.
3. MAESTRO re-dispatches ADVERSARY for the SAME pass to re-verify the revised
   artifact.
4. Only then is the gate re-evaluated against the fresh ADVERSARY verdict.

There is one ADVERSARY re-run per REVISE resolution — never one per owning
agent.

### Multi-field REVISE: the general dependency-ordering rule

When the REVISE findings span more than one field, MAESTRO does not improvise
and does not hard-code a fixed agent sequence. It applies one general rule:
**re-dispatch each owning agent sequentially in the lifecycle production order
of the field it owns.** The field that is produced earlier in the lifecycle is
revised first; the field that depends on it is revised after.

The rule is anchored to an explicit field-to-owner mapping. Every limbo field
has exactly one owning agent — one writer per field:

| Field | Owning agent |
|-------|--------------|
| acceptance-criteria | SCOUT |
| approach | PLANNER |
| test-strategy | PLANNER |
| risks | RISK |
| code | ENGINEER |
| report | ENGINEER |

The lifecycle production order of those fields follows the stage machine:
SCOUT writes `acceptance-criteria` at captured-to-refined; PLANNER writes
`approach` and `test-strategy` at refined-to-planned; RISK writes `risks` at
refined-to-planned, after the `approach` exists; ENGINEER writes `code` and the
`report` at in-progress. So when a multi-field REVISE touches several fields,
order the re-dispatches by where each owning agent's field sits in that
production sequence, and dispatch them one at a time. Each agent revises only
its own field. ADVERSARY is then re-run exactly once, for the SAME pass, AFTER
all owning agents have revised; the gate is re-evaluated against that single
fresh ADVERSARY verdict.

**Worked example (pre-build pass).** A pre-build REVISE flags both the
`approach` (PLANNER) and the `risks` field (RISK). `approach` is produced before
`risks` in the lifecycle, so the general rule resolves to: re-dispatch PLANNER
first, then RISK. This PLANNER-then-RISK sequence is the example output of the
rule for this particular pair of fields — it is not a hard-coded sequence. A
different multi-field REVISE — touching a different set of fields — produces a
different order from the same rule: always sort the owning agents by the
production order of their fields.

### COMMITTER failure

If COMMITTER fails to land the commit — a rejected pre-commit hook, branch
protection, a dirty index, or any other cause — MAESTRO resolves the underlying
cause and re-dispatches COMMITTER. If the cause cannot be resolved, the task is
marked blocked rather than left in a half-committed state.
