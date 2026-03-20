---
name: code-index
description: Generate a structural index of a codebase showing files and their exported symbols. Use when indexing a project, generating a code map, creating a codebase overview, or when you need to understand project structure quickly.
---

# Code Index

Generate a persistent structural index of a codebase. Maps files to their exported symbols (functions, types, classes) so agents can orient instantly instead of repeated grep/glob.

## When to Use

- Starting work on an unfamiliar codebase
- Agent needs to understand project structure before making changes
- Regenerating an outdated index after significant code changes

## Activation Protocol

1. Determine the project directory to index.
2. Run the index generator script.
3. Save the output to `.claude/code-index.md` in the project.
4. Report how many files were indexed.

## Generate the Index

Ensure `.claude/` exists in the project first, then run:

```bash
mkdir -p /path/to/project/.claude
bash ~/.claude/skills/code-index/scripts/generate-index.sh /path/to/project > /path/to/project/.claude/code-index.md
```

To include test files:
```bash
mkdir -p /path/to/project/.claude
bash ~/.claude/skills/code-index/scripts/generate-index.sh --include-tests /path/to/project > /path/to/project/.claude/code-index.md
```

## Reading an Existing Index

If `.claude/code-index.md` exists in the project, read it before exploring the codebase. It provides a structural overview that eliminates the need for initial file discovery.

## Supported Languages

Go, Rust, Python, Swift, TypeScript, JavaScript (including .tsx/.jsx).

## What Gets Indexed

- **Go**: exported functions (uppercase), types (struct/interface)
- **Rust**: pub fn, pub struct, pub enum, pub trait, pub mod
- **Python**: top-level functions and classes (excludes `_private`)
- **Swift**: func, class, struct, protocol, enum
- **TS/JS**: export function, export class, export const, export type, export interface

Test files are excluded by default. Up to 12 symbols per file.

## Output Format

Markdown grouped by directory with symbols per file:

```
## internal/models/
- `task.go` — type Task struct, type Note struct, func IsValidStatus
```

## Limitations

- Grep-based extraction — does not parse ASTs. May miss some patterns.
- Does not index private/unexported symbols (by design).
- Does not track cross-file dependencies or call graphs.
