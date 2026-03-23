---
name: code-reviewer
description: Review code diffs, PRs, and files for quality, bugs, security issues, and project conventions. Use when reviewing code, reviewing a PR, checking code quality, reviewing diffs, code review, review staged changes, security review, or checking for bugs.
---

# Code Reviewer

Systematic code review for diffs, files, and pull requests. Checks for bugs, security vulnerabilities, performance issues, and project convention compliance.

## Prerequisites

- For PR reviews: `gh` CLI must be authenticated
- For convention checking: invoke `/swe-team:software-engineering` first to load project preferences

## Activation Protocol

1. Determine review scope (see "What Are You Reviewing?" below).
2. Read `reference/security-checklist.md` (once per session is sufficient).
3. If `/swe-team:software-engineering` preferences have been loaded, apply them as style/convention rules. If not loaded, skip convention checking or note it as a limitation in your review.
4. Produce structured output using the Review Output Format below.

## What Are You Reviewing?

**Staged git diff:**
```bash
git diff --cached
```
Review the output. Focus on the changes only.

**Unstaged changes:**
```bash
git diff
```

**Specific files:**
Read the files directly. Review for standalone quality.

**Pull request via gh:**
```bash
gh pr diff <number>
gh pr view <number>
gh pr checks <number>
```
Review diff, check CI status, read PR description for context.

**Comparison between branches:**
```bash
git diff main..feature-branch
```

## Critical Requirements

- **Verify before flagging versions.** Never claim a dependency version, toolchain version, language edition, or library version is wrong based on memory alone. If you intend to flag a version as invalid, outdated, or incorrect, verify it first — check the project's lock file, run the toolchain's version command, or search the web. False version claims erode trust in the entire review.

## Review Process

For changes over 30 lines, follow all 6 steps below. For small changes (under 30 lines), use the Quick Checklist section instead.

### Step 1: Understand Context

- Read the diff or files.
- Identify what changed and why (commit messages, PR description).
- Note the language, framework, and project conventions.
- If the review involves config files (Cargo.toml, package.json, go.mod, pyproject.toml, etc.), verify toolchain and dependency versions are current before flagging any as incorrect.

### Step 2: Security Scan

Read reference/security-checklist.md. Check every item against the diff.

**Immediate blockers (request changes):**
- SQL injection, command injection, path traversal
- Hardcoded secrets or credentials
- Authentication/authorization bypass
- Unsafe deserialization

### Step 3: Bug Detection

- Off-by-one errors, null/undefined access, race conditions
- Incorrect error handling (swallowed errors, wrong error types)
- Resource leaks (unclosed files, connections, subscriptions)
- Logic errors (inverted conditions, missing edge cases)

### Step 4: Performance Check

- N+1 queries, unbounded loops, missing pagination
- Unnecessary allocations in hot paths
- Missing indexes on queried fields
- Blocking calls in async contexts

**Common patterns to flag:**
```python
# N+1 query: querying inside a loop
for order in orders:
    user = db.query(f"SELECT * FROM users WHERE id = {order.user_id}")

# Unbounded collection: no limit on accumulated results
items = []
while data := stream.read():
    items.append(data)  # no size limit

# Blocking in async: using sync HTTP client in async function
async def fetch(url):
    return requests.get(url)  # should use aiohttp or httpx
```

### Step 5: Style and Conventions

- Naming consistency with existing codebase
- Project-specific patterns (from software-engineering preferences)
- Dead code, unused imports, commented-out code
- Missing or misleading documentation

### Step 6: Test Coverage

- New code paths have tests
- Edge cases covered
- Tests are meaningful (not just coverage padding)

## Review Output Format

Structure every review as:

```
## Review: [scope description]

### Critical (must fix)
- [file:line] Issue description. Why it matters. Suggested fix.

### Warnings (should fix)
- [file:line] Issue description. Recommendation.

### Info (consider)
- [file:line] Observation or suggestion.

### Verdict: [APPROVE | REQUEST CHANGES]
[1-2 sentence summary]
```

Use `[file:line]` for single lines or `[file:line-line]` for ranges. If no issues found at a severity level, omit that section.

## PR Review Integration

To submit a review via `gh`:

```bash
# Approve
gh pr review <number> --approve --body "Review summary here"

# Request changes
gh pr review <number> --request-changes --body "Review summary here"

# Comment only (no verdict)
gh pr review <number> --comment --body "Review summary here"
```

## Quick Checklist

For small changes (under 30 lines), use this abbreviated checklist INSTEAD of the full 6-step Review Process above. Verify:
1. No security issues (reference/security-checklist.md)
2. No obvious bugs or logic errors
3. Error handling present
4. Consistent with surrounding code style
5. Tests exist for new behavior

## Reference

- **Security** — Read reference/security-checklist.md
