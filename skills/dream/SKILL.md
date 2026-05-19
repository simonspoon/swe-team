---
name: dream
description: Offline knowledge-store hygiene — runs simaris lint/cluster/decay/vacuum, reviews findings, consolidates near-duplicates, and synthesizes patterns into skill/agent improvement recommendations. Run manually or on schedule.
---

# Dream — Knowledge-Store Hygiene

Offline maintenance for the simaris knowledge graph. This skill is a wrapper around simaris's built-in hygiene primitives — it runs them in the right order, interprets findings, acts on safe ones, and reports the rest for review.

## When to Invoke

- Manually via `/dream`
- On a scheduled cadence (daily or weekly)
- After a large session that added many units
- When `simaris search` / `simaris prime` output feels noisy

## Phase 1: Inventory & Audit

Get the lay of the land and surface rot in one pass.

```bash
simaris stats --json
simaris lint --by-aspect --fix-suggest --json
```

Report:
- Total units, by-type breakdown, inbox size, archived count, confidence histogram
- Lint findings by category: `PROCEDURE_NO_TRIGGER`, `ORPHAN`, `DUPE`, `DUAL_PARENT_DIVERGENCE`, `TAG_VARIANT`
- Per-aspect rollup (which aspects carry the most rot)

Lint is read-only and advisory. Save its `--json` output — later phases act on it.

## Phase 2: Near-Duplicate Consolidation

Detect and resolve near-duplicate clusters.

```bash
simaris cluster --all --json --threshold 0.3 --max-cluster-size 10
```

For each cluster annotated by simaris with `near-dup` / `temporal-log` / `type-confused`:

- **True duplicates** (same rule, different wording): Keep the unit with richest content + highest confidence. `simaris archive <id>` the others (soft-delete, reversible via `simaris unarchive`).
- **Complementary** (same topic, additive info): `simaris add` a merged unit with combined content and tags, then `simaris archive` the originals. Optionally `simaris link --rel supersedes <new_id> <old_id>`.
- **Type-confused** (same content stored under conflicting types): Decide the correct type per the type taxonomy (preference / procedure / principle / fact / lesson / idea / aspect), keep that one, archive the others.
- **Contradictory** (same topic, conflicting advice): Keep the newer / higher-confidence unit. Archive the older. Note the contradiction in the report.

Log every archive: ID, headline, reason.

## Phase 3: Lint Fixes

Walk the lint findings from Phase 1 and resolve what's safe to automate.

- **`PROCEDURE_NO_TRIGGER`**: Procedure units must have a `trigger` field. For each finding, read the unit (`simaris show <id>`), infer the trigger from content if obvious, then `simaris edit <id> --content "<body with trigger frontmatter>"`. If trigger isn't inferable, flag for user review.
- **`TAG_VARIANT`**: Near-duplicate tags (e.g. `claude-code` vs `claudecode`). Pick the canonical form, `simaris edit <id> --tags "<normalized list>"` on each affected unit. Report normalizations applied.
- **`ORPHAN`**: Units with no incoming or outgoing links. Don't auto-act — orphans may be legitimately standalone. List in report.
- **`DUAL_PARENT_DIVERGENCE`**: Complex case (same logical unit diverged under two aspects). Flag for review; don't auto-act.

## Phase 4: Decay & Vacuum

Run simaris's automated hygiene:

```bash
# Ebbinghaus decay — drops confidence on cold units, archives below 0.1
simaris dream decay --json

# Autolink cleanup — removes bad `related_to` edges from tag-overlap noise
simaris vacuum autolink --json
```

Both are idempotent. Decay is pinned-aware (slugged units and units linked via `part_of` are protected).

Then verify file-path references manually:

1. For each `fact` / `lesson` / `procedure` referencing a concrete file path: check if the file exists. If not, archive the unit and note "stale path: <path>" in the report.
2. For `project` tags whose project directory has been removed: archive units tagged with that project.

## Phase 5: Synthesize

Read across remaining live units to identify patterns:

1. **Recurring feedback themes**: 3+ `preference` or `lesson` units clustering around the same topic → recommend consolidating into a skill instruction or CLAUDE.md rule.
2. **Emerging conventions**: Same architectural decision across multiple project tags → recommend documenting as a `principle` unit with a clear `--tension` field.
3. **Skill gaps**: `lesson` units describing problems a skill should have prevented → recommend a skill improvement.
4. **Agent behavior gaps**: `preference` or `lesson` units suggesting an agent should behave differently by default → recommend an agent definition update.
5. **Missing aspects**: If many procedures cluster around an unnamed role, recommend creating an `aspect` unit with `--role` and `--dispatches-to`.

Do NOT auto-apply any recommendations. Output them for user review.

## Phase 6: Report

Output a structured report:

```
## Dream Report — <date>

### Inventory
- Total: X units (by type: P preferences, Q procedures, R principles, F facts, L lessons, I ideas, A aspects)
- Inbox: X pending
- Confidence: low / med / high distribution

### Lint Findings
- PROCEDURE_NO_TRIGGER: X (Y auto-fixed, Z flagged)
- TAG_VARIANT: X (Y normalized)
- ORPHAN: X (flagged)
- DUAL_PARENT_DIVERGENCE: X (flagged)

### Consolidation
- Clusters resolved: X (Y units archived, Z merged)
- [list: cluster pattern → action → IDs]

### Decay & Vacuum
- Decayed below threshold: X archived
- Autolink edges removed: X

### Stale References
- Path-not-found archives: [list]
- Removed-project archives: [list]

### Recommendations
1. [Skill/agent recommendation with reasoning]
2. [...]

### Summary
Before: X live units → After: Y live units (Z archived, W merged). Snapshot persisted via `simaris lint --snapshot`.
```

Optionally persist a lint snapshot at end: `simaris lint --snapshot --note "post-dream <date>"`. This enables future `simaris lint --history` / `--ci` regression checks.

## Rules

1. **Use archive, not delete.** `simaris archive` is reversible; `simaris delete` is interactive and gated. Dream never calls `delete`.
2. **Run lint before clustering.** Lint's findings inform Phase 3 fixes; clustering can shift structure underneath if you reorder.
3. **Recommendations are reported only.** Never auto-modify skills, agents, or CLAUDE.md.
4. **Log every destructive action.** Every `simaris archive` must be logged with reason. Every `simaris edit` to fix lint must be logged with the lint category.
5. **When in doubt, keep.** If a cluster's resolution isn't clearly correct, leave both units and flag for user review.
6. **Verify before pruning.** Check file existence and project state before archiving for "stale reference".
7. **Hook conflicts:** Some unit content may contain keywords that trigger PreToolUse hooks (e.g., a commit-trailer rule literally quoting the trailer name triggers `enforce-commit.sh`). When `simaris edit` is blocked, rephrase the description to avoid the trigger while preserving meaning.
