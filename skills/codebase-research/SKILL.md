---
name: codebase-research
description: >
  Investigate an unfamiliar codebase to ground a task before design or implementation
  decisions are made. Explores code, documentation, and git history, then produces a
  structured research report with cited findings. Triggers: research this, investigate,
  deep dive, explore this topic, find out about, look into, analyze this.
triggers:
  - research how this works
  - investigate this part of the codebase
  - explore this topic before deciding
  - find out about a pattern or subsystem
---

# Codebase Research

Conduct deep research by exploring a codebase, reading documentation, and synthesizing
findings into a structured, actionable report. Used to ground a task before design
decisions are made.

## Activation Protocol

Engage this skill when a task needs investigation before it can be scoped or designed —
an unfamiliar subsystem, an unclear behavior, or a "how does X work" question. Before
starting, have in hand the research question and any prior context or constraints.

Begin with project orientation: check for `docs/INDEX.md`, fall back to `README.md`, and
if neither exists use Glob/Grep to explore structure. Then restate the research question
in your own words and confirm the scope if it is ambiguous.

## Workflow

The research procedure runs in five phases — scope and plan, codebase research,
documentation research, synthesis, and optional knowledge capture. Each phase, the
deep-research mode for cross-system surveys, and the structured report format are detailed
in [reference/research-workflow.md](reference/research-workflow.md).

High-level steps:

1. **Scope and plan** — parse the question into sub-questions, decide what "done" looks
   like, and draft the list of sources to consult.
2. **Codebase research** — Glob and Grep to locate relevant files, read them, trace data
   flows and call chains.
3. **Documentation research** — read applicable project docs and cross-reference their
   claims against actual code behavior.
4. **Synthesis** — organize findings by sub-question, resolve contradictions, assess a
   confidence level for each finding, and produce the structured report.
5. **Knowledge capture (optional)** — if the research produced reusable knowledge, offer
   to record it.

## Reference

- [reference/research-workflow.md](reference/research-workflow.md) — the five-phase
  workflow in full detail, the critical rules, the deep-research mode for industry/system
  surveys, and the structured report output format. Read it before starting research.
