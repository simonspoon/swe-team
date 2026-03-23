---
name: skill-creator
description: Create custom Agent Skills with proper structure, YAML frontmatter, and instructions. Use when the user asks to create a new skill, build a skill, or make a custom Agent Skill.
---

# Skill Creator

Create new skills for the swe-team plugin. Skills are markdown files that teach Claude how to perform a specific task.

## When to Use

- User asks to create a new skill
- User wants to wrap a CLI tool as a skill
- User needs a workflow codified as a repeatable skill

## Core Rules

1. **SKILL.md under 200 lines.** Move large reference content to `reference/` files.
2. **One skill, one concern.** If it does two things, it's two skills.
3. **Derive from reality.** Look at existing skills in this plugin as templates, not abstract patterns.
4. **Ask before guessing.** If the skill's purpose or triggers are unclear, ask the user.

## Activation Protocol

### Step 1: Gather Requirements

Clarify with the user:
- **What does it do?** (one sentence)
- **When should it trigger?** (what keywords/scenarios)
- **Does it wrap a CLI tool?** (if so, which one)
- **Does it compose with other skills?** (which ones, at what stage)

If the user already provided clear requirements, skip to Step 2.

### Step 2: Pick a Reference Skill

Read 1-2 existing skills that are closest to what's being built:

| Building... | Read this skill as reference |
|---|---|
| CLI tool wrapper | `code-index/SKILL.md` or `nyx/SKILL.md` |
| Analysis/workflow | `simplify/SKILL.md` |
| Stateful process | `session-handoff/SKILL.md` |
| Multi-step with composition | `code-reviewer/SKILL.md` |
| Testing/verification | `loki-test-desktop/SKILL.md` or `khora-test-web/SKILL.md` |

Use the reference skill's structure as your template. Don't invent new structures.

### Step 3: Create the Skill

#### Directory structure

**Simple skill** (most skills):
```
skill-name/
└── SKILL.md
```

**Skill with reference material** (when SKILL.md would exceed 200 lines):
```
skill-name/
├── SKILL.md
└── reference/
    └── topic-name.md
```

#### SKILL.md format

```markdown
---
name: skill-name
description: What this skill does and when to use it. Include trigger keywords.
---

# Skill Name

One-line summary of what this skill does.

## When to Use
- Bullet list of trigger scenarios

## Prerequisites
- Required tools, install instructions (omit if none)

## Activation Protocol
1. Step-by-step instructions
2. Use imperative voice ("Read the file", not "You should read the file")
3. Include actual commands and examples inline

## [Domain-Specific Sections]
- Commands, workflows, rules — whatever the skill needs
- Keep it concrete and actionable

## Reference
- Links to reference/ files if they exist
```

#### Frontmatter rules

- **name**: lowercase-with-hyphens, under 64 chars, no "anthropic" or "claude"
- **description**: under 1024 chars. Must answer WHAT it does and WHEN to use it. Include trigger keywords that users would say (e.g., "testing iOS apps, simulator testing, UI automation").

### Step 4: Register the Skill

Add an entry to `SKILLS-INDEX.md` following the existing table format:
```
| **skill-name** | Purpose | When to invoke | Composes with |
```

### Step 5: Validate

Before declaring done:

- [ ] SKILL.md has valid frontmatter (name + description)
- [ ] Description includes trigger keywords
- [ ] SKILL.md is under 200 lines
- [ ] Instructions use imperative voice
- [ ] At least one concrete example or command
- [ ] Added to SKILLS-INDEX.md
- [ ] All file references resolve (no broken links)

### Step 6: Sync

Run `swe-sync` to refresh the plugin cache so the new skill is available.

## Anti-Patterns

- **Don't create troubleshooting files.** Put troubleshooting guidance inline where the problem would occur.
- **Don't create pattern/template libraries.** Real skills are the templates.
- **Don't over-structure.** A 50-line skill doesn't need subdirectories.
- **Don't duplicate content.** If guidance exists in another skill, link to it.
