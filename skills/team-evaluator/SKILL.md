---
name: team-evaluator
description: Evaluate the SWE agent team's capabilities by running benchmarks, scoring results, and identifying gaps. Use when evaluating team performance, running benchmarks, auditing agent capabilities, identifying skill gaps, or assessing team readiness.
---

# Team Evaluator

Evaluate the SWE agent team by running structured benchmarks, scoring results, and producing actionable improvement recommendations.

## Activation Protocol

1. Read `reference/benchmark-catalog.md` for available benchmark tasks.
2. Read `reference/scoring-rubric.md` for the evaluation criteria.
3. Read `~/.claude/skills/SKILLS-INDEX.md` to know the current team roster.
4. Determine evaluation scope (see "Evaluation Modes" below).
5. Run benchmarks, score results, produce report.

## Evaluation Modes

**Full team evaluation:**
Run benchmarks across all categories. Produces a comprehensive team capability map.

**Single skill/agent evaluation:**
Run benchmarks relevant to one skill or agent. Produces a focused capability report.

**Gap analysis:**
Compare current team capabilities against a target workflow. Identifies missing skills or weak areas.

**Regression check:**
Re-run previously failed benchmarks to measure improvement after changes.

## Benchmark Categories

Read `reference/benchmark-catalog.md` for the full catalog. Summary:

| Category | Tests | Skills/Agents Exercised |
|----------|-------|------------------------|
| Bug Fix | Diagnose and fix a known bug | software-engineering, code-reviewer |
| Feature Implementation | Build a small feature from spec | software-engineering, project-manager |
| Code Review | Review code with planted issues | code-reviewer, software-engineering |
| Test Generation | Generate tests for existing code | test-engineer, software-engineering |
| CI/CD Setup | Create pipeline for a project | devops, test-engineer |
| Refactoring | Improve code without changing behavior | software-engineering, code-reviewer |

## Evaluation Workflow

### Step 1: Select Benchmarks

For full evaluation, run at least one benchmark per category (6 minimum).
For focused evaluation, select 2-3 benchmarks matching the target skill (prioritize benchmarks where the skill is the primary exercised skill, not just a supporting one).
For gap analysis, select benchmarks that cover each skill involved in the target workflow.

List selected benchmarks for the user before proceeding.

### Step 2: Prepare Test Environment

For each benchmark:
1. Create a temporary working directory under `/tmp/team-eval/`.
2. Set up the benchmark scenario (scaffold code, plant bugs, create specs).
3. Verify the setup is correct before running the evaluation.

### Step 3: Run Benchmarks

For each benchmark:
1. Record the start state.
2. Invoke the target skill or agent with the benchmark task. Invocation method: use the skill's documented activation (e.g., `/swe-team:software-engineering` or `/swe-team:code-reviewer`) directly in the current session. For benchmarks requiring composition of multiple skills, invoke them in sequence as the workflow dictates. Scaffold the benchmark code in the language most natural for the benchmark scenario (default to Python or JavaScript/TypeScript unless the benchmark specifies otherwise).
3. Capture all output and artifacts.
4. Record the end state and elapsed time.

If a benchmark fails to run (tool error, timeout), mark it as INCOMPLETE and note the reason.

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
