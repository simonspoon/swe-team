#!/usr/bin/env bash
#
# AC#2 — --check reports a stale symlink without deleting it.
# Check mode is read-only: it flags the stale entry (changes > 0) but leaves
# the symlink on disk.
#
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

# Stale skill symlink — same setup as test_prune_stale.sh.
mkdir -p "$REPO_DIR/skills/ghost-skill"
rmdir "$REPO_DIR/skills/ghost-skill"
mkdir -p "$CLAUDE_DIR/skills"
ln -s "$REPO_DIR/skills/ghost-skill" "$CLAUDE_DIR/skills/ghost-skill"

run_install --check

[ "$RC" -eq 0 ] || fail "install.sh --check exited $RC, expected 0"
grep -q '!!' <<<"$OUT" || fail "--check did not emit a '!!' marker for the stale entry"
grep -q 'out of sync' <<<"$OUT" || fail "--check summary did not report 'out of sync'"
# Check mode must not delete anything.
[ -L "$CLAUDE_DIR/skills/ghost-skill" ] || fail "--check deleted the stale symlink (should be read-only)"

pass
