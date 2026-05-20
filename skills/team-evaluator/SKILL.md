---
name: team-evaluator
description: Evaluate the SWE agent team's capabilities by running benchmarks, scoring results, and identifying gaps. Use when evaluating team performance, running benchmarks, auditing agent capabilities, identifying skill gaps, or assessing team readiness.
---

# Team Evaluator

Evaluate the SWE agent team by running structured benchmarks, scoring results, and producing actionable improvement recommendations.

## Activation Protocol

1. Read `reference/benchmark-catalog.md` for available benchmark tasks.
2. Read `reference/scoring-rubric.md` for the evaluation criteria.
3. Read the current team roster. The team is **both skills and agents**:
   - Skills — read `../SKILLS-INDEX.md` (the index lives one directory up, alongside this skill).
   - Agents — list `../../agents/` (each `*.md` file is one agent definition).
4. Determine evaluation scope (see "Evaluation Modes" below).
5. Run benchmarks, score results, produce report.

## Evaluation Levels

The team is exercised at two distinct levels. Every benchmark declares which level it runs at (see the `Level` field in the benchmark catalog).

**Skill-level:**
Invoke a single skill directly in the current session via its documented activation (e.g. `/swe-team:code-reviewer`). Scores that one skill in isolation. Best for single-skill regression checks — fast, cheap, narrow.

**Pipeline-level:**
Dispatch the `swe-team:project-manager` agent with the benchmark task and score the end-to-end result. This exercises the *actual* team workflow — the PM decomposes the task into limbo tasks, dispatches the tech-lead per leaf, runs the stage-gate agents (risk-assessor, test-engineer at refined→planned; code-reviewer, verifier at in-review), and commits via the committer. Scores decomposition quality, implementation, and verification together. Best for evaluating the team as a system, not its parts.

A skill-level benchmark answers "is this skill still good?"; a pipeline-level benchmark answers "does the team ship correct work end-to-end?". Most agent-coverage benchmarks are pipeline-level because agents only run inside the pipeline.

## Evaluation Modes

**Full team evaluation:**
Run benchmarks across all categories, at both levels. Produces a comprehensive team capability map.

**Single skill/agent evaluation:**
Run benchmarks relevant to one skill or agent. For a skill, use skill-level benchmarks. For an agent, use pipeline-level benchmarks (agents run inside the pipeline). Produces a focused capability report.

**Gap analysis:**
Compare current team capabilities against a target workflow. Identifies missing skills, weak agents, or pipeline-stage gaps.

**Regression check:**
Re-run previously failed benchmarks to measure improvement after changes. Run them at the same level as the original to keep scores comparable.

## Benchmark Categories

Read `reference/benchmark-catalog.md` for the full catalog. Summary:

| Category | Level | Tests | Skills/Agents Exercised |
|----------|-------|-------|------------------------|
| Bug Fix | Skill | Diagnose and fix a known bug | software-engineering, code-reviewer |
| Feature Implementation | Skill | Build a small feature from spec | software-engineering, tech-lead |
| Code Review | Skill | Review code with planted issues | code-reviewer, software-engineering |
| Test Generation | Skill | Generate tests for existing code | test-engineer, software-engineering |
| CI/CD Setup | Skill | Create pipeline for a project | devops, test-engineer |
| Refactoring | Skill | Improve code without changing behavior | software-engineering, code-reviewer |
| Agent / Pipeline | Pipeline | Dispatch the PM and score end-to-end team behavior | project-manager, tech-lead, risk-assessor, test-engineer, code-reviewer, verifier, committer, researcher |

The first six categories are **skill-level** — they invoke a skill directly. The **Agent / Pipeline** category is **pipeline-level** — each benchmark dispatches `swe-team:project-manager` and scores the workflow that runs underneath it.

## Evaluation Workflow

### Step 1: Select Benchmarks

For full evaluation, run at least one benchmark per category (7 minimum — the six skill-level categories plus Agent / Pipeline).
For focused evaluation on a **skill**, select 2-3 skill-level benchmarks matching it (prioritize benchmarks where the skill is the primary exercised skill, not just a supporting one).
For focused evaluation on an **agent**, select Agent / Pipeline benchmarks that exercise it — agents only run inside the pipeline, so a pipeline-level benchmark is the only way to score them.
For gap analysis, select benchmarks that cover each skill and agent involved in the target workflow.

Each benchmark's `Level` field tells you how to run it (see Step 3). List selected benchmarks — and their levels — for the user before proceeding.

### Step 2: Prepare Test Environment

For each benchmark:
1. Create a temporary working directory under `/tmp/team-eval/`.
2. Set up the benchmark scenario (scaffold code, plant bugs, create specs).
3. Verify the setup is correct before running the evaluation.

### Step 3: Run Benchmarks

For each benchmark, run it according to its `Level` field:

**Skill-level benchmarks:**
1. Record the start state.
2. Invoke the target skill via its documented activation (e.g., `/swe-team:software-engineering` or `/swe-team:code-reviewer`) directly in the current session. For benchmarks requiring composition of multiple skills, invoke them in sequence as the workflow dictates.
3. Capture all output and artifacts.
4. Record the end state and elapsed time.

**Pipeline-level benchmarks:**
1. Record the start state (scaffolded repo, planted issues, spec).
2. Dispatch the `swe-team:project-manager` agent with the benchmark task as its single task. Do NOT invoke skills directly — the point is to exercise the real pipeline (PM decomposition → tech-lead per leaf → stage-gate agents → committer).
3. Let the pipeline run end-to-end. Capture the limbo task tree, the produced diff/commits, and any verification output.
4. Record the end state and elapsed time.
5. Score the *end-to-end* result: was the task correctly decomposed, correctly implemented, and correctly verified? A pipeline benchmark scores the team as a system — a weak score points at a stage, not just a skill (see Step 5 root-cause analysis).

Scaffold benchmark code in the language most natural for the scenario (default to Python or JavaScript/TypeScript unless the benchmark specifies otherwise).

If a benchmark fails to run (tool error, timeout, missing environment), mark it as INCOMPLETE and note the reason. If a pipeline-level benchmark requires a live application the eval environment cannot provide (e.g. verifier needs khora/loki/qorvex against a running app), mark the agent's coverage as a documented limitation rather than forcing a synthetic result.

### Step 4: Score Results

Apply the scoring rubric from `reference/scoring-rubric.md`. Score each benchmark on:

- **Correctness** (0-3): Does the output solve the stated problem?
- **Completeness** (0-3): Are edge cases handled? Is nothing missing?
- **Quality** (0-3): Is the output well-structured, clean, and maintainable?
- **Convention adherence** (0-3): Does it follow project conventions and best practices?

Score definitions:
- 0 = Not attempted or completely wrong
- 1 = Partial attempt, major issues
- 2 = Mostly correct, minor issues
- 3 = Excellent, no issues

### Step 5: Analyze Gaps

After scoring all benchmarks:
1. Identify categories scoring below 2.0 average.
2. For each low-scoring area, determine root cause:
   - Skill missing entirely
   - Skill exists but instructions are weak
   - Skill exists but doesn't cover this scenario
   - Agent composition issue (skills don't work together)
   - Pipeline-stage failure — for Agent / Pipeline benchmarks, attribute the weakness to a specific stage: decomposition (PM), implementation (tech-lead), refined→planned gate (risk-assessor / test-engineer), or in-review gate (code-reviewer / verifier). A pipeline benchmark that fails tells you *which stage* leaked, not just which skill.
3. Rank gaps by impact (how often this capability is needed).

### Step 6: Produce Report

Use the Evaluation Report Format below. Always include specific, actionable recommendations.

## Evaluation Report Format

```markdown
## Team Evaluation Report
Date: [YYYY-MM-DD]
Scope: [Full team | Skill: name | Agent: name | Gap analysis]

### Team Roster
| Skill/Agent | Version/Last Modified |
|-------------|---------------------|

### Benchmark Results
| # | Benchmark | Category | Correctness | Completeness | Quality | Conventions | Total | Verdict |
|---|-----------|----------|-------------|--------------|---------|-------------|-------|---------|
(list ALL benchmarks)

### Category Averages
| Category | Avg Score | Rating |
|----------|-----------|--------|
(GREEN >= 2.5, YELLOW >= 1.5, RED < 1.5)

### Gaps Identified
| Gap | Severity | Root Cause | Affected Workflows |
|-----|----------|------------|-------------------|

### Recommendations
1. [Specific, actionable recommendation with priority]
2. [Next recommendation]

### Comparison with Previous Evaluation
(If previous evaluation exists, show score changes)
```

## Tracking Evaluation History

After each evaluation, append a summary to `reference/evaluation-history.md`:

```markdown
## [YYYY-MM-DD] — [Scope]
Overall: [avg score]/12
Strengths: [top categories]
Gaps: [weak categories]
Key recommendation: [most impactful recommendation]

### Per-Benchmark Scores
| Benchmark | Score | Verdict |
|-----------|-------|---------|
(list all benchmarks run in this evaluation)
```

Compare with previous entries to track improvement trends. The per-benchmark scores enable regression checks — when re-evaluating, compare individual benchmark scores against the most recent entry.

**Regression check with no history:** If no previous evaluations exist, run a full evaluation first to establish a baseline, then note in the report that this is the initial evaluation (no prior results to compare against).

## Example: Evaluating the Code Review Skill

**Benchmark:** Review a Python file with 3 planted bugs (SQL injection, unclosed file handle, off-by-one error).

**Run:** Invoke `/swe-team:code-reviewer` on the file.

**Score:**
- Correctness: 3 (found all 3 bugs)
- Completeness: 2 (missed the off-by-one edge case variant)
- Quality: 3 (clear report format, actionable suggestions)
- Conventions: 3 (followed review output format)
- Total: 11/12

**Verdict:** PASS

## Cleanup

After evaluation is complete:
1. Remove the temporary working directory: `rm -rf /tmp/team-eval/`
2. Verify no leftover artifacts remain from benchmark scaffolding.
3. Do NOT remove the evaluation history entry — that is permanent.

## When to Stop and Ask

- User hasn't specified evaluation scope — ask which mode
- Benchmark requires a tool or environment not available — flag it
- Results are ambiguous (skill partially succeeded) — present to user for judgment
- Recommendations would require significant skill rewrites — confirm priority with user

## Reference

- [reference/benchmark-catalog.md](reference/benchmark-catalog.md) — Full benchmark task catalog
- [reference/scoring-rubric.md](reference/scoring-rubric.md) — Detailed scoring criteria
- [reference/evaluation-history.md](reference/evaluation-history.md) — Past evaluation results
