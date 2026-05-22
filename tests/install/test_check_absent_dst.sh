#!/usr/bin/env bash
#
# F2 guard — --check with absent destination directories.
# In --check mode the mkdir -p for SKILLS/AGENTS/COMMANDS_DST is skipped, so
# those dirs may not exist. prune_stale_symlinks must early-return cleanly via
# '[[ -d "$1" ]] || return 0' and not crash under set -euo pipefail.
#
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

# CLAUDE_DIR has no skills/, agents/, or commands/ subdirectories at all.
# (helpers.sh creates the repo tree but never the destination subdirs.)

set +e
ERR=$(REPO_DIR="$REPO_DIR" CLAUDE_DIR="$CLAUDE_DIR" bash "$INSTALL_SH" --check 2>&1 >/dev/null)
RC=$?
set -e

[ "$RC" -eq 0 ] || fail "install.sh --check exited $RC with absent dst dirs, expected 0"
[ -z "$ERR" ] || fail "install.sh --check wrote to stderr with absent dst dirs: $ERR"

pass
