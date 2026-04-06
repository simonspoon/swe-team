# Change Request Workflow

For modifying existing functionality.

> **Note:** Use `--approach`, `--verify`, `--result` flags for structured tasks and `--outcome` when marking done (both optional but recommended).

## Task Hierarchy Pattern

```
Change: <description>
├── Analysis
│   ├── Understand current behavior
│   └── Define target behavior
├── Modify
│   ├── Update code
│   └── Update config/data
├── Test
│   ├── Test new behavior
│   └── Regression tests
└── Deploy (if applicable)
```

## Step-by-Step

### 1. Create Change Root

```bash
limbo add "Change: <description>"                  # → abcd
limbo note abcd "Reason: <why this change>"
```

### 2. Add Analysis Phase

```bash
limbo add "Analyze change impact" --parent abcd              # → efgh
limbo add "Document current behavior" --parent efgh          # → ijkl
limbo add "Define target behavior" --parent efgh             # → mnop
limbo add "Identify affected components" --parent efgh       # → qrst
```

### 3. Add Modification Phase

```bash
limbo add "Implement changes" --parent abcd                  # → uvwx
limbo add "Update <component 1>" --parent uvwx               # → yzab
limbo add "Update <component 2>" --parent uvwx               # → cdef

# Block on analysis
limbo block efgh uvwx
```

### 4. Add Testing

```bash
limbo add "Test changes" --parent abcd                       # → ghij
limbo add "Verify new behavior" --parent ghij                # → klmn
limbo add "Run regression suite" --parent ghij               # → opqr

limbo block uvwx ghij
```

## SWE Team Skills

For change requests that involve refactoring, compose with:
- **Test phase**: Use `/swe-team:test-engineer` — especially important for refactoring. Generate tests for newly extracted modules, don't just verify existing tests pass.
- **Review phase**: Use `/swe-team:code-reviewer` to verify refactoring preserves behavior and doesn't break encapsulation.

### 5. Independent Tasks

These groups have no dependencies between them and can execute in any order:
- Analysis sub-tasks
- Multiple component updates (after analysis)
- Different test types (after implementation)

## Example: Update API Response Format

```bash
limbo add "Change: Update user API to return camelCase"  # → abcd

# Analysis
limbo add "Analyze API change" --parent abcd             # → efgh
limbo add "List all affected endpoints" --parent efgh    # → ijkl
limbo add "Check client dependencies" --parent efgh      # → mnop
limbo add "Plan migration strategy" --parent efgh        # → qrst

# Modification
limbo add "Update API responses" --parent abcd           # → uvwx
limbo add "Update user endpoint" --parent uvwx           # → yzab
limbo add "Update profile endpoint" --parent uvwx        # → cdef
limbo add "Update settings endpoint" --parent uvwx       # → ghij

# Testing
limbo add "Test API changes" --parent abcd               # → klmn
limbo add "Test each endpoint response" --parent klmn    # → opqr
limbo add "Test client compatibility" --parent klmn      # → stuv

# Dependencies
limbo block ijkl qrst   # Migration plan needs endpoint list
limbo block mnop qrst   # Migration plan needs client info
limbo block efgh uvwx    # Modification after analysis
limbo block uvwx klmn    # Test after modification
```

Execution order (based on dependencies):
1. ijkl & mnop (endpoint list + client check — no blockers)
2. yzab, cdef, ghij (endpoint updates — unblocked after analysis)
3. opqr & stuv (endpoint + client tests — unblocked after implementation)

Back to [INDEX.md](INDEX.md) | [SKILL.md](../SKILL.md)
