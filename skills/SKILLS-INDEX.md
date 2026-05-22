# Skills Index

Quick reference for the 15 skills of the Specialist Guild — what each is for, who
loads it, and how they compose across the task lifecycle. Skills are the single
source of truth; agents are lean shells that load skills on demand.

| Skill | Purpose | Loaded by | Composes with |
|-------|---------|-----------|---------------|
| **lifecycle** | The 8-stage task machine, gate criteria, rollback rules, risk-weighted gate, fast-path rubric, and fan-out logic | MAESTRO (every task) | all agents — MAESTRO routes the work the other skills do |
| **codebase-research** | Investigate an unfamiliar codebase to ground a task before design decisions | SCOUT | project-orientation (docs orientation), engineering-standards (conventions) |
| **project-orientation** | Read project conventions, layout, and entry points via progressive-disclosure docs | SCOUT | codebase-research (deep-dive complement) |
| **engineering-standards** | Engineering conventions for implementation and planning; static conventions KB, reads project CLAUDE.md at load time | PLANNER, ENGINEER | test-strategy (planning), test-authoring (implementation), code-review (review bar) |
| **test-strategy** | Detect the test framework and plan the test cases with real, runnable commands before any test is written | PLANNER | engineering-standards (conventions), test-authoring (implements the strategy) |
| **test-authoring** | Write the tests that satisfy the strategy, run suites, analyze coverage, report results | ENGINEER | test-strategy (consumes its strategy), engineering-standards (conventions) |
| **risk-analysis** | Enumerate and weight the risks of a planned change before code is written | RISK | engineering-standards (conventions), code-review (shares the security checklist) |
| **adversarial-review** | Attack a plan (pre-build) or a git diff (pre-ship); produce a KILL/DEMOTE/REVISE/PASS verdict | ADVERSARY | lifecycle (verdict drives the gates and rollback rules) |
| **code-review** | Review a diff for correctness, convention adherence, and scope discipline | REVIEWER | engineering-standards (conventions), risk-analysis (shared security checklist), test-authoring (coverage check) |
| **verification** | Router — auto-detect the project type and route to the platform-matched QA skill | VERIFIER | web-verify, desktop-verify, ios-verify |
| **web-verify** | QA a web artifact via the khora CLI and Chrome DevTools Protocol | ENGINEER (conditional), VERIFIER (via router) | verification (router), desktop-verify (sibling pattern) |
| **desktop-verify** | QA a macOS desktop artifact via the loki CLI | ENGINEER (conditional), VERIFIER (via router) | verification (router), ios-verify (sibling pattern) |
| **ios-verify** | QA an iOS artifact on simulator or device | ENGINEER (conditional), VERIFIER (via router) | verification (router), desktop-verify (sibling pattern) |
| **commit** | Stage, message, commit, and verify a change with mandatory checks | COMMITTER | code-review (verified diff feeds the commit), docs (freshness gate) |
| **docs** | Author or update project documentation to reflect code changes | ENGINEER (conditional) | project-orientation (reads what docs writes), commit (docs freshness gate) |

## Composition Patterns

The patterns below trace the lifecycle in `docs/dev/team-architecture.md`
Sections 2 and 4. MAESTRO drives every task one stage at a time, dispatching
exactly one agent per stage, validating each gate, and rolling back when a gate
fails.

### Full task lifecycle (captured → commit)
1. **SCOUT** (`codebase-research`, `project-orientation`) — investigate, write at least one testable acceptance criterion, propose sizing. `captured → refined`.
2. **PLANNER** (`test-strategy`, `engineering-standards`) — author the `approach` and a test-strategy with real commands. **RISK** (`risk-analysis`) — write the `risks` field. `refined → planned`.
3. **ADVERSARY** pre-build pass (`adversarial-review`) — attack the plan; verdict gates the transition. `planned → ready`.
4. **ENGINEER** (`engineering-standards`, `test-authoring`) — implement, write tests, self-verify against the strategy, write a `report`. `ready → in-progress → in-review`.
5. **REVIEWER** (`code-review`), **VERIFIER** (`verification` → platform QA skill), **ADVERSARY** pre-ship pass (`adversarial-review`, reads the real `git diff`) — the three in-review verdicts. `in-review → done`.
6. **COMMITTER** (`commit`) — stage, message, commit, verify, note the SHA. `done → commit`.

### Trivial task (fast path)
A task that touches ≤2 files, makes no public API change, adds no dependency, and
is not security-sensitive skips **RISK** and both **ADVERSARY** passes. It still
runs SCOUT, PLANNER, ENGINEER, REVIEWER, VERIFIER, and COMMITTER. The skipped
gates are an explicit override — the task is never stuck waiting on a gate it
does not run.

### Documentation change
When the task produces documentation, **ENGINEER** loads the `docs` skill in
addition to `engineering-standards` and `test-authoring`. The `commit` skill's
docs-freshness gate then confirms docs and code landed together.

### Platform QA
When the task produces a runnable artifact, **VERIFIER** loads `verification`,
which routes to `web-verify`, `desktop-verify`, or `ios-verify` by platform.
**ENGINEER** may load the matching verification skill during implementation to
exercise the artifact before handing off.

### Decompose and fan-out
A feature too large for one task is decomposed into child limbo tasks with
explicit dependencies. MAESTRO batches the **ENGINEER** steps of independent
leaves into a single turn so they run concurrently; dependent leaves run in
dependency order. Each child still runs its own full stage machine and gates.

### Plan rework (REVISE / DEMOTE / KILL)
When ADVERSARY's pre-build verdict is not PASS, MAESTRO re-dispatches the owning
planning agent — **PLANNER** for the `approach`, **RISK** for the `risks` field —
which revises only its own field. ADVERSARY then re-runs the same pass once, and
the gate is re-evaluated against that fresh verdict.
