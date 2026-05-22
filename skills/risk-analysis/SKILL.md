---
name: risk-analysis
description: >
  Enumerate and weight the risks of a planned change before code is written. Invoke during
  the refined-to-planned stage to validate the approach against acceptance criteria, surface
  failure modes and edge cases, and run a security review. Triggers: risk assessment,
  validate approach, pre-implementation review, security review of a plan.
triggers:
  - assess the risks of this approach
  - validate this plan before implementation
  - what could go wrong with this change
  - security review of a planned change
---

# Risk Analysis

Pre-implementation risk assessment. Validate a proposed approach, enumerate its risks, and
check for security implications — all before any code is written.

## Activation Protocol

Engage this skill at the refined-to-planned stage, once an `approach` and
`acceptance-criteria` exist. Before starting, have in hand:

- the task `acceptance-criteria` — what success looks like
- the task `scope-out` — what is explicitly excluded
- the task `affected-areas` — files and modules that will change
- the proposed `approach` — the implementation plan to validate

Read every file listed in `affected-areas` first. You cannot weight a risk you have not
grounded against the actual code.

## Workflow

1. **Validate the approach against acceptance criteria.** For each criterion, trace through
   the approach: is there a step that addresses it? Are steps missing? Does the approach
   assume something untrue in the current code? See
   [reference/risk-methodology.md](reference/risk-methodology.md).
2. **Enumerate risks** across the three categories — failure modes, edge cases, and
   architectural concerns. Detail and taxonomy in
   [reference/risk-methodology.md](reference/risk-methodology.md).
3. **Run the security review.** Check the approach and affected code against the shared
   security checklist: [reference/security-checklist.md](reference/security-checklist.md).
4. **Write findings.** Every risk must cite a specific file, function, or code pattern — no
   vague warnings. If no significant risks exist, say so explicitly rather than inventing
   concerns.

## Reference

- [reference/risk-methodology.md](reference/risk-methodology.md) — the risk taxonomy and
  the approach-validation procedure. Read it for step 1 and step 2.
- [reference/security-checklist.md](reference/security-checklist.md) — the shared security
  checklist. Read it for step 3. This file is the canonical, single-source security
  reference; the code-review skill reads the same file by relative path.
