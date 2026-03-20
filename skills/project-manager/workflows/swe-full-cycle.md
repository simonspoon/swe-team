# SWE Full Cycle Workflow

For end-to-end software engineering: issue → plan → implement → test → review → retrospective → merge.

> **Note:** All `limbo add` calls require `--action`, `--verify`, `--result` flags. All `limbo status <id> done` calls require `--outcome`. Examples below use abbreviated form for readability — fill in the structured fields for each task when creating.

## When to Use

Use this workflow when the task requires the full engineering cycle — not just implementation, but also testing, review, and delivery. Choose a simpler workflow (feature.md, bug-fix.md) when only some phases are needed.

## Skills Involved

| Phase | Skill | Purpose |
|-------|-------|---------|
| Plan | `/software-engineering` | Load conventions, architecture knowledge |
| Plan | `/project-docs-explore` | Understand existing codebase |
| Plan | `/code-index` | Generate structural map of unfamiliar code |
| Implement | (subagents) | Write code per task decomposition |
| Test | `/test-engineer` | Generate tests, run suites, analyze coverage |
| Review | `/code-reviewer` | Review diffs for bugs, security, conventions |
| Review | `/simplify` | Analyze changed code for unnecessary complexity |
| CI/CD | `/devops` | Create/update CI pipeline if needed |
| Retrospective | `/software-engineering`, `/skill-reflection` | Capture lessons, fix skill/workflow gaps |
| Deliver | `/update-docs` | Update project docs to reflect changes |

## Task Hierarchy Pattern

```
SWE: <description>
├── Plan
│   ├── Research & understand requirements
│   ├── Explore codebase (project-docs-explore, code-index)
│   ├── Design approach
│   └── Define test plan (acceptance criteria)
├── Implement
│   ├── Core changes
│   └── Supporting changes
├── Test
│   ├── Generate tests (from test plan)
│   ├── Run test suite
│   └── Coverage analysis
├── Review
│   ├── Code review (code-reviewer)
│   ├── Simplify pass (simplify) — optional
│   └── Address review feedback
├── CI/CD (if needed)
│   └── Update pipeline (devops)
├── Completion Gate (MANDATORY)
│   └── Verify all phases executed with evidence
├── Retrospective (MANDATORY)
│   ├── Answer 3 questions
│   └── Create follow-up tasks for findings
└── Deliver
    ├── Update docs (update-docs)
    ├── Commit
    └── Create PR
```

## Step-by-Step

### 1. Plan Phase

Load context before decomposing:

```bash
# Load skills (orchestrator does this, not subagents)
# /software-engineering — conventions and preferences
# /project-docs-explore — architecture docs
# /code-index — structural map of unfamiliar areas (optional, use when codebase is new)
```

Create the root and plan tasks:

```bash
limbo add "SWE: <description>"                           # → root
limbo add "Plan" --parent root                           # → plan
limbo add "Research requirements" --parent plan          # → req
limbo add "Explore codebase" --parent plan               # → expl
limbo add "Design approach" --parent plan                # → dsgn
limbo add "Define test plan" --parent plan               # → tpln

limbo block req dsgn    # Design after requirements
limbo block expl dsgn   # Design after exploration
limbo block dsgn tpln   # Test plan after design
```

**Test plan (MANDATORY):** Before implementation begins, define acceptance criteria as a concrete test plan. This must include:
- What behaviors must be tested (happy path, edge cases, error cases)
- What existing behavior must be preserved
- What conventions/patterns tests must follow
- Specific scenarios that constitute "done"

The test plan becomes the input for the Test phase — test generation implements the plan, not ad-hoc coverage.

### 2. Implement Phase

```bash
limbo add "Implement" --parent root                      # → impl
limbo add "Core: <main change>" --parent impl            # → core
limbo add "Support: <secondary>" --parent impl           # → supp

limbo block plan impl   # Implement after plan
```

Dispatch core and support tasks to subagents in parallel (if no file conflicts).

### 3. Test Phase

Use `/test-engineer` for test generation and coverage:

```bash
limbo add "Test" --parent root                           # → test
limbo add "Generate tests for changed code" --parent test  # → tgen
limbo add "Run full test suite" --parent test            # → trun
limbo add "Coverage analysis" --parent test              # → tcov

limbo block impl test   # Test after implement
limbo block tgen trun   # Run after generation
limbo block trun tcov   # Coverage after run
```

Subagent prompt for test generation should include:
- Files that were changed (from implement phase)
- The test-engineer skill activation protocol
- Framework detection commands
- Expected output format

**Refactoring note:** When the implement phase is a refactoring (extracting modules, splitting files), the test generation task MUST generate tests for newly created modules, not just verify existing tests still pass. Include in the subagent prompt: "Generate tests for any newly extracted modules that don't have their own test coverage."

### 4. Review Phase

Use `/code-reviewer` on all changes:

```bash
limbo add "Review" --parent root                         # → rev
limbo add "Code review" --parent rev                     # → crev
limbo add "Address feedback" --parent rev                # → addr

limbo block test rev     # Review after tests pass
limbo block crev addr    # Address after review
```

The code review task should:
1. Run `git diff main..HEAD` (or appropriate base)
2. Apply the code-reviewer activation protocol
3. Produce structured output (Critical/Warnings/Info/Verdict)
4. If verdict is REQUEST CHANGES, the "Address feedback" task becomes active

**Simplify pass (optional):** After code review, run `/simplify` on changed files to catch unnecessary complexity (dead code, over-abstraction, duplication). Skip this for trivial changes. If simplify finds issues, fold them into the "Address feedback" task.

If review passes with APPROVE and no simplify findings, mark "Address feedback" as done with outcome "No changes needed."

### 5. CI/CD Phase (Optional)

Only if the project needs a new or updated pipeline:

```bash
limbo add "CI/CD" --parent root                          # → cicd
limbo add "Update CI pipeline" --parent cicd             # → pipe

limbo block impl cicd   # CI after implement (can parallel with test)
```

### 6. Completion Gate (MANDATORY)

**Do NOT skip this step.** Before delivery, the orchestrator must verify every phase actually executed and produce evidence.

```bash
limbo add "Completion gate" --parent root                # → gate
limbo block rev gate     # Gate after review

limbo add "Deliver" --parent root                        # → dlvr
limbo block gate dlvr    # Deliver BLOCKED on gate
```

To pass the gate, the orchestrator must verify ALL of the following and record the evidence in the gate task outcome:

1. **Plan phase**: Test plan was defined with acceptance criteria
2. **Implement phase**: Code was written and builds clean
3. **Test phase**: Tests were generated from the test plan, suite passes, coverage analyzed
4. **Review phase**: Code review ran with structured output, verdict was APPROVE (or feedback was addressed and re-review passed)
5. **CI/CD phase**: Pipeline updated if needed (or explicitly noted as not needed)

Evidence format for the gate outcome:
```
Plan: test plan defined [N acceptance criteria]
Implement: [N files changed], builds clean
Test: [N tests], all pass, coverage [X%]
Review: verdict [APPROVE/REQUEST CHANGES→fixed→APPROVE]
CI/CD: [updated/not needed]
```

If ANY phase lacks evidence, **do NOT pass the gate**. Go back and execute the missing phase.

### 7. Retrospective (MANDATORY)

After the gate passes, conduct a brief retrospective before delivery. This is how the team evolves.

```bash
limbo add "Retrospective" --parent root                  # → retro
limbo block gate retro   # Retro after gate passes

limbo add "Deliver" --parent root                        # → dlvr
limbo block retro dlvr   # Deliver BLOCKED on retro
```

Answer these 3 questions:

**1. What phase caused the most friction?**
Identify the phase that was hardest, took longest, or produced the weakest results. This points to skill/workflow gaps.

**2. Did the test plan match what was actually tested?**
Compare the acceptance criteria from the plan phase to the tests that were generated. Gaps indicate planning needs improvement. Over-testing indicates the plan was too vague.

**3. Any lesson worth saving?**
Conventions discovered, preferences to capture, mistakes to avoid. Only save things that apply to future work — not one-off observations.

**Where findings go:**

| Finding type | Action | Destination |
|-------------|--------|-------------|
| Skill produced wrong/incomplete output | Fix the skill's docs directly, or run `/skill-reflection` | Skill's SKILL.md or reference files |
| New convention or preference | Save via `/software-engineering` preference capture | `software-engineering/preferences/` |
| Workflow gap (missing step, wrong ordering) | Update the workflow template directly | `workflows/swe-full-cycle.md` or other template |
| Tool limitation or missing capability | Create a follow-up task or note for user | Limbo task or user communication |
| Nothing noteworthy | Record "No findings" — this is a valid outcome | Gate task outcome |

**Follow-up tasks have teeth:** If the retrospective identifies a gap, create a concrete follow-up task (in limbo or communicated to the user). Do NOT just note it and move on — that's how gaps persist.

Record the retrospective in the task outcome:
```
Friction: [phase] — [what happened]
Test plan accuracy: [matched/gaps/over-tested] — [details]
Lesson: [saved to X / none]
Follow-up: [task created / none needed]
```

### 8. Deliver Phase

Before committing, update docs to reflect the changes being shipped:

```bash
limbo add "Update docs" --parent dlvr                    # → docs
limbo add "Create commit" --parent dlvr                  # → cmit
limbo add "Create PR" --parent dlvr                      # → pr

limbo block docs cmit    # Commit after docs updated
limbo block cmit pr      # PR after commit
```

Run `/update-docs` for the docs task — it discovers existing doc structure and makes targeted updates for affected docs. Skip if changes are purely internal with no doc-facing impact.

## Dependency Graph

```
req ──┐
      ├→ dsgn → tpln → impl ──→ test ──→ rev ──→ gate ──→ retro ──→ dlvr (docs → cmit → pr)
expl ─┘                     │         ↗
                             └→ cicd ─┘ (optional)
```

## Wave Execution

- **Wave 1**: req + expl (parallel research; use `/code-index` if codebase is unfamiliar)
- **Wave 2**: dsgn (depends on both)
- **Wave 3**: tpln (test plan from design)
- **Wave 4**: core + supp (parallel implementation)
- **Wave 5**: tgen + cicd (parallel — tests + CI)
- **Wave 6**: trun → tcov (sequential test execution)
- **Wave 7**: crev (review all changes)
- **Wave 8**: simplify pass + addr (if review/simplify has feedback)
- **Wave 9**: gate (verify all phases, produce evidence)
- **Wave 10**: retro (retrospective — capture lessons, create follow-ups)
- **Wave 11**: docs → cmit → pr (update docs, commit, deliver)

## Review Loop

If code review returns REQUEST CHANGES:
1. Mark "Code review" as done with outcome noting the issues
2. "Address feedback" becomes the active task
3. After addressing feedback, add a new "Re-review" task
4. Block delivery on re-review
5. Maximum 2 review iterations before escalating to user

## Example: Add User Search Feature (Full Cycle)

```bash
limbo add "SWE: Add user search to admin panel"          # → root

# Plan
limbo add "Plan search feature" --parent root             # → plan
limbo add "Research search requirements" --parent plan    # → req
limbo add "Explore admin panel code" --parent plan        # → expl
limbo add "Design search approach" --parent plan          # → dsgn
limbo add "Define test plan" --parent plan                # → tpln

# Implement
limbo add "Implement search" --parent root                # → impl
limbo add "Add search API endpoint" --parent impl         # → api
limbo add "Add search UI component" --parent impl         # → ui

# Test
limbo add "Test search" --parent root                     # → test
limbo add "Generate search tests" --parent test           # → tgen
limbo add "Run test suite" --parent test                  # → trun

# Review
limbo add "Review search" --parent root                   # → rev
limbo add "Code review" --parent rev                      # → crev
limbo add "Address feedback" --parent rev                 # → addr

# Completion gate + Retrospective
limbo add "Completion gate" --parent root                 # → gate
limbo add "Retrospective" --parent root                   # → retro

# Deliver
limbo add "Deliver search" --parent root                  # → dlvr
limbo add "Update docs" --parent dlvr                     # → docs
limbo add "Commit changes" --parent dlvr                  # → cmit
limbo add "Create PR" --parent dlvr                       # → pr

# Dependencies
limbo block req dsgn
limbo block expl dsgn
limbo block dsgn tpln
limbo block plan impl
limbo block impl test
limbo block tgen trun
limbo block test rev
limbo block crev addr
limbo block rev gate
limbo block gate retro
limbo block retro dlvr
limbo block docs cmit
limbo block cmit pr
```

Back to [INDEX.md](INDEX.md) | [SKILL.md](../SKILL.md)
