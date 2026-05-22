# Pre-Build Pass

## Purpose

The ADVERSARY pre-build pass: what it attacks, when it runs, the limbo inputs it
reads, and its attack vectors. Loaded by the adversarial-review SKILL.md
Activation Protocol when ADVERSARY is invoked for the pre-build pass.

## Content

### Trigger and stage

The pre-build pass runs at the planned-to-ready transition. Its verdict gates
that transition: the planned-to-ready gate is satisfied when the ADVERSARY
pre-build verdict is resolved.

At this stage no code and no diff exist. The pre-build pass attacks the PLAN
only — there is no built artifact to inspect yet.

### Inputs to read

ADVERSARY re-grounds against the limbo record before attacking. Read, from the
task's limbo record:

- the `approach` — the implementation plan PLANNER wrote
- the test-strategy — the planned tests and their real, runnable commands
- the `acceptance-criteria` — what success is defined as
- the `risks` field — the risks RISK enumerated

### Attack vectors

Try to break the plan. Work these vectors against the inputs above:

- **Missing cases** — inputs, states, or transitions the approach does not
  address.
- **Wrong assumptions** — the approach assumes something untrue about the
  current code or system.
- **Untestable criteria** — an acceptance criterion that cannot be checked, or a
  test-strategy step with a placeholder instead of a real command.
- **Unaddressed risks** — a risk in the `risks` field with no corresponding
  mitigation or coverage in the approach or test-strategy.

Every finding must name a specific target — a specific approach step, criterion,
test command, or risk entry. No vague warnings.

### Verdict

Convert the findings into exactly one verdict — KILL, DEMOTE, REVISE, or PASS —
using [verdict-rubric.md](verdict-rubric.md). The verdict-rubric file states the
gate effect of each verdict on the pre-build pass.
