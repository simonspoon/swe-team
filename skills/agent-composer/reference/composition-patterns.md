# Agent-Skill Composition Patterns

How agents load and use skills, and common composition patterns.

## How Agents Use Skills

Agents invoke skills via the `Skill` tool in their First Steps section:

```markdown
## First Steps (EVERY time)

1. Load the `/skill-name` skill with the Skill tool
```

When the Skill tool is invoked, the skill's SKILL.md is loaded into the agent's context. The agent then follows the skill's instructions as part of its workflow.

## Composition Rules

1. **Agents orchestrate, skills execute.** An agent defines WHEN and WHY; the skill defines HOW.
2. **Do not duplicate skill instructions in the agent.** Just load the skill and reference its capabilities.
3. **An agent can load multiple skills.** Load them in the First Steps section.
4. **Conditional loading is fine.** "Load `/skill-name` if the task involves X" is a valid pattern.
5. **Skills do not load agents.** The dependency is one-directional: agent -> skill.
6. **Check SKILLS-INDEX.md before composing.** Only reference skills that exist.

## Common Composition Patterns

### Orchestrator Agent
Loads: project-manager skill, project-docs-explore, software-engineering
Uses: Agent tool to dispatch subagents
Example: project-manager agent

Orchestrator body pattern — dispatch subagents with the Agent tool:
```markdown
## Core Workflow

### Phase 1: Decompose
1. Break the task into independent subtasks.

### Phase 2: Dispatch
1. For each subtask, launch a subagent with the Agent tool.
2. Provide the subagent with a focused prompt: what to do, where to do it, and what to output.
3. Wait for the subagent to complete before dispatching the next (or run in parallel if independent).

### Phase 3: Integrate
1. Collect subagent outputs.
2. Verify consistency across outputs.
3. Report the combined result to the user.
```

### Focused Worker Agent
Loads: 1-2 domain skills (e.g., test-engineer, code-reviewer)
Uses: Direct tool calls, no Agent tool
Example: A dedicated test-writing agent

### Meta Agent
Loads: skill-reflection, skill-trainer, or other meta skills
Uses: Analyzes and improves the skill ecosystem
Example: skill-trainer agent

### Pipeline Agent
Loads: Multiple skills in sequence for a workflow
Uses: Each skill for a different phase
Example: An agent that reviews code, generates tests, then sets up CI

## Skill Discovery

To find available skills, read `~/.claude/skills/SKILLS-INDEX.md`. It lists:
- Every active skill
- What each skill does
- When to invoke each skill
- Which skills compose together

## Anti-Patterns

### Duplicating skill logic
Bad: Agent body contains the full code review checklist.
Good: Agent loads `/swe-team:code-reviewer` and says "Run the code review process."

### Loading unnecessary skills
Bad: Agent loads every available skill "just in case."
Good: Agent loads only skills needed for its specific workflow.

### Circular dependencies
Bad: Agent A loads skill that expects agent B, which loads skill that expects agent A.
Good: Keep the dependency graph acyclic: agents -> skills -> reference files.

### Missing tool declaration
Bad: Agent loads `/skill-name` but doesn't include `Skill` in its tools list.
Good: If the agent uses the Skill tool, include `Skill` in the frontmatter tools.
