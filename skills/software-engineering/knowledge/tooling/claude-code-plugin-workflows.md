# Claude Code Plugin Workflows
Last updated: 2026-03-23
Last researched: 2026-03-23
Sources: experience

## Summary

Practical patterns for developing, publishing, and maintaining Claude Code plugins. Covers version management, marketplace configuration, and skill namespacing — the three areas where mistakes are most common.

## Key Principles

- **Version bumps drive updates**: `claude plugin update` only detects changes when the version in `.claude-plugin/plugin.json` changes. Editing skill files alone is not enough.
- **Namespace everything in plugins**: All skill references within a plugin must use `plugin-name:skill-name` format. The YAML frontmatter `name:` field stays as the short name — only invocation references get prefixed.
- **Marketplace paths must be self-contained**: Relative `source` paths in `marketplace.json` cannot use `../` — they must resolve within the marketplace directory.

## Practical Guidance

### Plugin version management

1. Edit your plugin skill files as needed
2. Bump the version in `.claude-plugin/plugin.json` before pushing
3. Push the changes to the remote
4. Run `claude plugin update <plugin-name>@<marketplace>` to pull the new version (e.g., `swe-sync` alias or `claude plugin update swe-team@claudehub`)

Forgetting step 2 is the most common mistake — the update command silently does nothing if the version hasn't changed.

### Marketplace setup

- **Relative source paths**: Must resolve within the marketplace directory. `../` is not supported and will fail silently or error.
- **HTTPS URL source**: If the plugin lives in a separate repo, use `"source": "url"` with an `https://` URL rather than a relative path.
- **GitHub source type**: Uses SSH by default. If SSH keys aren't configured on the machine, use URL source with `https://` instead.

### Plugin namespacing

When converting standalone skills to a plugin:

- Update every cross-reference between skills to use `plugin-name:skill-name` format
- The `name:` field in each skill's YAML frontmatter stays as the short name (e.g., `name: software-engineering`)
- Only invocation references — in SKILL.md prose, CLAUDE.md instructions, or other skills calling this one — get the prefix (e.g., `swe-team:software-engineering`)
- Missing a single cross-reference causes silent failures where the skill can't be found at runtime

## Related Topics

- [Rust Dependency Management](rust-dependency-management.md) (example of a tooling knowledge entry)
