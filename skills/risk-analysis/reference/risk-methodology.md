# Risk Methodology

## Purpose

The risk taxonomy and the approach-validation procedure used by the risk-analysis skill.
Loaded by the SKILL.md workflow for step 1 (validate the approach) and step 2 (enumerate
risks).

## Content

### Validating the approach against acceptance criteria

For each acceptance criterion, trace through the proposed approach:

- Is there a step in the approach that addresses this criterion?
- Are there missing steps that would be needed to satisfy it?
- Does the approach assume something that is not true in the current code?

If the approach has gaps, write an improved version — the approach must be specific enough
to execute without guessing.

### The risk taxonomy

Categorize every identified risk into one of three categories.

**Failure modes — what can go wrong at runtime:**

- Missing error handling for expected failure cases
- Race conditions in concurrent code
- Resource leaks (files, connections, subscriptions)
- Data contract mismatches between components

**Edge cases — inputs or states the approach does not address:**

- Empty / null / zero values
- Boundary conditions
- Unicode, special characters, large inputs
- Platform-specific behavior

**Architectural concerns — broader impact:**

- Breaking changes to public APIs
- Performance regressions (N+1 queries, blocking in async, unbounded collections)
- Coupling that makes future changes harder
- Missing backwards compatibility

### Writing findings

- Every risk must reference a specific file, function, or code pattern. No vague warnings.
- Weight each risk by severity so the highest-impact risks are addressed first.
- If no significant risks are found, say so explicitly rather than inventing concerns.
