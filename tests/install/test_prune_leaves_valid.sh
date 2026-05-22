#!/usr/bin/env bash
#
# AC#1 — no false positive.
# A symlink pointing to a repo skill that still exists on disk must survive
# the prune pass.
#
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

# Repo skill that exists on disk.
mkdir -p "$REPO_DIR/skills/real-skill"

# Valid symlink in the destination.
mkdir -p "$CLAUDE_DIR/skills"
ln -s "$REPO_DIR/skills/real-skill" "$CLAUDE_DIR/skills/real-skill"

run_install

[ "$RC" -eq 0 ] || fail "install.sh exited $RC, expected 0"
[ -L "$CLAUDE_DIR/skills/real-skill" ] || fail "valid skill symlink was wrongly pruned"

pass
