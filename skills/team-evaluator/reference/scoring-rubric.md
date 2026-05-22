# Scoring Rubric

Detailed criteria for evaluating benchmark results across four dimensions.

## Dimensions

### Correctness (0-3)
Does the output solve the stated problem?

| Score | Criteria |
|-------|----------|
| 0 | Not attempted, or output is completely wrong / makes the problem worse |
| 1 | Partially addresses the problem but has major errors or misunderstandings |
| 2 | Solves the core problem but misses an edge case or has a minor error |
| 3 | Fully solves the problem including edge cases, no errors |

**Examples:**
- Bug fix that fixes the crash but introduces a new bug → 1
- Bug fix that works for the reported case but fails on empty input → 2
- Bug fix that handles all cases and adds regression test → 3

### Completeness (0-3)
Is the solution thorough? Are edge cases handled?

| Score | Criteria |
|-------|----------|
| 0 | Missing entirely or only a stub |
| 1 | Core functionality present but missing significant parts (no tests, no error handling, no docs) |
| 2 | Most parts present, minor gaps (e.g., tests exist but miss an edge case) |
| 3 | Everything present: implementation, tests, error handling, documentation where appropriate |

**Key completeness indicators:**
- Tests exist and cover the main paths
- Error cases are handled (not just happy path)
- Input validation present where needed
- Documentation updated if public API changed

### Quality (0-3)
Is the output well-structured, clean, and maintainable?

| Score | Criteria |
|-------|----------|
| 0 | Unreadable, deeply nested, no structure |
| 1 | Works but poorly organized, hard to maintain, code smells |
| 2 | Clean and readable, minor style issues |
| 3 | Excellent structure, clear naming, well-organized, easy to extend |

**Quality indicators:**
- Functions are focused (single responsibility)
- Naming is clear and consistent
- No unnecessary complexity
- Error messages are helpful
- Code is self-documenting or well-commented where needed

### Convention Adherence (0-3)
Does it follow project conventions and best practices?

| Score | Criteria |
|-------|----------|
| 0 | Ignores all project conventions |
| 1 | Some conventions followed, some violated |
| 2 | Most conventions followed, minor deviations |
| 3 | Full adherence to project conventions and language idioms |

**Convention indicators:**
- Matches existing code style in the project
- Uses project's preferred patterns (DI, error handling, logging)
- Follows language/framework idioms
- Uses project's testing patterns
- Output format matches skill's specified format (e.g., review output format for code-review)

## Scoring Process

1. Read the benchmark's "Expected" section — this defines what a 3/3 looks like.
2. Compare actual output against expected output.
3. Score each dimension independently.
4. Total score is sum of all four dimensions (max 12).

## Verdict Thresholds

| Total Score | Verdict |
|-------------|---------|
| 10-12 | PASS — Skill/agent is strong in this area |
| 7-9 | MARGINAL — Functional but needs improvement |
| 4-6 | FAIL — Significant gaps, skill needs work |
| 0-3 | CRITICAL — Skill cannot perform this task |

## Category Ratings

When averaging scores across a category:

| Average | Rating | Action |
|---------|--------|--------|
| >= 2.5 | GREEN | No action needed |
| >= 1.5 | YELLOW | Improvement recommended |
| < 1.5 | RED | Immediate improvement required |

## Scoring Tips

- **Be honest about partial credit.** A solution that "mostly works" is a 2, not a 3.
- **Test the output.** Do not score based on appearance alone — run the code, run the tests.
- **Check for silent failures.** Code that looks correct but fails on edge cases scores lower on correctness.
- **Convention adherence requires context.** Read the project's existing code and preferences before scoring.
- **Quality is relative to the task.** A quick bug fix doesn't need the same structure as a new feature.
