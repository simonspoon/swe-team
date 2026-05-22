# Feature Implementation Workflow

For adding a single feature to an existing codebase.

## Quick Start

Create tasks manually using `limbo add` with the hierarchy pattern below. Use `--approach`, `--verify`, `--result` flags for structured tasks and `--outcome` when marking done (both optional but recommended).

## SWE Team Skills

For features that need full engineering rigor, compose with these skills:
- **Test phase**: Use `/swe-team:test-engineer` to generate tests and analyze coverage for new code
- **Review phase**: Use `/swe-team:code-review` to review the implementation before merging
- **CI phase**: Use `/swe-team:devops` if the feature requires CI/CD pipeline changes

For the complete plan→implement→test→review→deliver cycle, use [swe-full-cycle.md](swe-full-cycle.md) instead.

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
│   ├── Unit tests (test-engineer)
│   └── Integration tests
├── Review (code-review)
└── Documentation (if needed)
```

## Step-by-Step

### 1. Create Feature Root

```bash
limbo add "Feature: <name>" \
  --approach "Complete all child tasks for <name>" \
  --verify "All children done, integration test passes" \
  --result "Summary of feature implementation"              # → abcd
```

### 2. Add Phases

```bash
# Design phase
limbo add "Design: <feature>" --parent abcd              # → efgh
limbo add "Analyze requirements" --parent efgh            # → ijkl
limbo add "Define implementation approach" --parent efgh  # → mnop

# Implementation
limbo add "Implement: <feature>" --parent abcd            # → qrst
limbo add "Core logic" --parent qrst                      # → uvwx
limbo add "Integration with existing code" --parent qrst  # → yzab

# Testing
limbo add "Test: <feature>" --parent abcd                 # → cdef
limbo add "Unit tests" --parent cdef                      # → ghij
limbo add "Integration tests" --parent cdef               # → klmn
```

### 3. Set Dependencies

```bash
# Implementation depends on design
limbo block efgh qrst

# Testing depends on implementation
limbo block qrst cdef
```

### 4. Execution Order

Design tasks run first (no blockers). As each phase completes, the next phase unblocks automatically. The orchestrator picks up unblocked leaf tasks.

## Example: Add Search Feature

```bash
limbo add "Feature: Full-text search"                         # → abcd

limbo add "Design search" --parent abcd                       # → efgh
limbo add "Research search libraries" --parent efgh           # → ijkl
limbo add "Design search index schema" --parent efgh          # → mnop

limbo add "Implement search" --parent abcd                    # → qrst
limbo add "Set up search engine" --parent qrst                # → uvwx
limbo add "Index existing content" --parent qrst              # → yzab
limbo add "Search API endpoint" --parent qrst                 # → cdef

limbo add "Test search" --parent abcd                         # → ghij
limbo add "Unit tests for search logic" --parent ghij         # → klmn
limbo add "E2E search tests" --parent ghij                    # → opqr

# Dependencies
limbo block efgh qrst   # Implement after design
limbo block qrst ghij   # Test after implement
limbo block uvwx yzab   # Index after engine setup
```

Independent tasks (can execute in any order):
- ijkl & mnop (research + schema design)
- uvwx & cdef (engine setup + API can start together)
- klmn & opqr (unit + E2E tests)

## iOS Features

If the feature involves iOS UI changes, add a verification task using `/swe-team:qorvex-test-ios`:

```bash
limbo add "Verify iOS UI changes" --parent ghij \
  --approach "Run qorvex screenshot + screen-info to verify UI" \
  --verify "Screenshots show expected layout, elements are tappable" \
  --result "Before/after screenshots confirming feature works"
```

This task should depend on the implementation phase and run as part of (or alongside) testing.

Back to [INDEX.md](INDEX.md) | [SKILL.md](../SKILL.md)
