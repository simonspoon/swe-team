# Bug Fix Workflow

For investigating and fixing bugs systematically.

> **Note:** All `clipm add` calls require `--action`, `--verify`, `--result` flags. All `clipm status <id> done` calls require `--outcome`. Examples below use abbreviated form for readability — fill in the structured fields for each task when creating.

## Task Hierarchy Pattern

```
Bug: <description>
├── Investigate
│   ├── Reproduce issue
│   ├── Identify root cause
│   └── Document findings
├── Fix
│   ├── Implement fix
│   └── Code review prep
├── Test
│   ├── Verify fix
│   └── Regression tests
└── Verify
    └── Confirm in target environment
```

## Step-by-Step

### 1. Create Bug Root

```bash
clipm add "Bug: <short description>"              # → abcd
clipm note abcd "Reported: <details>"
```

### 2. Add Investigation Phase

```bash
clipm add "Investigate" --parent abcd              # → efgh
clipm add "Reproduce the issue" --parent efgh      # → ijkl
clipm add "Identify root cause" --parent efgh      # → mnop
clipm add "Document findings" --parent efgh        # → qrst

# Root cause depends on reproduction
clipm block ijkl mnop
clipm block mnop qrst
```

### 3. Add Fix Phase

```bash
clipm add "Fix" --parent abcd                      # → uvwx
clipm add "Implement fix" --parent uvwx            # → yzab
clipm add "Prepare for review" --parent uvwx       # → cdef

# Fix depends on investigation
clipm block efgh uvwx
clipm block yzab cdef
```

### 4. Add Test & Verify

```bash
clipm add "Test" --parent abcd                     # → ghij
clipm add "Verify fix resolves issue" --parent ghij  # → klmn
clipm add "Run regression tests" --parent ghij     # → opqr

clipm add "Verify in environment" --parent abcd    # → stuv

# Dependencies
clipm block uvwx ghij    # Test after fix
clipm block ghij stuv    # Verify after test
```

### 5. Execute Sequentially

Bug fixes are typically sequential (investigate → fix → test → verify).

Dispatch investigation first:
```bash
clipm claim ijkl bug-investigator
clipm status ijkl in-progress
```

## Example: Login Failure Bug

```bash
clipm add "Bug: Users cannot log in with email containing +"  # → abcd

# Investigation
clipm add "Investigate login bug" --parent abcd              # → efgh
clipm add "Reproduce with test account" --parent efgh        # → ijkl
clipm add "Trace email handling in auth flow" --parent efgh  # → mnop
clipm add "Document root cause" --parent efgh                # → qrst

# Fix
clipm add "Fix email handling" --parent abcd                 # → uvwx
clipm add "Update email validation regex" --parent uvwx      # → yzab
clipm add "Handle URL encoding for email" --parent uvwx      # → cdef

# Test
clipm add "Test fix" --parent abcd                           # → ghij
clipm add "Test login with + in email" --parent ghij         # → klmn
clipm add "Test other special chars" --parent ghij           # → opqr

# Set all dependencies
clipm block ijkl mnop
clipm block mnop qrst
clipm block efgh uvwx
clipm block uvwx ghij
```

Note: Fix tasks yzab & cdef can run in parallel once investigation completes.

## iOS Bugs

For bugs involving iOS UI, use `/qorvex-test-ios` in the investigation and verification phases:

- **Reproduce**: `qorvex screenshot` + `screen-info` to capture the broken state
- **Verify fix**: Screenshot after fix, compare with broken state, confirm elements behave correctly

Back to [INDEX.md](INDEX.md) | [SKILL.md](../SKILL.md)
