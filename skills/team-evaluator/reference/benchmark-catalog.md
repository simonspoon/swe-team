# Benchmark Catalog

Predefined benchmark tasks organized by category. Each benchmark specifies a scenario, expected outcome, the level it runs at, and which skills/agents it exercises.

**Levels** (see SKILL.md "Evaluation Levels"):
- **Skill** — invoke a single skill directly in the current session. Fast, narrow.
- **Pipeline** — dispatch the `swe-team:project-manager` agent and score the end-to-end team workflow.

Categories BF / FI / CR / TG / CD / RF are skill-level. Category AP is pipeline-level.

## Bug Fix Benchmarks

### BF-1: Null Reference in API Handler
**Setup:** Create a REST handler that crashes when an optional field is missing from the request body.
**Task:** "This API endpoint crashes when the `email` field is omitted. Find and fix the bug."
**Expected:** Null check added, graceful error response returned, test added for missing field.
**Level:** Skill
**Exercises:** engineering-standards, code-review

### BF-2: Off-by-One in Pagination
**Setup:** Create a list endpoint with pagination that skips the last item when results are exactly page-sized.
**Task:** "Users report the last item on each page is sometimes missing. Investigate and fix."
**Expected:** Pagination boundary condition fixed, edge case tests added.
**Level:** Skill
**Exercises:** engineering-standards, test-engineer

### BF-3: Race Condition in Cache
**Setup:** Create a cache module where concurrent reads and writes can return stale data.
**Task:** "Cache sometimes returns stale data under load. Diagnose and fix."
**Expected:** Thread-safe access pattern implemented, concurrent access test added.
**Level:** Skill
**Exercises:** engineering-standards, code-review

## Feature Implementation Benchmarks

### FI-1: Add Search Endpoint
**Setup:** Provide a project with user CRUD endpoints but no search.
**Task:** "Add a search endpoint that supports filtering by name and email, with pagination."
**Expected:** New endpoint with filtering, pagination, input validation, tests, docs.
**Level:** Skill
**Exercises:** engineering-standards, tech-lead, test-engineer

### FI-2: Add Rate Limiting Middleware
**Setup:** Provide an Express/Actix/Flask app with no rate limiting.
**Task:** "Add rate limiting: 100 requests per minute per IP, with configurable limits."
**Expected:** Middleware implemented, configurable, tests for limit enforcement and reset.
**Level:** Skill
**Exercises:** engineering-standards, test-engineer

### FI-3: Add Webhook System
**Setup:** Provide an app that processes events internally.
**Task:** "Add webhook support: register URLs, retry on failure, log delivery attempts."
**Expected:** Registration API, delivery with retries, logging, tests.
**Level:** Skill
**Exercises:** engineering-standards, tech-lead, devops

## Code Review Benchmarks

### CR-1: Security Vulnerabilities
**Setup:** Create a file with 3 planted security issues: SQL injection, hardcoded secret, path traversal.
**Task:** "Review this code for security issues."
**Expected:** All 3 issues identified with severity ratings and fix suggestions.
**Level:** Skill
**Exercises:** code-review, engineering-standards

### CR-2: Performance Anti-Patterns
**Setup:** Create a file with N+1 query, unbounded loop, and missing index hint.
**Task:** "Review this code for performance issues."
**Expected:** All 3 patterns identified with improvement suggestions.
**Level:** Skill
**Exercises:** code-review, engineering-standards

### CR-3: Mixed Quality PR
**Setup:** Create a diff with good changes mixed with subtle bugs and style violations.
**Task:** "Review this PR."
**Expected:** Bugs caught, style issues noted, good changes acknowledged. Correct verdict.
**Level:** Skill
**Exercises:** code-review

## Test Generation Benchmarks

### TG-1: Unit Tests for Utility Module
**Setup:** Provide a utility module with 5 functions, no tests.
**Task:** "Generate comprehensive unit tests for this module."
**Expected:** Tests for all functions, edge cases covered, tests actually pass.
**Level:** Skill
**Exercises:** test-engineer, engineering-standards

### TG-2: Integration Tests for API
**Setup:** Provide an API with 3 endpoints, no integration tests.
**Task:** "Generate integration tests for these API endpoints."
**Expected:** Tests cover success paths, error paths, validation, auth. Tests actually run.
**Level:** Skill
**Exercises:** test-engineer, engineering-standards

### TG-3: Test Coverage Gap Analysis
**Setup:** Provide a module with existing tests that miss 3 critical paths.
**Task:** "Analyze test coverage and fill the gaps."
**Expected:** Missing paths identified, tests added, coverage improved.
**Level:** Skill
**Exercises:** test-engineer

## CI/CD Benchmarks

### CD-1: GitHub Actions for Node.js
**Setup:** Provide a Node.js project with tests but no CI.
**Task:** "Set up GitHub Actions CI: lint, test, build on PR and push to main."
**Expected:** Working workflow file, correct triggers, caching, artifact handling.
**Level:** Skill
**Exercises:** devops, test-engineer

### CD-2: Docker Multi-Stage Build
**Setup:** Provide a project with a naive Dockerfile.
**Task:** "Optimize the Dockerfile with multi-stage build, minimize image size."
**Expected:** Multi-stage Dockerfile, smaller image, build still works.
**Level:** Skill
**Exercises:** devops

### CD-3: Deployment Pipeline
**Setup:** Provide a project with CI but no CD.
**Task:** "Add a deployment stage: staging on PR merge, production on tag."
**Expected:** Deployment workflow with environment separation, approval gates.
**Level:** Skill
**Exercises:** devops

## Refactoring Benchmarks

### RF-1: Extract Module from God Object
**Setup:** Create a class/module with 5+ responsibilities.
**Task:** "Refactor this into focused modules with clear responsibilities."
**Expected:** Clean separation, all existing tests still pass, no behavior change.
**Level:** Skill
**Exercises:** engineering-standards, code-review, test-engineer

### RF-2: Replace Callback Hell with Async/Await
**Setup:** Provide deeply nested callback-based code.
**Task:** "Refactor to use async/await while preserving behavior."
**Expected:** Clean async code, all existing tests pass, error handling preserved.
**Level:** Skill
**Exercises:** engineering-standards

### RF-3: Dependency Injection Refactor
**Setup:** Provide code with hardcoded dependencies.
**Task:** "Refactor to use dependency injection for testability."
**Expected:** DI pattern applied, existing tests updated, new tests use mocks.
**Level:** Skill
**Exercises:** engineering-standards, test-engineer

## Agent / Pipeline Benchmarks

**Level: Pipeline.** Every benchmark in this category is run by dispatching the `swe-team:project-manager` agent with the `Task` as its single task, then scoring the end-to-end result — decomposition, implementation, stage-gate behavior, and verification together. These benchmarks exist because agents (project-manager, risk-assessor, code-reviewer-as-gate, verifier, committer, researcher) only run *inside* the pipeline; a skill-level benchmark cannot reach them.

When scoring, attribute weak dimensions to a pipeline stage (see SKILL.md Step 5): decomposition (PM), implementation (tech-lead), refined→planned gate (risk-assessor / test-engineer), in-review gate (code-reviewer / verifier).

### AP-1: Decompose a Multi-Part Feature
**Setup:** Provide a small app with no auth. Write a feature request with 3 distinct user-visible behaviors (register, log in, log out).
**Task:** "Add session-based authentication: users can register, log in, and log out."
**Expected:** PM decomposes into 2-3 well-scoped leaf tasks in limbo, each with `approach`, `verify`, and `result` fields populated; dependencies set where order matters; leaves are independently executable. Decomposition is the scored artifact — implementation need not be run.
**Level:** Pipeline
**Exercises:** project-manager (decomposition)

### AP-2: End-to-End Bug Fix Through the Pipeline
**Setup:** Scaffold a repo with a known bug (reuse a BF-style scenario, e.g. a null-reference crash) and a passing-but-incomplete test suite.
**Task:** "This endpoint crashes when the `email` field is omitted. Fix it."
**Expected:** PM runs the task through every stage — refined (acceptance criteria), planned (approach + test strategy + risks via risk-assessor and test-engineer), in-progress (tech-lead implements the fix), in-review (code-reviewer self-review + verifier), done (committer commits). Bug fixed, regression test added, single clean commit. Score the whole loop.
**Level:** Pipeline
**Exercises:** project-manager, tech-lead, risk-assessor, test-engineer, code-reviewer, committer

### AP-3: Risk Assessment Catches a Bad Approach
**Setup:** Provide a task whose obvious naive approach has a real flaw (e.g. "add a cache" where the data is per-request and caching would leak state across users).
**Task:** "Add caching to the user-profile endpoint to speed it up."
**Expected:** At the refined→planned gate, the risk-assessor flags the correctness/security risk (cross-user state leak) and the recorded `risks` field names it; the `approach` reflects the safer design. The pipeline does not silently ship the naive approach.
**Level:** Pipeline
**Exercises:** project-manager, risk-assessor

### AP-4: In-Review Gate Catches a Planted Defect
**Setup:** Construct the benchmark so the implementation step produces code with a subtle planted defect (e.g. an off-by-one, or a swallowed error). One way: pre-seed the task `approach` with the flawed instruction.
**Task:** "Implement the pagination helper per the approach."
**Expected:** At the in-review stage the code-reviewer self-review returns REQUEST CHANGES (or the verifier returns FAIL), the task rolls back to in-progress, the defect is fixed, and only the corrected version is committed. A pass here means the gate did its job; a defect reaching `done` is a gate failure.
**Level:** Pipeline
**Exercises:** project-manager, code-reviewer, verifier, tech-lead

### AP-5: Test Strategy Quality at the Planned Gate
**Setup:** Provide a feature task touching code with no existing tests.
**Task:** "Add input validation to the registration endpoint."
**Expected:** At the refined→planned gate the test-engineer produces a `test_strategy` that names a concrete tool/command (e.g. `uv run pytest`) and covers the invalid-input paths, not vague prose. The planned-gate check (test strategy must reference a real tool) passes on substance.
**Level:** Pipeline
**Exercises:** project-manager, test-engineer

### AP-6: Targeted Investigation via Researcher
**Setup:** Provide an unfamiliar codebase (a few modules, no docs) and a task whose scope can't be settled without reading the code.
**Task:** "Add a `--dry-run` flag to the sync command."
**Expected:** During refinement the PM dispatches the `swe-team:researcher` agent in scout mode with a tight question, synthesizes the returned findings into the limbo task, and scopes the change correctly. Score whether the investigation was targeted (not a blind grep) and whether findings shaped the acceptance criteria.
**Level:** Pipeline
**Exercises:** project-manager, researcher

### Coverage limitation — verifier

The `verifier` agent runs live verification against a running application via khora (web), loki (desktop), or qorvex (iOS). A `/tmp` benchmark scaffold has no running app, so the verifier cannot be fully exercised in a synthetic environment. AP-2 and AP-4 exercise the verifier's *pipeline position* (the in-review gate fires and a FAIL rolls the task back), but its live-app behavior — launching a UI, taking screenshots, asserting on rendered state — is **not benchmarked here**. To evaluate the verifier end-to-end, run a pipeline benchmark against a real project with a launchable app rather than a scaffold. This is a known, accepted gap; do not force a synthetic verifier benchmark.

## Creating Custom Benchmarks

To add a benchmark, follow this template:

```markdown
### [CAT]-[N]: [Title]
**Setup:** [What to create/scaffold for the test scenario]
**Task:** [Exact prompt to give the skill/agent]
**Expected:** [What a correct solution looks like]
**Level:** [Skill | Pipeline]
**Exercises:** [skill1, skill2]
```

Categories: BF (bug fix), FI (feature implementation), CR (code review), TG (test generation), CD (CI/CD), RF (refactoring) — all skill-level; AP (agent / pipeline) — pipeline-level.
