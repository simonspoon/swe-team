# Pre-Ship Pass

## Purpose

The ADVERSARY pre-ship pass: the hard requirement to attack the real `git diff`
of the actual change, the exact commands to run, and its attack vectors. Loaded
by the adversarial-review SKILL.md Activation Protocol when ADVERSARY is invoked
for the pre-ship pass.

## Content

### Trigger and stage

The pre-ship pass runs at the in-review stage. Its verdict is one of the three
inputs to the in-review-to-done gate, alongside the REVIEWER verdict and the
VERIFIER verdict.

### HARD REQUIREMENT: read the real git diff

On the pre-ship pass ADVERSARY MUST read the real `git diff` of the actual
change. It attacks what was actually built, against what the plan promised.

This is a hard, non-negotiable requirement. Run the real diff and read the
changed files themselves:

```bash
git diff                 # unstaged changes
git diff --cached        # staged changes
git diff <base>..<head>  # the full change range, when a base/head is known
```

Run the form that captures the actual change for the task under review, then
also open and read each changed file — not only the diff hunks.

**PROHIBITED.** ADVERSARY MUST NOT attack a summary of the change, the `report`
note, a remembered description, or any second-hand account of the code. Do not
use a summary. Do not use the report. Do not use memory. A pre-ship verdict
formed from anything other than the real `git diff` output and the changed files
is invalid — re-run the diff and attack the real code.

### Inputs to read

The pre-ship pass attacks the actual code against what the plan promised, so
ADVERSARY must know what the plan promised. In addition to running the real
`git diff` and reading the changed files (the hard requirement above), read,
from the task's limbo record:

- the `approach` — the implementation plan PLANNER wrote, so the diff can be
  compared against what was planned
- the `acceptance-criteria` — what success is defined as
- the `risks` — the risks RISK enumerated, to check the change did not realize
  one
- the `test-strategy` — the planned tests and their real, runnable commands

This does not relax the hard `git diff` mandate or the prohibition above: the
limbo fields establish what the plan promised, but the verdict must still be
formed against the real diff and the changed files, never a summary, the
`report`, or memory.

### Attack vectors

With the real diff and the changed files in hand, attack the built change:

- **Actual code vs. the plan** — what was built diverges from what the
  `approach` promised.
- **Acceptance criteria coverage** — a criterion the code does not actually
  satisfy.
- **New failure modes** — the change introduces a bug, race, leak, or
  regression not present before.
- **Scope creep** — changes in the diff that the task never asked for.

Every finding must cite a specific file, function, or diff hunk.

### Verdict

Convert the findings into exactly one verdict — KILL, DEMOTE, REVISE, or PASS —
using [verdict-rubric.md](verdict-rubric.md). The verdict-rubric file states the
gate effect of each verdict on the pre-ship pass.
