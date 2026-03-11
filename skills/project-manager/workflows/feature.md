# Feature Implementation Workflow

For adding a single feature to an existing codebase.

> **Note:** All `clipm add` calls require `--action`, `--verify`, `--result` flags. All `clipm status <id> done` calls require `--outcome`. Examples below use abbreviated form for readability — fill in the structured fields for each task when creating.

## Task Hierarchy Pattern

```
Feature: <name>
├── Design
│   ├── Analyze requirements
│   └── Define approach
├── Implementation
│   ├── Core logic
│   └── Integration points
├── Testing
│   ├── Unit tests
│   └── Integration tests
└── Documentation (if needed)
```

## Step-by-Step

### 1. Create Feature Root

```bash
clipm add "Feature: <name>" \
  --action "Complete all child tasks for <name>" \
  --verify "All children done, integration test passes" \
  --result "Summary of feature implementation"              # → abcd
```

### 2. Add Phases

```bash
# Design phase
clipm add "Design: <feature>" --parent abcd              # → efgh
clipm add "Analyze requirements" --parent efgh            # → ijkl
clipm add "Define implementation approach" --parent efgh  # → mnop

# Implementation
clipm add "Implement: <feature>" --parent abcd            # → qrst
clipm add "Core logic" --parent qrst                      # → uvwx
clipm add "Integration with existing code" --parent qrst  # → yzab

# Testing
clipm add "Test: <feature>" --parent abcd                 # → cdef
clipm add "Unit tests" --parent cdef                      # → ghij
clipm add "Integration tests" --parent cdef               # → klmn
```

### 3. Set Dependencies

```bash
# Implementation depends on design
clipm block efgh qrst

# Testing depends on implementation
clipm block qrst cdef
```

### 4. Dispatch Design Phase

Start with design tasks (can run in parallel if independent):

```bash
clipm claim ijkl design-analyst
clipm status ijkl in-progress
```

### 5. Progress Through Phases

As each phase completes, next phase unblocks automatically.

## Example: Add Search Feature

```bash
clipm add "Feature: Full-text search"                         # → abcd

clipm add "Design search" --parent abcd                       # → efgh
clipm add "Research search libraries" --parent efgh           # → ijkl
clipm add "Design search index schema" --parent efgh          # → mnop

clipm add "Implement search" --parent abcd                    # → qrst
clipm add "Set up search engine" --parent qrst                # → uvwx
clipm add "Index existing content" --parent qrst              # → yzab
clipm add "Search API endpoint" --parent qrst                 # → cdef

clipm add "Test search" --parent abcd                         # → ghij
clipm add "Unit tests for search logic" --parent ghij         # → klmn
clipm add "E2E search tests" --parent ghij                    # → opqr

# Dependencies
clipm block efgh qrst   # Implement after design
clipm block qrst ghij   # Test after implement
clipm block uvwx yzab   # Index after engine setup
```

Parallel opportunities:
- ijkl & mnop (research + schema design)
- uvwx & cdef (engine setup + API can start together)
- klmn & opqr (unit + E2E tests)

## iOS Features

If the feature involves iOS UI changes, add a verification task using `/qorvex-test-ios`:

```bash
clipm add "Verify iOS UI changes" --parent ghij \
  --action "Run qorvex screenshot + screen-info to verify UI" \
  --verify "Screenshots show expected layout, elements are tappable" \
  --result "Before/after screenshots confirming feature works"
```

This task should depend on the implementation phase and run as part of (or alongside) testing.

Back to [INDEX.md](INDEX.md) | [SKILL.md](../SKILL.md)
