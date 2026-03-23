---
name: code-index
description: Generate a structural index of a codebase showing files and their exported symbols. Use when indexing a project, generating a code map, creating a codebase overview, or when you need to understand project structure quickly.
---

# Code Index

Index a codebase using **helios** — a tree-sitter-based code indexing CLI with SQLite storage. Maps files to their symbols (functions, types, classes, imports) so agents can orient instantly.

## When to Use

- Starting work on an unfamiliar codebase
- Agent needs to understand project structure before making changes
- Querying for specific symbols, dependencies, or code relationships
- Regenerating an outdated index after significant code changes

## Prerequisites

Install helios: `brew install simonspoon/tap/helios`

## Activation Protocol

1. Determine the project directory to index.
2. Check if `.helios/index.db` already exists — if so, run `helios update` (incremental). Otherwise run `helios init`.
3. Use `helios symbols`, `helios deps`, or `helios summary` to answer questions about the codebase.

## Commands

### Index a project (first time)
```bash
cd /path/to/project
helios init
```

### Incremental update (after code changes)
```bash
helios update
```

### Query symbols
```bash
# All symbols
helios symbols

# Filter by kind
helios symbols --kind fn
helios symbols --kind struct
helios symbols --kind trait

# Filter by file
helios symbols --file src/db.rs

# Search by name pattern
helios symbols --grep "create"

# Combine filters
helios symbols --kind fn --grep "auth" --file src/

# JSON output (for programmatic use)
helios symbols --json
```

### Trace dependencies
```bash
# What does a file import?
helios deps src/main.rs

# What depends on a file? (reverse deps)
helios deps src/db.rs
```

### Get a structural overview
```bash
# Full project summary (directory-grouped)
helios summary

# Summary of a specific path
helios summary src/parsers/
```

### Export to markdown (backward compat)
```bash
# Dump full index as markdown
helios export

# Save to file for agents that read markdown
helios export > .claude/code-index.md
```

## Reading an Existing Index

If `.helios/index.db` exists in the project, prefer querying it over grep/glob exploration. Use `helios symbols` for targeted lookups and `helios summary` for orientation.

For backward compatibility, if `.claude/code-index.md` exists (old format), it can still be read directly.

## Supported Languages

Go, Rust, Python, Swift, TypeScript, JavaScript (including .tsx/.jsx).

## What Gets Indexed

- **Go**: functions, methods, structs, interfaces, constants, imports — visibility by capitalization
- **Rust**: fn, struct, enum, trait, type, const, mod, use — visibility by `pub` keyword, scope by impl/trait/mod
- **Python**: functions, classes, constants, imports — visibility by underscore convention, class scope
- **TypeScript/JavaScript**: functions, classes, interfaces, types, enums, constants, imports — visibility by export keyword
- **Swift**: functions, classes, structs, enums, protocols, types, imports — visibility by access modifiers

## Output Format

`helios symbols` outputs one symbol per line:
```
file:line:col kind visibility name
```

`helios summary` outputs markdown grouped by directory:
```
## src/parsers/
### src/parsers/rust_parser.rs
- `struct` pub RustParser
- `fn` pub new
- `fn` private parse
```

All commands support `--json` for machine-readable output.

## Storage

- Index stored at `.helios/index.db` (SQLite) in the project root
- Add `.helios/` to `.gitignore`
- Incremental updates use git diff — fast re-indexing after changes
