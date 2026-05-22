#!/usr/bin/env bash
#
# AC#4 — real directory is never touched.
# A real directory in CLAUDE_DIR/skills (not a symlink) must survive: it fails
# the -L symlink check, so the prune pass skips it.
#
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

# Real directory in the destination (mkdir, not ln) — simulates dante-trader.
mkdir -p "$CLAUDE_DIR/skills/dante-trader"

run_install

[ "$RC" -eq 0 ] || fail "install.sh exited $RC, expected 0"
[ -d "$CLAUDE_DIR/skills/dante-trader" ] || fail "real directory was wrongly removed"
[ ! -L "$CLAUDE_DIR/skills/dante-trader" ] || fail "real directory was replaced by a symlink"

pass
