---
name: agent-composer
description: Compose and generate agent definition files (.md) for Claude Code from role descriptions, capabilities, and existing skills. Use when creating a new agent, building an agent, composing an agent from skills, or generating an agent definition.
---

# Agent Composer

Generate well-structured Claude Code agent definitions from role descriptions and capability requirements.

## Prerequisites

- Read `reference/agent-format.md` for the complete agent frontmatter and body specification.
- Read `reference/composition-patterns.md` for how agents compose with skills.
- Familiarity with SKILLS-INDEX.md to know available skills.

## Activation Protocol

1. Gather the agent requirements (see "Gathering Requirements" below).
2. Read `reference/agent-format.md` for the structural template.
3. Read `reference/composition-patterns.md` for skill composition guidance.
4. Read `~/.claude/skills/SKILLS-INDEX.md` to identify available skills.
5. List existing agents in `~/.claude/agents/` to check for overlap with the proposed agent.
6. Generate the agent .md file.
7. Validate against the checklist below.
8. Optionally create the symlink to `~/.claude/agents/`.

## Gathering Requirements

Collect these from the user (ask if not provided):

**Required:**
- **Name**: Agent role name (lowercase-with-hyphens)
- **Purpose**: What the agent does in 1-2 sentences
- **Workflow**: Step-by-step process the agent follows
- **Tools needed**: Which tools the agent uses (Bash, Read, Write, Edit, Glob, Grep, Skill, Agent)

**Optional (use sensible defaults):**
- **Model**: `opus` (default), `sonnet`, or `haiku`
- **maxTurns**: 200 (default for focused agents), 500 (for orchestrators)
- **Skills to load**: Which existing skills the agent should invoke
- **Personality traits**: Methodical, creative, cautious, etc.
- **Error handling**: What to do when things go wrong

If the user provides a complete spec, skip gathering and proceed to generation. However, ALWAYS perform steps 4-5 of the Activation Protocol (check SKILLS-INDEX.md and list existing agents for overlap) regardless of whether gathering was skipped.

## Generation Process

### Step 1: Write Frontmatter

```yaml
---
name: agent-name
description: >
  1-2 sentence description of what the agent does and when to use it.

  Examples:
  - User: '[trigger phrase]'
    Assistant: '[how agent responds]'

  - User: '[another trigger]'
    Assistant: '[response]'

  Triggers: keyword1, keyword2, keyword3
tools: Tool1, Tool2, Tool3
model: opus
maxTurns: 200
---
```

Rules for frontmatter:
- Name: lowercase-with-hyphens, under 64 characters
- Description: under 1024 characters total, includes examples AND triggers
- Examples: 2-3 user/assistant pairs showing activation scenarios
- Triggers: comma-separated keywords that match user intent
- Tools: only include tools the agent actually needs
- Model: match complexity to model (opus for orchestration, sonnet for focused work)

### Step 2: Write Agent Body

Follow this structure (read `reference/agent-format.md` for full details):

1. **Title and role statement** — "# You are the [Role Name]" + 1-sentence purpose
2. **First Steps section** — Skills to load on every activation, initial setup
3. **Core Workflow** — Numbered phases with clear entry/exit criteria
4. **Critical Rules** — Non-negotiable behaviors, formatted as a numbered list
5. **Error Handling** — What to do when things go wrong
6. **Output Format** — If the agent produces structured output, specify the format

### Step 3: Compose with Skills

For each skill the agent should use:
- Add a "Load `/skill-name`" step in the First Steps section
- Reference the skill's capabilities in the relevant workflow phase
- Do NOT duplicate skill instructions in the agent — just invoke the skill

### Step 4: Validate

Run through this checklist before finalizing:
- [ ] Frontmatter name is lowercase-with-hyphens, under 64 chars
- [ ] Description includes WHAT, WHEN, examples, and triggers
- [ ] Description is under 1024 characters
- [ ] Tools list matches actual tool usage in the body
- [ ] First Steps section loads required skills
- [ ] Workflow phases have clear entry/exit criteria (e.g., "Start when X is ready", "Done when Y is produced")
- [ ] Critical rules are explicit and numbered
- [ ] Error handling section exists
- [ ] Instructions are imperative ("Do X", not "You should X")
- [ ] No skills referenced that don't exist in SKILLS-INDEX.md

### Step 5: Install (Optional)

```bash
# Copy to agents directory
cp agent-file.md ~/.claude/agents/agent-name.md

# Or symlink from a managed directory
ln -sf /path/to/source/agent-name.md ~/.claude/agents/agent-name.md
```

## Example: Generating a Documentation Agent

**Input requirements:**
- Name: doc-writer
- Purpose: Generate and maintain project documentation
- Tools: Bash, Read, Write, Edit, Glob, Grep, Skill
- Skills: software-engineering, project-docs-explore
- Model: sonnet

**Generated output:**

```markdown
---
name: doc-writer
description: >
  Generate and maintain project documentation including READMEs, API docs, and
  architecture guides. Use when writing docs, updating documentation, or generating
  API reference from code.

  Examples:
  - User: 'Write documentation for the auth module'
    Assistant: 'I will use the doc-writer agent to generate docs for the auth module.'

  - User: 'Update the README to reflect the new API'
    Assistant: 'I will launch the doc-writer agent to update the README.'

  Triggers: write docs, update docs, documentation, README, API docs
tools: Bash, Read, Write, Edit, Glob, Grep, Skill
model: sonnet
maxTurns: 100
---

# You are the Doc Writer

You generate and maintain project documentation by reading source code, understanding
architecture, and producing clear, accurate documentation.

## First Steps (EVERY time)

1. Load `/swe-team:software-engineering` to understand project conventions.
2. Load `/swe-team:project-docs-explore` to find existing documentation.
3. Identify the documentation scope from the user's request.

## Core Workflow

1. Read target code files, identify public APIs and data flows.
2. Write documentation following project conventions with code examples.
3. Verify all code references are accurate and examples run.

## Critical Rules

1. Never document internals unless explicitly asked.
2. Always include usage examples for public APIs.
3. Match tone and style of existing project documentation.
4. If code is too complex to document, ask the user for context.
```

## When to Stop and Ask

Stop and consult the user when:
- Agent purpose is ambiguous or overlaps with an existing agent (check `~/.claude/agents/`)
- Unclear which tools the agent needs
- Uncertain whether to use opus or sonnet model
- Agent would need skills that don't exist yet — suggest: (a) create the skill first with `/swe-team:skill-creator`, (b) find a similar existing skill in SKILLS-INDEX.md, or (c) proceed without the skill and handle the capability inline
- Workflow has unclear decision points

## Reference

- [reference/agent-format.md](reference/agent-format.md) — Complete agent file specification
- [reference/composition-patterns.md](reference/composition-patterns.md) — How agents compose with skills
