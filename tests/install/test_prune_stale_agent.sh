#!/usr/bin/env bash
#
# AC#1 — prune happy path, agent (file-type .md symlink).
# Ensures the 'for entry in "$1"/*' glob (no trailing slash) covers file-type
# symlinks. A trailing-slash glob would silently skip stale .md agent symlinks.
#
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

# Create then delete the repo agent file so the symlink target is gone.
: > "$REPO_DIR/agents/ghost-agent.md"
rm "$REPO_DIR/agents/ghost-agent.md"

# Stale .md symlink in the destination.
mkdir -p "$CLAUDE_DIR/agents"
ln -s "$REPO_DIR/agents/ghost-agent.md" "$CLAUDE_DIR/agents/ghost-agent.md"

run_install

[ "$RC" -eq 0 ] || fail "install.sh exited $RC, expected 0"
[ ! -L "$CLAUDE_DIR/agents/ghost-agent.md" ] || fail "stale agent symlink was not pruned"
[ ! -e "$CLAUDE_DIR/agents/ghost-agent.md" ] || fail "stale agent entry still exists"

pass
