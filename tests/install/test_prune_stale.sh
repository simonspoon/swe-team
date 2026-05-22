#!/usr/bin/env bash
#
# AC#1 — prune happy path, skill (directory-type symlink).
# A symlink in CLAUDE_DIR/skills pointing to a repo skill whose target no
# longer exists must be removed by a plain install run.
#
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

# Create then delete the repo skill so the symlink target is gone.
mkdir -p "$REPO_DIR/skills/ghost-skill"
rmdir "$REPO_DIR/skills/ghost-skill"

# Stale symlink in the destination, pointing at the now-gone repo path.
mkdir -p "$CLAUDE_DIR/skills"
ln -s "$REPO_DIR/skills/ghost-skill" "$CLAUDE_DIR/skills/ghost-skill"

run_install

[ "$RC" -eq 0 ] || fail "install.sh exited $RC, expected 0"
# -L catches a dangling symlink that -e would (misleadingly) report as absent.
[ ! -L "$CLAUDE_DIR/skills/ghost-skill" ] || fail "stale skill symlink was not pruned"
[ ! -e "$CLAUDE_DIR/skills/ghost-skill" ] || fail "stale skill entry still exists"

pass
