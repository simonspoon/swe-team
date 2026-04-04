# Go CLI Patterns (Cobra)
Last updated: 2026-04-03
Sources: experience (limbo project)

## Summary
Patterns for building Go CLI tools with Cobra, based on the limbo task manager. Covers command structure, flag management, storage patterns, and testing.

## Key Principles
- **One file per command** — each command gets its own file in `internal/commands/` with `init()` registering flags and `root.go` registering the command
- **Package-level flag vars** — declare flag vars at package level (e.g., `var searchPretty bool`), bind in `init()`, read in `RunE`
- **RunE over Run** — use `RunE` (returns error) so Cobra handles error display consistently
- **cobra.ExactArgs(N)** — let Cobra validate argument count at the framework level, don't hand-roll validation
- **JSON by default, --pretty for humans** — CLI tools consumed by agents should output JSON; `--pretty` flag for human-readable output
- **Shared helpers** — reuse output functions (`printTasksPretty`) and filter functions (`filterCompletedTasks`) across commands

## Practical Guidance
- New command checklist: create `cmd.go`, add flag vars + `init()`, implement `RunE`, register in `root.go`
- Storage: `storage.NewStorage()` in each command — it finds the project root by walking up looking for `.limbo/`
- Testing: use `setupTestEnv(t)` to create isolated temp dirs with `LIMBO_DIR` set. Reset flag vars before each test since they're package-level state
- Sort results consistently (e.g., by creation time) so output is deterministic
- Use `strings.Contains(strings.ToLower(...))` for case-insensitive search — no regex needed for simple matching
- **Portable data with ID remapping**: when importing data that references IDs (parent, blockedBy), build an old→new ID map first, then remap all references in a second pass. Drop references to IDs not in the import set rather than erroring.
- **Import modes**: `--replace` (wipe then load) vs merge (add alongside existing) is a common pattern for CLI import commands. Default to merge (safer), flag for replace.

## Linting (gocritic)
Projects using `golangci-lint` with gocritic enabled (check `.golangci.yml`) enforce these common rules:
- **paramTypeCombine**: `func(id string, content string, ...)` → `func(id, content string, ...)` — combine consecutive params of the same type
- **appendAssign**: `result := append(other, items...)` is flagged — append result must be assigned to the same slice variable, or build with `make` + `append`
- **filepathJoin**: `filepath.Join("/tmp/project", ...)` — literal paths containing separators are flagged. Use `t.TempDir()` in tests instead.
- Always check `.golangci.yml` in the project root for enabled linters and tag sets (diagnostic, style, performance)

## Related Topics
- [Rust CLI patterns](rust-cli-patterns.md) — similar principles, different ecosystem
