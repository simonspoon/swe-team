---
name: software-engineering
description: Self-evolving software engineering knowledge base. Apply and grow knowledge on architecture, debugging, code review, design patterns, testing, performance, and security. Captures personal preferences and lessons learned. Use when working on architecture decisions, debugging, code review, design patterns, testing strategy, performance optimization, security review, or when user shares engineering preferences or lessons.
---

# Software Engineering Knowledge Base

A self-evolving knowledge base that starts minimal and grows by researching topics, capturing preferences, and consolidating learnings. The knowledge/ and preferences/ directories are the living memory; this file is the immutable DNA.

**Skill root**: `~/.claude/skills/software-engineering/`

## Critical Requirements

- **Never upgrade project dependencies, toolchains, frameworks, or libraries without explicitly asking the user first.** Even if versions are outdated, present findings and ask for confirmation before making any changes.

## Activation Protocol

On every activation:

1. Read `preferences/INDEX.md`. If any category has >0 entries, read those preference files. If all are 0, skip to step 2.
2. Determine the SE domain(s) of the current task: architecture, debugging, patterns, testing, performance, security, code-review, tooling, or other.
3. Read `knowledge/INDEX.md`. If a relevant entry exists, read the knowledge file(s). If the index is empty, skip to step 5.
4. Apply combined knowledge to the task. **Preferences override general knowledge when they conflict.**
5. **Staleness check**: If any read knowledge file has a `Last researched` date older than 3 months, flag it as potentially stale. If the task depends on version-specific info (e.g., library versions, framework features), re-research before relying on that data.
6. If knowledge gaps are detected AND the task involves design decisions (not just implementation), follow the Research Protocol.
7. If the user expresses a preference or lesson, follow the Preference Capture Protocol.

## Research Protocol

**Trigger**: The task involves a topic where knowledge/INDEX.md has no entry, OR the existing entry is thin (under 20 lines), OR the user explicitly asks to research something.

**Do NOT research** when existing knowledge is sufficient or during urgent debugging (note the gap for later instead).

Process:
1. Use WebSearch to find authoritative, current sources on the topic.
2. Synthesize findings into a knowledge file using the Knowledge File Format below.
3. Create the domain subdirectory under `knowledge/` if it doesn't exist (e.g., `knowledge/patterns/`).
4. Write the file to `knowledge/<domain>/<topic-in-kebab-case>.md`.
5. Update `knowledge/INDEX.md` — add a row to the table.
6. Append a row to `meta/evolution-log.md`.
7. Briefly tell the user what was learned and stored.

## Preference Capture Protocol

**Trigger signals**:
- Explicit: "I prefer X", "always use X", "never do Y", "our convention is..."
- Implicit: User corrects your approach (ask: "Should I remember this preference for future sessions?")
- Lessons: "I learned that...", "we got burned by...", "the problem with X is..."

**Always confirm before saving.** Say: "I'd like to remember that [preference]. Should I save this?"

Process:
1. Determine category: `style.md` (conventions), `tooling.md` (tools/frameworks), or `lessons.md` (experiential).
2. Read the current file.
3. Append the new entry using the format documented in the file's comment block.
4. Update `preferences/INDEX.md` — increment the entry count.
5. Append a row to `meta/evolution-log.md`.

**Rule**: Never capture one-off situational choices. Only capture things the user indicates are general rules or recurring lessons.

## Knowledge File Format

Every file in `knowledge/` follows this structure:

```markdown
# [Topic Title]
Last updated: [YYYY-MM-DD]
Last researched: [YYYY-MM-DD] (required for tooling/library/framework files)
Sources: [URLs or "experience"]

## Summary
[2-3 sentence overview]

## Key Principles
- [Principle with brief explanation]

## Practical Guidance
[When to apply, how to apply, common pitfalls]

## Related Topics
- [Links to related knowledge files if they exist]
```

## Evolution & Consolidation

After every activation, check `meta/evolution-log.md` entry count.

**If log exceeds 50 entries**, trigger consolidation:
1. Survey all files via `knowledge/INDEX.md`.
2. Merge overlapping files in the same domain into single, refined files.
3. Remove redundant files and update INDEX.md.
4. Reset the evolution log with a consolidation summary entry.

**Guardrails**:
- **150 lines per file max.** If a file exceeds this, split into sub-topic files.
- **30 knowledge files max.** If exceeded, consolidate smallest/most-related files before creating new ones.
- **Staleness (general)**: If a file's "Last updated" date is 6+ months old and the topic comes up, re-research and refresh it.
- **Staleness (tooling/libraries/frameworks)**: If a file's "Last researched" date is 3+ months old and the task depends on version-specific info, re-research before relying on it. Update the "Last researched" date after refreshing.
- **Preference deduplication**: If a new preference contradicts an existing one, replace the old one (latest wins).

## Index Formats

**knowledge/INDEX.md**:

| Domain | Topic | File | Added |
|--------|-------|------|-------|

**preferences/INDEX.md**:

| Category | File | Entries |
|----------|------|---------|

## Rules

1. **Only modify SKILL.md via /skill-reflection.** During normal activation, only knowledge/, preferences/, and meta/ evolve.
2. **Read before write.** Always check existing knowledge before creating new files.
3. **Preferences win.** When general knowledge and a user preference conflict, follow the preference.
4. **Skip research during urgent debugging** unless asked. Apply best available knowledge; note the gap for later.
5. **Stable paths.** Use descriptive, kebab-case filenames. Never rename existing files without updating INDEX.md.
6. **Absolute paths.** Always use full paths: `~/.claude/skills/software-engineering/...`
7. **Be concise.** Knowledge files should be actionable, not encyclopedic. Favor practical guidance over theory.
