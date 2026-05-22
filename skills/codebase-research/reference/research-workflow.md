# Research Workflow

## Purpose

The full five-phase research procedure, critical rules, deep-research mode, and report
format used by the codebase-research skill. Loaded by the SKILL.md workflow before
starting any research.

## Content

### Phase 1: Scope and Plan

1. Parse the research question. Identify the core question, related sub-questions, and
   what "done" looks like (deliverable format, depth, audience).
2. Check for a conventions index in the project for prior research on this topic.
3. If prior research exists and is not stale, summarize it and ask whether to build on it
   or start fresh.
4. Draft a research plan listing sources to consult: codebase exploration, project
   documentation, git history, and existing knowledge entries.

### Phase 2: Codebase Research

When the question involves the current codebase:

1. Use Glob to find relevant files by name patterns.
2. Use Grep to search for key terms, function names, types, and patterns.
3. Read the most relevant files to understand implementation details.
4. Trace data flows and call chains when investigating behavior.
5. Note architectural patterns, dependencies, and design decisions.

### Phase 3: Documentation Research

1. Follow the project-orientation procedure to find relevant project docs.
2. Read applicable docs in full.
3. Cross-reference documentation claims against actual code behavior: Grep for function
   names, config keys, and patterns mentioned in docs to verify they exist and match.

### Phase 4: Synthesis

1. Organize findings by sub-question.
2. Identify contradictions between sources and resolve or flag them.
3. Distill actionable recommendations from raw findings.
4. Assess a confidence level for each finding:
   - **High** — corroborated by 2+ sources, or directly observed in code.
   - **Medium** — single authoritative source, or multiple supporting signals.
   - **Low** — uncorroborated inference, or based on stale documentation.
5. Produce the structured report using the output format below.

### Phase 5: Knowledge Capture (optional)

If the research produced reusable knowledge, offer to record it. Never write to a
knowledge base without confirmation.

### Critical Rules

1. **Cite sources.** Every finding must reference where it came from (file path, doc name,
   commit hash).
2. **Distinguish fact from inference.** Label conclusions drawn from evidence differently
   from directly observed facts.
3. **Check existing knowledge first.** Do not re-research topics already covered unless
   they are stale.
4. **Prioritize authoritative sources.** Official documentation and source code outweigh
   other references.
5. **Note staleness.** If a knowledge entry is older than 3 months, flag it.
6. **Do not modify code.** Produce reports, not patches.
7. **Scope discipline.** Stay focused on the research question. Note tangents for future
   investigation but do not pursue them.

### When Things Go Wrong

- **No project documentation found** — skip documentation research. Rely on codebase
  exploration. Note in the report that no project documentation was available.
- **Codebase too large to explore fully** — focus on the most relevant subsystems. Use
  Grep to narrow scope before reading files. State which areas were and were not explored.
- **Conflicting information** — present both sides with citations. Recommend which to
  trust and explain why.
- **Research question too broad** — break it into sub-questions. If a user is present,
  ask them to prioritize. If running autonomously, research breadth-first at shallow depth
  and flag sub-questions that need deeper investigation.

### Deep Research Mode (industry / system survey)

When the research question is "survey approaches to X", "what do existing systems do for
Y", or any cross-system comparison, switch into deep-research mode.

**Constraints:**

- **Max 6 systems** — pick the most relevant. Sample widely, then prune.
- **Max 1 page per system** — terse summaries, not exhaustive deep-dives.
- **Comparison matrix required** — systems as rows, dimensions as columns.

**Additional outputs** (on top of the standard report): the comparison matrix, 2-3
candidate options with trade-offs called out, and explicit open questions for what could
not be answered from public sources.

**When NOT to use:** codebase exploration (stay in standard mode) and single-system deep
dives (use standard mode, just go deep).

### Output Format

Structure every research report as:

```
## Research Report: [topic]

### Question
[The research question as understood]

### Key Findings
1. [Finding with source citation] (confidence: high/medium/low)
2. ...

### Analysis
[Deeper discussion connecting findings, resolving contradictions, explaining implications]

### Recommendations
- [Actionable recommendation based on findings]

### Sources
- [Source: type (code/doc/git), path, date if applicable]

### Open Questions
- [Anything that could not be resolved or needs further investigation]
```
