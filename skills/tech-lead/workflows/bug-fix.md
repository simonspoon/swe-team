# Bug Fix Workflow

For investigating and fixing bugs systematically.

## Quick Start

Create tasks manually using `limbo add` with the hierarchy pattern below. Use `--approach`, `--verify`, `--result` flags for structured tasks and `--outcome` when marking done (both optional but recommended).

## SWE Team Skills

For bug fixes that need thorough verification, compose with these skills:
- **Test phase**: Use `/swe-team:test-engineer` to generate regression tests that prevent recurrence
- **Review phase**: Use `/swe-team:code-reviewer` to review the fix for security and correctness
- **CI phase**: Use `/swe-team:devops` if the fix reveals a CI gap (missing test step, etc.)

## Task Hierarchy Pattern

```
Bug: <description>
├── Investigate
│   ├── Reproduce issue
│   ├── Identify root cause
│   └── Document findings
├── Fix
│   ├── Implement fix
│   └── Code review (code-reviewer)
├── Test
│   ├── Verify fix
│   └── Regression tests (test-engineer)
└── Verify
    └── Confirm in target environment
```

## Step-by-Step

### 1. Create Bug Root

```bash
limbo add "Bug: <short description>"              # → abcd
limbo note abcd "Reported: <details>"
```

### 2. Add Investigation Phase

```bash
limbo add "Investigate" --parent abcd              # → efgh
limbo add "Reproduce the issue" --parent efgh      # → ijkl
limbo add "Identify root cause" --parent efgh      # → mnop
limbo add "Document findings" --parent efgh        # → qrst

# Root cause depends on reproduction
limbo block ijkl mnop
limbo block mnop qrst
```

### 3. Add Fix Phase

```bash
limbo add "Fix" --parent abcd                      # → uvwx
limbo add "Implement fix" --parent uvwx            # → yzab
limbo add "Prepare for review" --parent uvwx       # → cdef

# Fix depends on investigation
limbo block efgh uvwx
limbo block yzab cdef
```

### 4. Add Test & Verify

```bash
limbo add "Test" --parent abcd                     # → ghij
limbo add "Verify fix resolves issue" --parent ghij  # → klmn
limbo add "Run regression tests" --parent ghij     # → opqr

limbo add "Verify in environment" --parent abcd    # → stuv

# Dependencies
limbo block uvwx ghij    # Test after fix
limbo block ghij stuv    # Verify after test
```

### 5. Execution Order

Bug fixes are typically sequential (investigate → fix → test → verify). The orchestrator picks up unblocked leaf tasks in dependency order.

## Example: Login Failure Bug

```bash
limbo add "Bug: Users cannot log in with email containing +"  # → abcd

# Investigation
limbo add "Investigate login bug" --parent abcd              # → efgh
limbo add "Reproduce with test account" --parent efgh        # → ijkl
limbo add "Trace email handling in auth flow" --parent efgh  # → mnop
limbo add "Document root cause" --parent efgh                # → qrst

# Fix
limbo add "Fix email handling" --parent abcd                 # → uvwx
limbo add "Update email validation regex" --parent uvwx      # → yzab
limbo add "Handle URL encoding for email" --parent uvwx      # → cdef

# Test
limbo add "Test fix" --parent abcd                           # → ghij
limbo add "Test login with + in email" --parent ghij         # → klmn
limbo add "Test other special chars" --parent ghij           # → opqr

# Set all dependencies
limbo block ijkl mnop
limbo block mnop qrst
limbo block efgh uvwx
limbo block uvwx ghij
```

Note: Fix tasks yzab & cdef are independent and can execute in any order once investigation completes.

## iOS Bugs

For bugs involving iOS UI, use `/swe-team:qorvex-test-ios` in the investigation and verification phases:

- **Reproduce**: `qorvex screenshot` + `screen-info` to capture the broken state
- **Verify fix**: Screenshot after fix, compare with broken state, confirm elements behave correctly

Back to [INDEX.md](INDEX.md) | [SKILL.md](../SKILL.md)
