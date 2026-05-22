# Evaluation History

Track of all team evaluations for measuring improvement over time.

<!-- Append new entries at the bottom. Format:

## [YYYY-MM-DD] — [Scope]
Overall: [avg score]/12
Strengths: [top categories]
Gaps: [weak categories]
Key recommendation: [most impactful recommendation]

### Per-Benchmark Scores
| Benchmark | Score | Verdict |
|-----------|-------|---------|
| BF-1 | 10/12 | PASS |
(list all benchmarks run)

-->

## 2026-03-19 — Full Team Evaluation (Baseline)
Overall: 10.8/12
Strengths: Bug Fix (12/12), Code Review (12/12), Test Generation (11/12)
Gaps: CI/CD Setup (9/12 — MARGINAL)
Key recommendation: Improve devops skill to detect actual project package manager rather than defaulting to user preference when they conflict (e.g., npm project with pnpm preference).

### Per-Benchmark Scores
| Benchmark | Score | Verdict |
|-----------|-------|---------|
| BF-1: Null Reference in API Handler | 12/12 | PASS |
| FI-1: Add Search Endpoint | 11/12 | PASS |
| CR-1: Security Vulnerabilities | 12/12 | PASS |
| TG-1: Unit Tests for Utility Module | 11/12 | PASS |
| CD-1: GitHub Actions for Node.js | 9/12 | MARGINAL |
| RF-1: Extract Module from God Object | 10/12 | PASS |

### Detailed Scores
| Benchmark | Correctness | Completeness | Quality | Conventions | Total |
|-----------|-------------|--------------|---------|-------------|-------|
| BF-1 | 3 | 3 | 3 | 3 | 12 |
| FI-1 | 3 | 2 | 3 | 3 | 11 |
| CR-1 | 3 | 3 | 3 | 3 | 12 |
| TG-1 | 3 | 3 | 3 | 2 | 11 |
| CD-1 | 2 | 2 | 2 | 3 | 9 |
| RF-1 | 3 | 2 | 3 | 2 | 10 |

### Category Averages
| Category | Avg Score (per dimension) | Rating |
|----------|--------------------------|--------|
| Bug Fix | 3.00 | GREEN |
| Feature Implementation | 2.75 | GREEN |
| Code Review | 3.00 | GREEN |
| Test Generation | 2.75 | GREEN |
| CI/CD Setup | 2.25 | YELLOW |
| Refactoring | 2.50 | GREEN |

### Gaps Identified
| Gap | Severity | Root Cause | Affected Workflows |
|-----|----------|------------|-------------------|
| DevOps skill defaults to pnpm regardless of actual project setup | YELLOW | Skill follows user preference (pnpm) without detecting project reality (npm) | CI/CD Setup, SWE Full Cycle |
| Python 3.8 compat not proactively detected | YELLOW | Scaffolded code uses 3.10+ syntax (list[dict]) without __future__ import; skills fix it reactively but don't catch it upfront | All Python benchmarks |
| Refactoring doesn't add module-level tests | YELLOW | engineering-standards focuses on preserving existing tests, doesn't proactively generate tests for new modules | Refactoring workflows |
| Completeness gaps on documentation | YELLOW | Feature implementations include docstrings but not standalone docs when specs request them | Feature Implementation |

### Recommendations
1. **[HIGH] Enhance devops skill**: Add package manager detection logic (check for lockfiles: pnpm-lock.yaml, package-lock.json, yarn.lock) before defaulting to user preference. When detected PM differs from preference, use detected PM and note the divergence.
2. **[MEDIUM] Add Python version awareness**: engineering-standards and test-authoring skills should detect the runtime Python version and proactively add `from __future__ import annotations` when using 3.10+ type syntax on 3.8/3.9.
3. **[MEDIUM] Refactoring workflow improvement**: After extracting modules, the workflow should generate basic unit tests for each new module, not just verify existing tests pass.
4. **[LOW] Feature implementation completeness**: When the spec mentions "docs", generate a brief usage section or update project README, not just docstrings.

### Notes
- This is the initial baseline evaluation. No prior results to compare against.
- All benchmarks used Python except CD-1 (Node.js/YAML).
- The team performs well on core software engineering tasks (bug fix, code review, test generation).
- The primary weakness is in the DevOps/CI/CD area, specifically around environment detection.

## 2026-03-19 — Skill: simplify (Refactoring Category)
Overall: 11.7/12
Strengths: All three RF benchmarks scored PASS. RF-2 and RF-3 scored perfect 12/12.
Gaps: RF-1 Completeness (2/3) — extracted modules lack dedicated unit tests.
Key recommendation: After extracting modules from a god object, generate basic unit tests for each new module rather than only verifying existing tests pass.

### Per-Benchmark Scores
| Benchmark | Score | Verdict |
|-----------|-------|---------|
| RF-1: Extract Module from God Object | 11/12 | PASS |
| RF-2: Replace Callback Hell with Async/Await | 12/12 | PASS |
| RF-3: Dependency Injection Refactor | 12/12 | PASS |

### Detailed Scores
| Benchmark | Correctness | Completeness | Quality | Conventions | Total |
|-----------|-------------|--------------|---------|-------------|-------|
| RF-1 | 3 | 2 | 3 | 3 | 11 |
| RF-2 | 3 | 3 | 3 | 3 | 12 |
| RF-3 | 3 | 3 | 3 | 3 | 12 |

### Category Averages
| Category | Avg Score (per dimension) | Rating |
|----------|--------------------------|--------|
| Refactoring | 2.92 | GREEN |

### Comparison with Previous Evaluation
| Benchmark | Previous | Current | Change |
|-----------|----------|---------|--------|
| RF-1: Extract Module from God Object | 10/12 | 11/12 | +1 (Conventions improved from 2 to 3) |
| RF-2: Replace Callback Hell with Async/Await | N/A | 12/12 | New benchmark |
| RF-3: Dependency Injection Refactor | N/A | 12/12 | New benchmark |
| **Category Average** | **2.50** | **2.92** | **+0.42** |

### Gaps Identified
| Gap | Severity | Root Cause | Affected Workflows |
|-----|----------|------------|-------------------|
| Extracted modules lack dedicated unit tests | YELLOW | simplify skill focuses on verifying existing tests pass after refactoring, but doesn't proactively generate tests for newly created modules | God Object extraction |

### Notes
- Previous RF score was 2.50/3.00 (from single RF-1 baseline). New score is 2.92/3.00 across all three RF benchmarks.
- The simplify skill correctly followed all 7-pattern checklist analysis, applied conservative refactoring, and preserved all existing behavior.
- RF-1 improved by 1 point vs baseline (convention adherence improved — proper docstrings and consistent naming this time).
- RF-2 showed excellent async/await conversion with proper error handling semantics (non-fatal vs fatal errors).
- RF-3 demonstrated clean DI pattern with production defaults, and tests were properly rewritten to use constructor injection.
- The remaining gap (no tests for extracted modules) is a known issue from the baseline evaluation and would require a change to the simplify skill's refactoring workflow.

## 2026-03-19 — Full Team Evaluation (All Categories, All Benchmarks)
Overall: 11.89/12 (99.1%)
Strengths: Bug Fix (36/36), Feature Implementation (36/36), Code Review (36/36), Test Generation (36/36), Refactoring (36/36) — all perfect
Gaps: CI/CD (34/36) — minor completeness gaps in CD-1 and CD-3
Key recommendation: CI/CD pipelines should include lockfile validation and explicit approval gate configuration in deployment workflows.

### Per-Benchmark Scores
| Benchmark | Score | Verdict |
|-----------|-------|---------|
| BF-1: Null Reference in API Handler | 12/12 | PASS |
| BF-2: Off-by-One in Pagination | 12/12 | PASS |
| BF-3: Race Condition in Cache | 12/12 | PASS |
| FI-1: Add Search Endpoint | 12/12 | PASS |
| FI-2: Add Rate Limiting Middleware | 12/12 | PASS |
| FI-3: Add Webhook System | 12/12 | PASS |
| CR-1: Security Vulnerabilities | 12/12 | PASS |
| CR-2: Performance Anti-Patterns | 12/12 | PASS |
| CR-3: Mixed Quality PR | 12/12 | PASS |
| TG-1: Unit Tests for Utility Module | 12/12 | PASS |
| TG-2: Integration Tests for API | 12/12 | PASS |
| TG-3: Test Coverage Gap Analysis | 12/12 | PASS |
| CD-1: GitHub Actions for Node.js | 11/12 | PASS |
| CD-2: Docker Multi-Stage Build | 12/12 | PASS |
| CD-3: Deployment Pipeline | 11/12 | PASS |
| RF-1: Extract Module from God Object | 12/12 | PASS |
| RF-2: Replace Callback Hell with Async/Await | 12/12 | PASS |
| RF-3: Dependency Injection Refactor | 12/12 | PASS |

### Detailed Scores
| Benchmark | Correctness | Completeness | Quality | Conventions | Total |
|-----------|-------------|--------------|---------|-------------|-------|
| BF-1 | 3 | 3 | 3 | 3 | 12 |
| BF-2 | 3 | 3 | 3 | 3 | 12 |
| BF-3 | 3 | 3 | 3 | 3 | 12 |
| FI-1 | 3 | 3 | 3 | 3 | 12 |
| FI-2 | 3 | 3 | 3 | 3 | 12 |
| FI-3 | 3 | 3 | 3 | 3 | 12 |
| CR-1 | 3 | 3 | 3 | 3 | 12 |
| CR-2 | 3 | 3 | 3 | 3 | 12 |
| CR-3 | 3 | 3 | 3 | 3 | 12 |
| TG-1 | 3 | 3 | 3 | 3 | 12 |
| TG-2 | 3 | 3 | 3 | 3 | 12 |
| TG-3 | 3 | 3 | 3 | 3 | 12 |
| CD-1 | 3 | 2 | 3 | 3 | 11 |
| CD-2 | 3 | 3 | 3 | 3 | 12 |
| CD-3 | 3 | 2 | 3 | 3 | 11 |
| RF-1 | 3 | 3 | 3 | 3 | 12 |
| RF-2 | 3 | 3 | 3 | 3 | 12 |
| RF-3 | 3 | 3 | 3 | 3 | 12 |

### Category Averages
| Category | Total Score | Avg (per dimension) | Rating |
|----------|-----------|---------------------|--------|
| Bug Fix | 36/36 | 3.00 | GREEN |
| Feature Implementation | 36/36 | 3.00 | GREEN |
| Code Review | 36/36 | 3.00 | GREEN |
| Test Generation | 36/36 | 3.00 | GREEN |
| CI/CD Setup | 34/36 | 2.83 | GREEN |
| Refactoring | 36/36 | 3.00 | GREEN |

### Comparison with Previous Evaluation (Baseline)
| Category | Previous | Current | Change |
|----------|----------|---------|--------|
| Bug Fix | 3.00 (1 benchmark) | 3.00 (3 benchmarks) | Stable, expanded coverage |
| Feature Implementation | 2.75 (1 benchmark) | 3.00 (3 benchmarks) | +0.25 |
| Code Review | 3.00 (1 benchmark) | 3.00 (3 benchmarks) | Stable, expanded coverage |
| Test Generation | 2.75 (1 benchmark) | 3.00 (3 benchmarks) | +0.25 |
| CI/CD Setup | 2.25 (1 benchmark) | 2.83 (3 benchmarks) | +0.58 |
| Refactoring | 2.92 (3 benchmarks) | 3.00 (3 benchmarks) | +0.08 |
| **Overall** | **10.8/12 (90%)** | **11.89/12 (99.1%)** | **+9.1%** |

### Gaps Identified
| Gap | Severity | Root Cause | Affected Workflows |
|-----|----------|------------|-------------------|
| CD-1: No lockfile validation in CI workflow | LOW | Workflow assumes package-lock.json exists but doesn't check; npm ci would fail without it | CI/CD Setup |
| CD-3: Deployment steps are placeholder-only | LOW | Deployment commands are echo stubs; no actual cloud provider integration demonstrated | Deployment workflows |

### Recommendations
1. **[LOW] CI workflow lockfile handling**: Add a step to verify lockfile exists before running `npm ci`, or fall back to `npm install` with a warning.
2. **[LOW] Deployment workflow concreteness**: Consider adding a reusable deployment action or script template for common providers (AWS, Fly.io, Vercel) so deployment steps aren't just placeholders.

### Notes
- This is the first comprehensive evaluation covering all 18 benchmarks across all 6 categories.
- Previous baseline only ran 1 benchmark per category (6 total). This evaluation ran all 3 per category (18 total).
- The team now scores GREEN across all categories. The previous YELLOW on CI/CD has been resolved.
- All Python benchmarks ran successfully on Python 3.8 without compatibility issues.
- All code benchmarks produced passing test suites (verified by running pytest).
- The only remaining gaps are minor CI/CD completeness issues, both rated LOW severity.
- RF-1 improved from 11/12 (previous simplify eval) to 12/12 — the completeness gap for extracted module tests has been addressed.

## 2026-03-24 — Full Team Evaluation (v1.9.0 Regression Check)
Overall: 11.72/12 (97.7%)
Strengths: Bug Fix (36/36), Code Review (36/36), Test Generation (36/36) — all perfect
Gaps: CI/CD (33/36) — deploy scaffold missing rollback docs, Docker copy logic not context-aware
Key recommendation: Add rollback documentation to devops deploy template per skill's own rules.

### Per-Benchmark Scores
| Benchmark | Score | Verdict |
|-----------|-------|---------|
| BF-1: Null Reference in API Handler | 12/12 | PASS |
| BF-2: Off-by-One in Pagination | 12/12 | PASS |
| BF-3: Race Condition in Cache | 12/12 | PASS |
| FI-1: Add Search Endpoint | 12/12 | PASS |
| FI-2: Add Rate Limiting Middleware | 12/12 | PASS |
| FI-3: Add Webhook System | 11/12 | PASS |
| CR-1: Security Vulnerabilities | 12/12 | PASS |
| CR-2: Performance Anti-Patterns | 12/12 | PASS |
| CR-3: Mixed Quality PR | 12/12 | PASS |
| TG-1: Unit Tests for Utility Module | 12/12 | PASS |
| TG-2: Integration Tests for API | 12/12 | PASS |
| TG-3: Test Coverage Gap Analysis | 12/12 | PASS |
| CD-1: GitHub Actions for Node.js | 12/12 | PASS |
| CD-2: Docker Multi-Stage Build | 11/12 | PASS |
| CD-3: Deployment Pipeline | 10/12 | PASS |
| RF-1: Extract Module from God Object | 12/12 | PASS |
| RF-2: Replace Callback Hell with Async/Await | 11/12 | PASS |
| RF-3: Dependency Injection Refactor | 12/12 | PASS |

### Detailed Scores
| Benchmark | Correctness | Completeness | Quality | Conventions | Total |
|-----------|-------------|--------------|---------|-------------|-------|
| BF-1 | 3 | 3 | 3 | 3 | 12 |
| BF-2 | 3 | 3 | 3 | 3 | 12 |
| BF-3 | 3 | 3 | 3 | 3 | 12 |
| FI-1 | 3 | 3 | 3 | 3 | 12 |
| FI-2 | 3 | 3 | 3 | 3 | 12 |
| FI-3 | 3 | 3 | 3 | 2 | 11 |
| CR-1 | 3 | 3 | 3 | 3 | 12 |
| CR-2 | 3 | 3 | 3 | 3 | 12 |
| CR-3 | 3 | 3 | 3 | 3 | 12 |
| TG-1 | 3 | 3 | 3 | 3 | 12 |
| TG-2 | 3 | 3 | 3 | 3 | 12 |
| TG-3 | 3 | 3 | 3 | 3 | 12 |
| CD-1 | 3 | 3 | 3 | 3 | 12 |
| CD-2 | 3 | 3 | 2 | 3 | 11 |
| CD-3 | 3 | 2 | 2 | 3 | 10 |
| RF-1 | 3 | 3 | 3 | 3 | 12 |
| RF-2 | 3 | 3 | 3 | 2 | 11 |
| RF-3 | 3 | 3 | 3 | 3 | 12 |

### Category Averages
| Category | Total Score | Avg (per dimension) | Rating |
|----------|-----------|---------------------|--------|
| Bug Fix | 36/36 | 3.00 | GREEN |
| Feature Implementation | 35/36 | 2.92 | GREEN |
| Code Review | 36/36 | 3.00 | GREEN |
| Test Generation | 36/36 | 3.00 | GREEN |
| CI/CD Setup | 33/36 | 2.75 | GREEN |
| Refactoring | 35/36 | 2.92 | GREEN |

### Comparison with Previous Evaluation (Mar 19 Full)
| Benchmark | Previous | Current | Change |
|-----------|----------|---------|--------|
| CD-1 | 11/12 | 12/12 | +1 (pnpm lockfile detection fixed) |
| CD-2 | 12/12 | 11/12 | -1 (Docker copy logic not context-aware) |
| CD-3 | 11/12 | 10/12 | -1 (missing rollback docs) |
| FI-3 | 12/12 | 11/12 | -1 (Python truthiness convention) |
| RF-2 | 12/12 | 11/12 | -1 (error format changed during async conversion) |
| All others | 12/12 | 12/12 | Stable |
| **Overall** | **214/216 (99.1%)** | **211/216 (97.7%)** | **-1.4%** |

### Gaps Identified
| Gap | Severity | Root Cause | Affected Workflows |
|-----|----------|------------|-------------------|
| CD-3: No rollback mechanism/docs in deploy scaffold | YELLOW | Devops skill rules require rollback docs but deploy template omits them | Deployment workflows |
| CD-2: Builder copies src/ not dist/ | LOW | Copy logic not context-aware for projects with real build steps | Docker workflows |
| RF-2: Error message format changed during async conversion | LOW | Callback error prefixes dropped in favor of native exceptions | Refactoring workflows |
| FI-3: datetime.utcnow() deprecated in Python 3.12+ | LOW | Not proactively caught during code generation | Feature Implementation |

### Recommendations
1. **[MEDIUM] Add rollback docs to devops deploy template** — CD-3 dropped because skill's own rules require rollback steps but scaffold omits them. Add a rollback job or commented rollback instructions.
2. **[LOW] Docker copy context-awareness** — Builder stage should copy dist/ when a real build step exists vs src/ for runtime-only apps.
3. **[LOW] Python datetime modernization** — Use datetime.now(timezone.utc) in generated code to avoid 3.12+ deprecation.

### Notes
- This is a regression check after the v1.9.0 portability refactor and suda integration.
- **No regressions from the portability work.** The 3-point drop is from convention/completeness nuances, not correctness.
- **CD-1 pnpm bug confirmed fixed** — lockfile detection now works correctly (+1 vs previous).
- All 18 benchmarks PASS. All categories GREEN. Zero CRITICAL or FAIL verdicts.
- Correctness is 54/54 (100%) across all benchmarks — every solution solves the stated problem.

## 2026-05-20 — Full Team Evaluation (v1.27.0, first run with AP pipeline benchmarks)
Overall: 11.96/12 (287/288, 99.65%)
Strengths: Bug Fix, Feature Implementation, Code Review, Test Generation, Refactoring, Agent/Pipeline — all perfect on score
Gaps: CI/CD (35/36 — CD-2 missing HEALTHCHECK); AP suite coverage holes — verifier, in-review gate, and researcher were not actually exercised
Key recommendation: Harden the new AP benchmark scaffolds. AP-4 and AP-6 did not trigger their target mechanism (in-review gate / researcher dispatch); verifier remains unbenchmarked. The 72/72 AP score reflects team execution quality, not coverage of those three agents.

### Per-Benchmark Scores
| Benchmark | Score | Verdict |
|-----------|-------|---------|
| BF-1: Null Reference in API Handler | 12/12 | PASS |
| BF-2: Off-by-One in Pagination | 12/12 | PASS |
| BF-3: Race Condition in Cache | 12/12 | PASS |
| FI-1: Add Search Endpoint | 12/12 | PASS |
| FI-2: Add Rate Limiting Middleware | 12/12 | PASS |
| FI-3: Add Webhook System | 12/12 | PASS |
| CR-1: Security Vulnerabilities | 12/12 | PASS |
| CR-2: Performance Anti-Patterns | 12/12 | PASS |
| CR-3: Mixed Quality PR | 12/12 | PASS |
| TG-1: Unit Tests for Utility Module | 12/12 | PASS |
| TG-2: Integration Tests for API | 12/12 | PASS |
| TG-3: Test Coverage Gap Analysis | 12/12 | PASS |
| CD-1: GitHub Actions for Node.js | 12/12 | PASS |
| CD-2: Docker Multi-Stage Build | 11/12 | PASS |
| CD-3: Deployment Pipeline | 12/12 | PASS |
| RF-1: Extract Module from God Object | 12/12 | PASS |
| RF-2: Replace Callback Hell with Async/Await | 12/12 | PASS |
| RF-3: Dependency Injection Refactor | 12/12 | PASS |
| AP-1: Decompose a Multi-Part Feature | 12/12 | PASS |
| AP-2: End-to-End Bug Fix Through the Pipeline | 12/12 | PASS |
| AP-3: Risk Assessment Catches a Bad Approach | 12/12 | PASS |
| AP-4: In-Review Gate Catches a Planted Defect | 12/12 | PASS* |
| AP-5: Test Strategy Quality at the Planned Gate | 12/12 | PASS |
| AP-6: Targeted Investigation via Researcher | 12/12 | PASS* |

(*) Team executed well but the benchmark's target mechanism was not exercised — see Gaps.

### Detailed Scores
| Benchmark | Correctness | Completeness | Quality | Conventions | Total |
|-----------|-------------|--------------|---------|-------------|-------|
| BF-1 | 3 | 3 | 3 | 3 | 12 |
| BF-2 | 3 | 3 | 3 | 3 | 12 |
| BF-3 | 3 | 3 | 3 | 3 | 12 |
| FI-1 | 3 | 3 | 3 | 3 | 12 |
| FI-2 | 3 | 3 | 3 | 3 | 12 |
| FI-3 | 3 | 3 | 3 | 3 | 12 |
| CR-1 | 3 | 3 | 3 | 3 | 12 |
| CR-2 | 3 | 3 | 3 | 3 | 12 |
| CR-3 | 3 | 3 | 3 | 3 | 12 |
| TG-1 | 3 | 3 | 3 | 3 | 12 |
| TG-2 | 3 | 3 | 3 | 3 | 12 |
| TG-3 | 3 | 3 | 3 | 3 | 12 |
| CD-1 | 3 | 3 | 3 | 3 | 12 |
| CD-2 | 3 | 2 | 3 | 3 | 11 |
| CD-3 | 3 | 3 | 3 | 3 | 12 |
| RF-1 | 3 | 3 | 3 | 3 | 12 |
| RF-2 | 3 | 3 | 3 | 3 | 12 |
| RF-3 | 3 | 3 | 3 | 3 | 12 |
| AP-1 | 3 | 3 | 3 | 3 | 12 |
| AP-2 | 3 | 3 | 3 | 3 | 12 |
| AP-3 | 3 | 3 | 3 | 3 | 12 |
| AP-4 | 3 | 3 | 3 | 3 | 12 |
| AP-5 | 3 | 3 | 3 | 3 | 12 |
| AP-6 | 3 | 3 | 3 | 3 | 12 |

### Category Averages
| Category | Total Score | Avg (per dimension) | Rating |
|----------|-----------|---------------------|--------|
| Bug Fix | 36/36 | 3.00 | GREEN |
| Feature Implementation | 36/36 | 3.00 | GREEN |
| Code Review | 36/36 | 3.00 | GREEN |
| Test Generation | 36/36 | 3.00 | GREEN |
| CI/CD Setup | 35/36 | 2.92 | GREEN |
| Refactoring | 36/36 | 3.00 | GREEN |
| Agent / Pipeline | 72/72 | 3.00 | GREEN |

### Comparison with Previous Evaluation (Mar 24, v1.9.0)
| Category | Previous | Current | Change |
|----------|----------|---------|--------|
| Bug Fix | 36/36 | 36/36 | Stable |
| Feature Implementation | 35/36 | 36/36 | +1 (FI-3 Python convention fixed) |
| Code Review | 36/36 | 36/36 | Stable |
| Test Generation | 36/36 | 36/36 | Stable |
| CI/CD Setup | 33/36 | 35/36 | +2 (CD-3 rollback docs added — prior key recommendation resolved) |
| Refactoring | 35/36 | 36/36 | +1 (RF-2 error format preserved) |
| Agent / Pipeline | N/A | 72/72 | New category (pipeline-level, 6 benchmarks) |
| **Skill-level overall** | **211/216 (97.7%)** | **215/216 (99.5%)** | **+1.8%** |

### Gaps Identified
| Gap | Severity | Root Cause | Affected Workflows |
|-----|----------|------------|-------------------|
| AP-4 did not exercise the in-review gate | YELLOW | The planted defect was pre-stated in APPROACH.md, so the pipeline caught it at refinement/planning before implementation. A defect visible in the spec cannot test the *in-review* gate. | team-evaluator AP suite |
| AP-6 did not exercise the researcher agent | YELLOW | The scaffold is only 3 files / ~85 lines — too small to compel scout-mode dispatch. The PM correctly investigated directly. | team-evaluator AP suite |
| verifier agent unbenchmarked | YELLOW | Known/documented limitation — verifier needs a live app (khora/loki/qorvex); a /tmp scaffold has none. | team-evaluator AP suite |
| CD-2 Dockerfile omits HEALTHCHECK | LOW | devops skill produced a multi-stage build but did not add a HEALTHCHECK despite the app exposing /health. | CI/CD, Docker workflows |

### Recommendations
1. **[MEDIUM] Re-scaffold AP-4** so the defect is introduced *during implementation*, not pre-stated in APPROACH.md — e.g. an approach that is correct in prose but where a naive implementation produces an off-by-one. Only then does the in-review gate become the thing under test.
2. **[MEDIUM] Re-scaffold AP-6** with a genuinely large/unfamiliar codebase (many modules, indirection) so direct PM investigation is impractical and scout-mode researcher dispatch is the correct call.
3. **[LOW] devops skill** — add a HEALTHCHECK instruction to generated Dockerfiles when the app exposes a health endpoint.
4. **[LOW] verifier coverage** — to evaluate the verifier end-to-end, run a one-off pipeline benchmark against a real launchable project rather than a synthetic scaffold.

### Notes
- First evaluation on plugin v1.27.0 and the first to run the AP (Agent/Pipeline) benchmarks added in commit 43e6f94.
- Skill-level benchmarks (18) are self-run and self-scored by the runner, consistent with the skill design and all prior evals. The 6 AP benchmarks were independently verified by the orchestrator (git logs, limbo task state, live `pytest` runs in each scratch repo).
- All 24 benchmarks PASS. Zero MARGINAL/FAIL/CRITICAL. Correctness 72/72 (100%).
- The team's *execution* is excellent end-to-end: AP-2 ran a full bug-fix lifecycle with a regression test verified failing pre-fix; AP-3's risk-assessor caught a cross-user cache leak and drove a structurally-safe design; AP-4 caught a planted defect upstream so it never reached `done`.
- The real finding is in the *evaluation harness*, not the team: 3 of the AP category's target agents/gates (in-review gate, researcher, verifier) were not exercised. The AP suite is new and needs scaffold hardening before its scores can be read as agent coverage.
