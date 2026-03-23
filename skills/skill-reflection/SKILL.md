---
name: skill-reflection
description: Analyze user sessions to identify skill usage patterns, detect improvement opportunities, create actionable enhancement plans, and implement improvements to existing skills. Use when the user requests skill analysis, skill improvement, or session reflection on skill performance.
---

# Skill Reflection

Analyze user sessions to improve skill quality by identifying structural issues, missing guardrails, and clarity problems.

## Core Principle

**You are a generalist skill improver. You do NOT need domain knowledge.**

Your role is to identify:
- Structural problems (poor organization, missing files)
- Process problems (unclear steps, missing decision points)
- Clarity problems (ambiguous instructions, unexplained templates)
- Guardrail problems (no guidance for edge cases, missing escalation paths)

**NOT** to determine:
- Domain correctness (right table, correct API endpoint)
- Implementation details (specific code/query correctness)

When domain knowledge is needed → Ask the user or note "skill should define this term/concept"

## Quick Start

When user requests skill reflection:
1. Analyze conversation for improvement signals
2. Identify structural/process issues (not domain issues)
3. Create improvement plan with user consultation if needed
4. Implement improvements focused on clarity, structure, guardrails

## Critical Improvement Areas

### 1. Progressive Disclosure

**Problem Signal**: User got overwhelmed with information, or had to read through many examples to find what they needed.

**Fix**: 
- Break large files into focused, single-purpose files
- Create index files that list available resources by purpose
- Main SKILL.md points to indexes, not to full documents
- Each linked file is self-contained (no jumping around)

**Example Structure**:
```
skill-name/
  SKILL.md (entry point, always-needed info, decision tree)
  common-queries/
    INDEX.md (lists: user-lookup, patient-search, etc.)
    user-lookup.md (single query + full docs)
    patient-search.md
  troubleshooting/
    INDEX.md
    connection-errors.md
    no-results.md
```

### 2. Template Documentation

**Problem Signal**: User had to guess what placeholders mean, or wasn't sure how to fill them in.

**Fix**: Every template must explicitly document:
- What each placeholder represents
- How to get the replacement value (user provides? query first? from context?)
- Example with placeholders filled in
- What successful output looks like
- What to do if output doesn't match expected format

**Don't assume**: Model cannot infer that `[FirstName]` means "user's first name"

### 3. Guardrails with Context

**Problem Signal**: Model took wrong action when unexpected result occurred, or continued when it should have stopped.

**Fix**: Add conditional guidance:
- "If X AND Y, then do Z"
- "If 0 results AND user expects data, read troubleshooting/no-results.md"
- "If 0 results AND that may be valid, report to user: 'No data found for [criteria]. Is this expected?'"
- "If error contains 'Invalid object', read troubleshooting/schema-errors.md"
- "If unclear what user expects, ask: '[scripted question]'"

**Escalation paths**: Explicitly script when/how to ask user for help

### 4. Critical Instructions

**Problem Signal**: Model skipped a required step or didn't follow essential practice.

**Fix**: Mark universal requirements clearly:

```markdown
## ⚠️ CRITICAL REQUIREMENTS

- Always use `WITH (NOLOCK)` in all SELECT queries
- Always include `TOP 100` limit unless user specifies otherwise
- Always check `DeletedDate IS NULL` for soft-deleted records
```

Put these in main SKILL.md since they apply to EVERY operation.

### 5. Weak Model Optimization

**Problem Signal**: Skill has long prose, vague guidance, or expects reasoning.

**Fix**:
- Replace prose with instructions: "Do X" not "You might want to consider X"
- Be concise but complete: every word earns its place
- Don't sacrifice clarity for brevity
- Provide decision frameworks, not just conditions
- Use explicit step-by-step sequences
- Avoid "figure it out" - spell everything out

## Workflow

### Step 1: Identify Improvement Signals

Review session for:
- ❌ User corrected the agent multiple times
- ❌ Agent made assumptions about domain terminology
- ❌ Agent got stuck and didn't know how to proceed
- ❌ Agent chose wrong file/section because skill wasn't clear
- ❌ Agent didn't follow critical requirement
- ❌ User said "Could this not have been..." (overcomplexity signal)
- ❌ User said "actually means..." (domain definition missing)
- ❌ Agent used wrong template or filled it incorrectly

### Step 2: Categorize the Problem

Is this:
- **Structure**: Files too large, poor organization, no index
- **Clarity**: Vague instructions, unexplained terms, unclear steps
- **Guardrails**: No guidance for errors/edge cases, missing escalation
- **Templates**: Placeholders not documented, examples missing
- **Critical**: Required practices not marked as critical

**If domain knowledge is needed to categorize**: Ask user or note "skill needs to define [term]"

### Step 3: Plan Improvement

Create plan (may need user input):

```
Skill: [name]
Issue: [structural/clarity/guardrail problem]
Signal: [what in session indicated this]
Root Cause: [why skill failed to guide properly]
Proposed Fix:
  1. [specific structural/clarity improvement]
  2. [files to create/modify]
  3. [what to ask user if domain knowledge needed]
Expected Outcome: [how this helps weaker models]
```

### Step 4: Consult User if Needed

**Ask user about**:
- Domain terminology that skill should define
- Whether certain information is always needed vs sometimes
- What valid error conditions exist
- What edge cases matter

**Don't ask user about**:
- How to structure files (you decide)
- What makes instructions clear (your expertise)
- How to mark critical requirements (your call)

### Step 5: Implement

Follow implementation checklist:
- [ ] Read existing skill files
- [ ] If domain clarification needed, ask user first
- [ ] Make structural improvements (split files, create indexes)
- [ ] Add missing guardrails and decision points
- [ ] Document templates completely
- [ ] Mark critical requirements clearly
- [ ] Keep SKILL.md focused (up to ~100 lines of always-needed info)
- [ ] Validate YAML frontmatter
- [ ] Test that links work

## Common Anti-Patterns to Fix

### Anti-Pattern 1: "Figure it out" Instructions
❌ Bad: "Query the appropriate table based on what you're looking for"
✅ Good: "If looking for user info, read common-queries/user-lookup.md. If looking for patient info, read common-queries/patient-lookup.md"

### Anti-Pattern 2: Undocumented Templates
❌ Bad: Just showing `SELECT * FROM table WHERE name = '[Name]'`
✅ Good: Template + "Replace [Name] with the user's full name from their request. Example: If user says 'find John Doe', use 'John Doe'"

### Anti-Pattern 3: Missing Escalation
❌ Bad: No guidance when query returns unexpected results
✅ Good: "If 0 results and user expects data → read troubleshooting/no-results.md. If unclear whether 0 is valid → ask user: 'No records found for [criteria]. Is this expected?'"

### Anti-Pattern 4: Dumping Information
❌ Bad: Single file with 20 examples
✅ Good: Index listing 20 examples by purpose → agent reads index → picks one → reads only that file

### Anti-Pattern 5: Buried Critical Requirements
❌ Bad: "Remember to use WITH (NOLOCK)" buried in paragraph
✅ Good: "⚠️ CRITICAL: Always use `WITH (NOLOCK)`" at top of SKILL.md

## Validation Checklist

After improvements:
- [ ] SKILL.md is focused (always-needed info only, up to ~100 lines)
- [ ] Critical requirements clearly marked
- [ ] Decision points explicit ("If X then read Y")
- [ ] Guardrails include conditional logic and escalation paths
- [ ] Templates fully documented (placeholders, how to fill, example, expected output)
- [ ] Large files broken into indexed collections
- [ ] No assumptions about domain knowledge
- [ ] No "figure it out" instructions
- [ ] YAML frontmatter valid
- [ ] All links work

## When to Stop and Ask User

Stop and consult user when:
- Skill uses domain terminology you don't understand
- Multiple ways to structure and you need domain context to choose
- Unclear what error conditions are valid vs problematic
- Unclear what information is always needed vs contextual
- Need to verify whether your general knowledge applies to this domain

**Don't hesitate to ask** - getting domain info from user is better than making assumptions.
