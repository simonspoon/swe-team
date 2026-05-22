#!/usr/bin/env bash
#
# AC#4 — foreign-origin symlink is never touched.
# A symlink whose target lies outside REPO_DIR must survive the prune pass even
# when its target does not exist on disk. This is the blast-radius fence: only
# repo-owned symlinks are prune candidates.
#
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

# Symlink pointing outside REPO_DIR, to a path that does NOT exist on disk.
# A broken-OR logic bug (delete any dangling symlink) would wrongly remove it.
mkdir -p "$CLAUDE_DIR/skills"
ln -s /tmp/other-repo/skills/foreign-skill "$CLAUDE_DIR/skills/foreign-skill"

run_install

[ "$RC" -eq 0 ] || fail "install.sh exited $RC, expected 0"
[ -L "$CLAUDE_DIR/skills/foreign-skill" ] || fail "foreign symlink was wrongly pruned"

pass
