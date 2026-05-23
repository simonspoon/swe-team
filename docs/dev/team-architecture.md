# Team Architecture

This document is the authoritative blueprint for the swe-team plugin: a 9-agent
autonomous software-development team in which skills are the single source of
truth and agents are lean soul-plus-mandate shells.

It is a TARGET design. It describes the architecture the rebuild produces, not
the current state of the `agents/` and `skills/` directories on disk. Where this
document and the current `CLAUDE.md` routing disagree, this document defines the
intended end state; the live files are migrated to it by later build tasks. Read
this as the specification every later build task encodes — not as a live
behavioral override to honor before the migration completes.

## 1. Purpose and Principles

The core flaw being fixed: agents previously embedded frozen copies of skill
knowledge (inline checklists and procedures), and those copies drifted from the
skills they were copied from. The rebuild removes every embedded copy. Knowledge
lives in exactly one place.

Three primitives, three responsibilities, no overlap:

| Primitive | Is | Holds | Rule |
|-----------|-----|-------|------|
| SKILL | Knowledge | Procedures, checklists, conventions | One home. Progressive disclosure: a thin `SKILL.md` plus a deep `reference/`. The single source of truth. |
| AGENT | Soul + mandate + tools + model | Identity, creed, bar, mandate | Loads skills on demand. Embeds ZERO knowledge — no inline checklists, no inline procedures. Target ~60 lines. |
| LIMBO | Task state | Stage, approach, risks, criteria, notes | One writer per field. |

A fourth principle binds the team: there is no separate memory or knowledge
service anywhere in the architecture. All durable knowledge lives in skills and
is loaded on demand. All task state lives in limbo.

The soul block. Every agent's body opens with a soul block of three parts:

- Identity — what the agent is and the craft it owns.
- Creed — the standard it holds itself to; its integrity.
- Bar — its definition of done. It refuses to pass shoddy work.

One front door (MAESTRO). The team is autonomous from intake through commit,
with a single risk-weighted human checkpoint (Section 5).

## 2. The 9 Agents

Each agent is a lean shell. Its body carries a soul block and a mandate; its
knowledge comes entirely from the skills it loads. Model and tool assignments
are exact and asymmetric — they are not interchangeable.

| Agent | Model | Tools | Skills loaded | Stage(s) owned | Mandate |
|-------|-------|-------|---------------|----------------|---------|
| MAESTRO | opus | Bash, Read, Glob, Grep, Skill, Agent | lifecycle | drives all | Front door and pure router. |
| SCOUT | sonnet | Read, Bash, Glob, Grep, Skill | codebase-research, project-orientation | captured to refined | Investigate; write testable criteria; propose sizing. |
| PLANNER | sonnet | Read, Bash, Glob, Grep, Skill | test-strategy, engineering-standards | refined to planned | Own the approach field and test-strategy. |
| RISK | sonnet | Read, Bash, Glob, Grep, Skill | risk-analysis | refined to planned | Write the risks field only. |
| ADVERSARY | sonnet | Read, Bash, Glob, Grep, Skill | adversarial-review | planned to ready; in-review | Attack the plan, then attack the code. |
| ENGINEER | opus | Read, Write, Edit, Bash, Glob, Grep, Skill | engineering-standards, test-authoring, plus conditional | ready through in-progress to in-review | Implement, test, self-verify, report. |
| REVIEWER | sonnet | Read, Bash, Glob, Grep, Skill | code-review | in-review | Review the diff. |
| VERIFIER | sonnet | Read, Bash, Glob, Grep, Skill | verification | in-review | Run the artifact via platform-matched QA. |
| COMMITTER | haiku | Read, Bash, Skill | commit | commit | Stage, message, commit, verify, note the SHA. |

Two tool assignments are unique and load-bearing:

- MAESTRO is the ONLY agent that has the Agent tool. It is the only agent that
  dispatches other agents.
- ENGINEER is the ONLY agent that has Write and Edit. It is the only agent that
  modifies files — and it never commits.

The four hard prohibitions. These are non-negotiable and must survive into the
agent files verbatim in intent:

1. MAESTRO is a PURE ROUTER. It authors zero technical content. It intakes,
   clarifies, sizes, dispatches, validates gates, and rolls back — it never
   writes an approach, a risk, a criterion, or code.
2. ENGINEER is the ONLY agent with Write and Edit. It never commits.
3. RISK writes the `risks` field ONLY. It never rewrites the `approach` field.
4. ADVERSARY, on its pre-ship pass, MUST read the real `git diff`. It does not
   attack a remembered or summarized version of the code.

### 2.1 MAESTRO (opus)

Front door of the team. Receives the user's request, clarifies scope with the
user when intent is ambiguous, sizes the task against the fast-path rubric,
drives the lifecycle one stage at a time, validates each gate, rolls a task back
when a gate fails, and dispatches COMMITTER at the end.

MAESTRO is a pure router. It authors zero technical content — no approach, no
risk entry, no acceptance criterion, no line of code. Within a single task's
lifecycle it dispatches exactly one agent at a time, reads that agent's limbo
output, re-grounds against the limbo record, validates the gate for the current
transition, and only then advances or rolls back. (Across independent leaf tasks
it may batch dispatches into one turn — see Section 7; that batching is still one
agent per leaf, never two agents on the same task at once.) It owns the limbo
`status` field.

Loads: lifecycle.

### 2.2 SCOUT (sonnet)

Owns captured to refined. Investigates the codebase to ground the task in
reality, writes at least one testable acceptance criterion, and proposes a task
sizing (trivial or full) for MAESTRO to confirm. SCOUT flags ambiguity and high
blast radius — those flags drive the risk-weighted checkpoint in Section 5.

Loads: codebase-research, project-orientation.

### 2.3 PLANNER (sonnet)

Owns refined to planned. Owns the `approach` field and the test-strategy. The
approach must be concrete and the test-strategy must contain real, runnable test
commands — not placeholders.

PLANNER also raises flags. When its plan-level analysis detects ambiguity or a
high-blast-radius change, PLANNER records a `FLAG: AMBIGUITY` or
`FLAG: HIGH-BLAST-RADIUS` limbo note on the task. Those flag notes drive the
risk-weighted checkpoint (Section 5).

Loads: test-strategy, engineering-standards.

### 2.4 RISK (sonnet)

Owns refined to planned, alongside PLANNER. Writes the `risks` field ONLY. RISK
never rewrites the `approach` field; if RISK finds the approach itself flawed, it
records that as a risk and returns it — it does not edit PLANNER's field.

Loads: risk-analysis.

### 2.5 ADVERSARY (sonnet)

ADVERSARY runs twice in a full task, against two different artifacts at two
different stages. It is not one role; it is two passes. Verdict vocabulary for
both passes: KILL, DEMOTE, REVISE, PASS.

#### 2.5a ADVERSARY pre-build pass (planned to ready)

Attacks the plan. At this stage no code and no diff exist. ADVERSARY reads the
`approach`, the test-strategy, the acceptance criteria, and the `risks` field,
and tries to break the plan: missing cases, wrong assumptions, untestable
criteria, unaddressed risks. Its verdict gates the planned-to-ready transition.

Loads: adversarial-review.

#### 2.5b ADVERSARY pre-ship pass (in-review)

Attacks the code. ADVERSARY MUST read the real `git diff` of the actual change —
not a summary, not a remembered description, not the report. It attacks what was
actually built against what the plan promised. Its verdict is one of the three
inputs to the in-review-to-done gate.

Loads: adversarial-review.

### 2.6 ENGINEER (opus)

Owns ready through in-progress to in-review. Implements the change, writes its tests, runs a
self-verify against the test-strategy, and writes a `report` note. ENGINEER is
the ONLY agent with Write and Edit. ENGINEER never commits — staging and
committing belong to COMMITTER.

Loads: always loads engineering-standards and test-authoring. Loads two further
skills conditionally:

- The docs skill — loaded when the task produces documentation.
- A verification skill — loaded when the task requires platform QA.

When neither condition holds, neither conditional skill is loaded.

### 2.7 REVIEWER (sonnet)

Runs at in-review. Reviews the diff for correctness, convention adherence, and
scope discipline. Verdict: APPROVE, REQUEST_CHANGES, or COMMENT.

The three verdicts have distinct lifecycle effects. APPROVE satisfies the
in-review-to-done gate. REQUEST_CHANGES rolls the task back to in-progress.
COMMENT is advisory only — it neither blocks the task nor rolls it back: the
task advances on the strength of the other in-review verdicts, and the comments
are recorded as limbo notes for the record (Section 4.1, Section 4.2).

Loads: code-review.

### 2.8 VERIFIER (sonnet)

Runs at in-review. Runs the built artifact through a platform-matched QA skill
selected by the verification router. Verdict: PASS, FAIL, or SKIPPED. SKIPPED is
a valid passing outcome when no runnable artifact exists for the change.

Loads: verification.

### 2.9 COMMITTER (haiku)

Owns commit. Stages the change, writes the commit message, commits, verifies the
commit landed, and records the SHA in a limbo note. COMMITTER runs on haiku — it
is a deterministic mechanical step, not a reasoning step.

Loads: commit.

## 3. The Skill Catalog

Skills are the single source of truth. The catalog holds roughly 15 skills.
Each is a thin `SKILL.md` over a deep `reference/` (Section 9).

| Skill | Status | Purpose |
|-------|--------|---------|
| lifecycle | NEW | The stage machine, gates, and rollback rules MAESTRO drives. |
| codebase-research | existing | Investigate an unfamiliar codebase to ground a task. |
| project-orientation | existing | Read project conventions, layout, and entry points. |
| engineering-standards | existing | Engineering conventions for implementation and planning. |
| test-strategy | existing | Design a test-strategy with real, runnable commands. |
| test-authoring | existing | Write the tests that satisfy the strategy. |
| risk-analysis | existing | Enumerate and weight the risks of a planned change. |
| adversarial-review | NEW | Attack a plan, then attack a diff; produce a verdict. |
| code-review | existing | Review a diff for correctness, convention, and scope. |
| verification | existing | Router: pick the platform-matched QA skill. |
| web-verify | existing | QA a web artifact. |
| desktop-verify | existing | QA a desktop artifact. |
| ios-verify | existing | QA an iOS artifact. |
| commit | existing | Stage, message, commit, and verify a change. |
| docs | existing | Author or update project documentation. |

The engineering-standards formula. engineering-standards is the prior
software-engineering skill with its `simaris` dependency removed, replaced by
two static inputs:

```
engineering-standards = software-engineering MINUS simaris
                        + a static conventions KB (bundled in reference/)
                        + reads the project CLAUDE.md (at load time)
```

This formula is load-bearing. The static conventions KB and the project
`CLAUDE.md` are what replace the removed dependency — the skill is not merely
"software-engineering with a feature deleted"; it gains two concrete
substitutes.

Note: `security-checklist` is intentionally absent from this catalog. It is not
a peer skill — it is a shared reference artifact. See Section 9.

## 4. The Lifecycle Workflow

A task moves through eight limbo stages:

```
captured -> refined -> planned -> ready -> in-progress -> in-review -> done -> commit
```

MAESTRO dispatches ONE agent at a time. After each agent returns, MAESTRO reads
that agent's limbo output, re-grounds against the limbo record, validates the
gate for the current transition, and then either advances the task or rolls it
back.

### 4.1 Stage gates

A gate is the condition that must hold before MAESTRO advances a task out of a
stage. The gate criteria are quoted at specification precision — they are not
paraphrased and must not be softened:

| Transition | Gate criterion |
|------------|----------------|
| captured to refined | SCOUT has produced at least one testable acceptance criterion. |
| refined to planned | A concrete `approach` exists, the test-strategy contains real test commands, and the `risks` field is populated. |
| planned to ready | The ADVERSARY pre-build verdict is resolved. |
| ready to in-progress | ENGINEER picks up the task and begins implementation. |
| in-progress to in-review | The build is green. |
| in-review to done | REVIEWER verdict is APPROVE, VERIFIER verdict is PASS or SKIPPED, and the ADVERSARY pre-ship pass is clear. |
| done to commit | COMMITTER stages, commits, verifies, and notes the SHA. |

Trivial-task overrides to these gate criteria are enumerated in S6.

A REVIEWER COMMENT verdict is advisory only: it is not APPROVE and does not on
its own satisfy the in-review-to-done gate, but it does not block the task and
does not roll it back. When the REVIEWER verdict is COMMENT, the gate is decided
by the remaining inputs (the in-review-to-done gate requires an explicit APPROVE
verdict from REVIEWER; a COMMENT does not satisfy it, so a standalone COMMENT
pass leaves the task at in-review until an APPROVE is recorded), and the comments
are kept as limbo notes.

### 4.2 Rollback rules

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

A REVIEWER COMMENT verdict is not a rollback trigger. It is advisory only: the
task neither rolls back nor is forced forward by a COMMENT — the comments are
recorded as limbo notes and the in-review-to-done gate is decided by the other
verdicts (Section 4.1).

KILL is deterministic by pass. A KILL on the ADVERSARY pre-build pass
(planned to ready) rolls the task back to `planned` — the plan failed and the
planning specialists must rework it. A KILL on the ADVERSARY pre-ship pass
(in-review) rolls the task back to `refined` — the built change is unsalvageable
against the requirements, and the task must be re-scoped from its acceptance
criteria forward.

The REVISE procedure. A REVISE verdict does not by itself force a stage
rollback; it is resolved in place before the gate is re-evaluated. The
resolution is a defined sequence MAESTRO drives:

1. MAESTRO re-dispatches the agent that owns the flagged content — ENGINEER for
   code-level findings on the pre-ship pass, or the relevant planning specialist
   (PLANNER for the `approach`, RISK for the `risks` field) for plan-level
   findings on the pre-build pass.
2. The owning agent revises only its own field, addressing the REVISE findings.
3. MAESTRO re-dispatches ADVERSARY for the SAME pass to re-verify the revised
   artifact.
4. Only then is the gate re-evaluated against the fresh ADVERSARY verdict.

When the REVISE findings span multiple owning agents — for example a pre-build
pass that flags both the `approach` (PLANNER) and the `risks` field (RISK) —
MAESTRO re-dispatches each owning agent sequentially in dependency order:
PLANNER first, then RISK. Each agent revises only its own field. ADVERSARY is
re-run exactly once, for the SAME pass, AFTER all owning agents have revised;
the gate is then re-evaluated against that single fresh ADVERSARY verdict.
There is one ADVERSARY re-run per REVISE resolution, never one per owning
agent.

COMMITTER failure. If COMMITTER fails to land the commit — a rejected pre-commit
hook, branch protection, a dirty index, or any other cause — MAESTRO resolves
the underlying cause and re-dispatches COMMITTER. If the cause cannot be
resolved, the task is marked blocked rather than left in a half-committed state.

## 5. The Risk-Weighted Gate

The team is autonomous by default. It runs from intake to commit without asking
the user to approve intermediate steps.

There is exactly one human checkpoint. After the planned stage, and ONLY when
SCOUT or PLANNER has flagged ambiguity or high blast radius, MAESTRO pauses and
presents the user with a 3-line approach summary before continuing. A clear task
— one with no such flag — receives zero interruptions: it runs straight through.

The flag is a concrete signal, not a vibe. SCOUT and PLANNER raise it by
recording a limbo note on the task with a structured, machine-detectable prefix
— `FLAG: AMBIGUITY` or `FLAG: HIGH-BLAST-RADIUS`. When MAESTRO validates the
planned gate, it scans the task's limbo notes for that prefix: if a flag note is
present it triggers the checkpoint, and if none is present it continues
autonomously. The signal is written by SCOUT or PLANNER and read by MAESTRO — no
agent infers the flag from free prose.

This is the risk-weighted gate: human attention is spent only where risk is
flagged, never as a blanket per-stage approval.

## 6. The Fast-Path Rubric

Not every task needs the full eight-stage lifecycle. SCOUT, grounded in the
codebase, proposes a sizing; MAESTRO confirms it.

A task is trivial when ALL of the following hold:

- It touches no more than 2 files.
- It makes no public API or signature change.
- It adds no new dependency.
- It is not security-sensitive.

If any condition fails, the task is full and runs the complete lifecycle.

A trivial task skips RISK and both ADVERSARY passes. It still runs SCOUT,
PLANNER, ENGINEER, REVIEWER, VERIFIER, and COMMITTER. The rubric is
machine-checkable on purpose — file count, API surface, dependency set, and
security sensitivity are all concrete, inspectable facts, not judgment calls.

Because a trivial task runs no ADVERSARY pre-build pass, the planned-to-ready
gate (Section 4.1) has no verdict to resolve. For a trivial task that gate is
simply skipped: the task still advances from planned to ready, just without an
ADVERSARY verdict. A trivial task is never stuck waiting on a gate it does not
run.

The same override applies to the in-review-to-done gate. Because a trivial task
runs no ADVERSARY pre-ship pass, the in-review-to-done gate (Section 4.1) drops
its ADVERSARY-pre-ship-clear input for a trivial task: that gate is satisfied by
REVIEWER APPROVE and VERIFIER PASS or SKIPPED alone. The skipped ADVERSARY
passes are an explicit gate override for trivial tasks, not a stalled gate.

A third override applies to the refined-to-planned gate. Because a trivial task
skips RISK, the risks field is not populated by any agent. For a trivial task
the refined-to-planned gate clause `"the risks field is populated"` (Section
4.1) is suspended: that gate is satisfied by a concrete `approach` and a
test-strategy with real test commands alone. A trivial task is never stuck
waiting on a field no agent is mandated to write.

## 7. Decompose and Fan-Out

A feature too large for a single task is decomposed into child limbo tasks with
explicit dependencies between them.

- Independent leaves — child tasks with no dependency on each other — are
  dispatched concurrently.
- Dependent leaves — child tasks where one needs another's output — run
  sequentially in dependency order.

The concurrency mechanism is concrete. MAESTRO achieves parallelism by emitting
multiple Task tool calls in a SINGLE turn; the runtime then runs those dispatched
calls concurrently. The batched dispatch is scoped to ENGINEER (implementation)
steps: independent leaves at the ready-to-in-progress stage run their ENGINEERs
in parallel. Parallelism is therefore the batched dispatch of independent
ENGINEER steps in one turn — it is not a separate orchestration layer and not
unbounded per-leaf concurrency. Other agents (PLANNER, RISK, REVIEWER, and the
rest) are not dispatched in parallel across leaves; doing so would risk
one-writer-per-field violations.

This bounds what runs in parallel. MAESTRO still drives each leaf's lifecycle
itself: it batches the independent ENGINEER steps across leaves into a single
turn, reads the returns, and advances each leaf one stage at a time. Where leaf
lifecycles cannot be cleanly batched into one turn, those steps are serialized.
Decomposition does not waive the lifecycle for any child: each child task runs
its own stage machine, its own gates, and its own rollback rules, all driven by
MAESTRO.

## 8. The Canonical Agent File Template

Every agent file is a Markdown file with YAML frontmatter and a body. The body
carries the soul block, the mandate, the handoff contract, and the
skill-binding. The template below is canonical — every agent file conforms to
it.

```markdown
---
name: <agent-name>
description: <one-line role summary; tells MAESTRO when to dispatch this agent>
tools: <space-separated tool list — exact, per Section 2>
model: <opus | sonnet | haiku>
---

# You are the <ROLE>

<Soul block, part 1 — Identity: what this agent is and the craft it owns.>

<Soul block, part 2 — Creed: the standard it holds itself to; its integrity.>

<Soul block, part 3 — Bar: its definition of done. It refuses to pass shoddy
work — state the exact bar it will not drop below.>

## Mandate

<Purpose: the lifecycle stage(s) this agent owns and the single outcome it
delivers.>

<Constraints: the hard prohibitions that bound this agent — quoted verbatim in
intent from Section 2 where applicable.>

## Inputs

<Handoff contract, in: the limbo fields this agent reads to re-ground itself
before it acts.>

## Outputs

<Handoff contract, out: the limbo field(s) this agent writes — and only those.
One writer per field.>

## Workflow

<The ordered steps the agent runs. The first step is always: re-ground against
the source (limbo record and codebase).>

## Skills

<Skill-binding: the skills this agent loads on demand, and the explicit
condition for any conditional load.>

## What you do NOT do

<The explicit out-of-scope list.>
```

How the template maps to existing agent files. Agent files on disk already use
the body sections `# You are the X`, `Inputs`, `Outputs`, `Workflow`, and
`Rules`. The canonical template maps onto them directly, so the later build
tasks produce conforming files:

| Template element | Existing body section |
|------------------|-----------------------|
| Soul block (identity / creed / bar) | The opening paragraphs under `# You are the X` |
| Mandate (purpose + constraints) | `Rules`, plus the purpose statement |
| Handoff contract | `Inputs` and `Outputs` |
| Skill-binding | A new explicit `## Skills` section |

## 9. Skill File Conventions

Skills are the single source of truth, so their structure carries full weight.
Every skill is built from two layers — a thin entry point and a deep reference —
so that an agent loads only what its current task needs.

### 9.1 Thin SKILL.md

The `SKILL.md` is the entry point. It is deliberately thin: it tells the agent
what the skill is for and how to start, then points at the reference layer for
depth. Its structure:

```markdown
---
name: <skill-name>
description: <what this skill does and when to use it>
triggers:
  - <phrase or intent that should activate this skill>
---

# <Skill Title>

## Activation Protocol

<When the agent should engage this skill, and what it must have in hand first.>

## Workflow

<The ordered, high-level steps. Each step points to a reference/ file for the
detail rather than inlining a checklist or procedure here.>

## Reference

<A footer that lists the reference/*.md files and says when to read each one.>
```

### 9.2 Deep reference/ directory

Procedures, checklists, conventions, and worked detail live in `reference/*.md`
files beside the `SKILL.md`. This is progressive disclosure: the `SKILL.md` is
always cheap to load, and an agent reads a `reference/` file only when its
workflow step calls for that depth. No procedure or checklist is duplicated into
an agent file — the agent loads the skill, and the skill discloses its
reference progressively.

Each `reference/*.md` file holds focused deep knowledge on exactly one
sub-topic, loaded on demand by the `SKILL.md` when a workflow step calls for
that depth. Its structure:

```markdown
# <Reference Topic>

## Purpose

<The single sub-topic this file covers, and which `SKILL.md` workflow step
loads it.>

## Content

<The focused deep knowledge in full detail: the procedure, checklist, or
convention. One sub-topic per file — a second sub-topic goes in its own
reference file rather than being appended here.>
```

### 9.3 security-checklist as a shared reference

`security-checklist` is NOT a peer skill in the catalog. It is a single shared
reference artifact — one `reference/*.md` file — consumed by TWO skills:

- risk-analysis reads it when enumerating the security risks of a planned
  change.
- code-review reads it when reviewing a diff for security defects.

The file has one canonical home: `skills/risk-analysis/reference/security-checklist.md`.
risk-analysis is its owning skill. code-review does NOT keep its own copy — it
reads the same file by relative path
(`../../risk-analysis/reference/security-checklist.md`). There is exactly one
file on disk; the second skill borrows it rather than forking a divergent copy.

It is documented here, in the conventions section, rather than in the Section 3
catalog, because it is a reference artifact and not a skill an agent loads
directly. Keeping it as one shared file — rather than two divergent copies —
preserves the single-source-of-truth principle for security guidance.

## 10. Red-Team Blocker Fixes

The locked specification recorded six red-team blockers, all resolved. This
architecture encodes every one of them. All six are listed here so no later
build task drops one:

1. engineering-standards uses a static conventions KB plus the project
   `CLAUDE.md` instead of an external knowledge service. The skill no longer
   depends on any external memory or knowledge service for its conventions.
2. A risk-weighted gate was added. The team is autonomous by default; the user
   is checkpointed only after planned and only when ambiguity or high blast
   radius is flagged (Section 5).
3. One writer per limbo field. Each limbo field has exactly one owning agent —
   RISK writes `risks`, PLANNER writes `approach`, and so on — so fields cannot
   be silently overwritten by a second agent.
4. The adversarial-review pre-ship pass reads the real `git diff`. ADVERSARY's
   second pass attacks the actual code that was built, never a summary or a
   remembered description (Section 2.5b).
5. A machine-checkable fast-path rubric. Triviality is decided by concrete,
   inspectable facts — file count, API surface, dependency set, security
   sensitivity — not by judgment (Section 6).
6. MAESTRO authors zero technical content, and every technical agent re-grounds
   against source. MAESTRO is a pure router; each technical agent re-reads the
   limbo record and the codebase before it acts, so no agent operates on a stale
   or remembered view of the task.
