---
name: skill-creator
description: Create custom Agent Skills with proper structure, YAML frontmatter, instructions, and best practices. Use when the user asks to create a new skill, build a skill, or make a custom Agent Skill.
---

# Skill Creator

Create high-quality custom Agent Skills following Anthropic's specifications and best practices.

## Core Principle

**You are a skill structure architect, not a domain expert.**

Your role is to:
- ✅ Create valid YAML frontmatter
- ✅ Organize skill structure properly
- ✅ Write clear, actionable instructions
- ✅ Provide complete examples
- ✅ Ensure proper file organization

You do NOT:
- ❌ Guess at domain requirements without user input
- ❌ Create skills without understanding trigger conditions
- ❌ Make assumptions about what the skill should do

When domain knowledge is needed → Ask the user

## ⚠️ CRITICAL REQUIREMENTS

Every skill MUST have:
- SKILL.md file with valid YAML frontmatter
- Name: lowercase, hyphens only, <64 chars, no "anthropic"/"claude"
- Description: <1024 chars, specifies WHAT and WHEN (trigger conditions)
- At least one complete, runnable example
- Clear instructions (imperative, not suggestive)
- SKILL.md under 200 lines (move advanced content to separate files)
- Entry in SKILLS-INDEX.md (name, description, triggers, composition info)

## Quick Start

When user requests a skill:

1. **Gather requirements** - Read workflow/gather-requirements.md if unclear
2. **Choose pattern** - Read patterns/INDEX.md to select appropriate pattern
3. **Create structure** - Use selected pattern as template
4. **Validate** - Read validation/CHECKLIST.md before finalizing
5. **Test triggers** - Verify description includes relevant keywords

## What Type of Skill Are You Creating?

**User provided complete requirements:**
→ Read workflow/create-from-requirements.md

**User said "create a skill" but unclear scope:**
→ Read workflow/gather-requirements.md, ask clarifying questions

**Need to see examples of different skill types:**
→ Read patterns/INDEX.md

**User wants simple single-file skill:**
→ Read examples/minimal-skill.md, follow that pattern

**User wants skill with scripts/automation:**
→ Read examples/comprehensive-skill.md

## YAML Frontmatter Requirements

Template and documentation: Read templates/YAML-FRONTMATTER.md

**Quick reference:**
```yaml
---
name: skill-name
description: Brief description of what this skill does and when to use it
---
```

Critical rules:
- Name: lowercase-with-hyphens, <64 chars
- Description: Include capabilities AND trigger keywords
- No XML tags in either field

## Skill Structure

**Minimal skill:**
```
skill-name/
└── SKILL.md (frontmatter + instructions + examples)
```

**Comprehensive skill:**
```
skill-name/
├── SKILL.md (frontmatter + core instructions + navigation)
├── additional-guides/
│   ├── INDEX.md
│   └── guide-name.md
├── scripts/
│   └── utility.py
└── resources/
    └── reference.json
```

## When Things Go Wrong

**Skill doesn't trigger:**
→ Read troubleshooting/trigger-problems.md

**YAML validation fails:**
→ Read troubleshooting/yaml-errors.md

**SKILL.md too long (>200 lines):**
→ Read troubleshooting/file-too-long.md

**Unsure about structure:**
→ Read patterns/INDEX.md, pick closest match

**Validation fails:**
→ Read validation/CHECKLIST.md, identify failing requirement

## When to Stop and Ask User

Stop and consult user when:
- User said "create a skill for X" but X is ambiguous
- Unclear what triggers the skill (what keywords/scenarios)
- Don't know if skill needs scripts or multiple files
- Uncertain whether something is a critical requirement
- User mentions domain-specific terms without context
- Unclear what the skill's main purpose is

**Don't hesitate to ask** - getting requirements from user is better than creating wrong skill.

## How to Know the Skill Is Ready

✅ **YAML frontmatter is valid** (name and description meet all requirements)
✅ **Description includes triggers** (answers "when to use")
✅ **Has at least one complete example** (user can copy and run)
✅ **Instructions are imperative** (do X, not "you should X")
✅ **All file links work** (no broken references)
✅ **SKILL.md is focused** (<200 lines, advanced content in separate files)
✅ **Skill is listed in SKILLS-INDEX.md** (name, description, triggers, and composition info)

If all ✅, skill is ready.
If any ❌, read troubleshooting/INDEX.md

## Validation Before Finalizing

Before completing:
1. Read validation/CHECKLIST.md
2. Verify all critical requirements met
3. Test that all file references work
4. Confirm examples are complete and runnable
5. Verify YAML frontmatter is valid
6. Add the new skill to SKILLS-INDEX.md
7. Run `swe-sync` (or `claude plugin update swe-team@claudehub`) to refresh the plugin cache

## Resources

- [patterns/INDEX.md](patterns/INDEX.md) - Skill patterns and examples
- [workflow/](workflow/) - Creation workflows for different scenarios
- [validation/CHECKLIST.md](validation/CHECKLIST.md) - Complete validation checklist
- [troubleshooting/INDEX.md](troubleshooting/INDEX.md) - Common issues and fixes
- [templates/](templates/) - Templates for YAML, examples, etc.
- [examples/](examples/) - Complete skill examples
