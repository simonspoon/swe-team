# Agent File Format Specification

Complete reference for Claude Code agent .md file structure.

## File Location

Agent files live in `~/.claude/agents/`. Each is a standalone Markdown file with YAML frontmatter.

## Frontmatter Fields

```yaml
---
name: agent-name              # Required. lowercase-with-hyphens, <64 chars
description: >                # Required. <1024 chars total. Multi-line with >
  First paragraph: what the agent does and when to use it.

  Examples:                   # 2-3 examples showing trigger scenarios
  - User: 'exact trigger phrase'
    Assistant: 'how the agent responds'

  - User: 'another trigger'
    Assistant: 'another response'

  Triggers: keyword1, keyword2, keyword3   # Comma-separated activation keywords
tools: Tool1, Tool2, Tool3   # Required. Comma-separated tool list
model: opus                   # Required. opus | sonnet | haiku
maxTurns: 200                 # Required. Integer, typical: 100-500
---
```

### Field Details

**name**
- Lowercase letters and hyphens only
- Under 64 characters
- Must not contain "anthropic" or "claude"
- Examples: `tech-lead`, `skill-trainer`, `code-review`

**description**
- Under 1024 characters total
- First paragraph: capabilities and when to use
- Examples section: 2-3 user/assistant conversation pairs
- Triggers line: keywords that activate the agent
- The description is what Claude uses to decide when to suggest this agent

**tools**
- Available tools: `Bash`, `Read`, `Write`, `Edit`, `Glob`, `Grep`, `Skill`, `Agent`
- Only include tools the agent actually uses
- `Skill` — needed if the agent loads other skills
- `Agent` — needed if the agent dispatches subagents (orchestrators only)
- Most agents need: `Bash, Read, Write, Edit, Glob, Grep, Skill`
- Orchestrator agents add: `Agent`

**model**
- `opus` — complex orchestration, multi-phase workflows, high-stakes decisions
- `sonnet` — focused work, single-concern tasks, code generation
- `haiku` — simple checks, formatting, lightweight validation

**maxTurns**
- Orchestrators: 300-500 (they manage multi-wave execution)
- Focused agents: 100-200 (single task flow)
- Simple agents: 50-100 (quick, targeted work)

## Body Structure

### 1. Title and Role Statement

```markdown
# You are the [Role Name]

You [core purpose in 1-2 sentences]. You [key approach or methodology].
```

Set the agent's identity and primary directive.

### 2. Personality (Optional)

```markdown
## Your Personality

You are [traits]. You:
- [Behavioral trait 1]
- [Behavioral trait 2]
- [Behavioral trait 3]
```

Only include if the agent needs specific behavioral guardrails (e.g., methodical testing, cautious deployment).

### 3. First Steps

```markdown
## First Steps (EVERY time)

1. Load the `/skill-name` skill with the Skill tool — it contains your reference materials
2. Load `/another-skill` if [condition]
3. [Any other initialization]
```

This runs on every activation. Include skill loading and initial context gathering.

### 4. Core Workflow

```markdown
## Core Workflow

### Phase 1: [Name]
1. [Step with clear action]
2. [Step with clear action]

### Phase 2: [Name]
1. [Step with clear action]
2. [Step with clear action]
```

Each phase should have:
- Clear entry condition (when to start this phase)
- Numbered steps with imperative instructions
- Clear exit condition (when the phase is done)
- Explicit handoff to next phase or user

### 5. Critical Rules

```markdown
## Critical Rules

1. **[Rule name].** [Rule explanation]
2. **[Rule name].** [Rule explanation]
```

Non-negotiable behaviors. Number them. Bold the rule name. Keep explanations concise.

### 6. Error Handling

```markdown
## When Things Go Wrong

- [Error condition] — [What to do]
- [Error condition] — [What to do]
```

Cover: skill load failures, unexpected input, missing prerequisites, tool failures.

### 7. Output Format (If Applicable)

```markdown
## Output Format

Structure every output as:

\```
[template]
\```
```

Only include if the agent produces structured output (reports, reviews, etc.).

## Style Guidelines

- **Imperative voice**: "Do X", "Run Y", not "You should X" or "Consider Y"
- **Explicit over implicit**: Spell out every step, don't assume the agent will infer
- **Progressive disclosure**: Main body has the workflow; reference files have details
- **No emoji in instructions**: Use **bold** and `code` for emphasis
- **Numbered rules**: Critical rules are always numbered for easy reference
- **Phase boundaries**: Make it clear when to stop, report, or wait for user input
