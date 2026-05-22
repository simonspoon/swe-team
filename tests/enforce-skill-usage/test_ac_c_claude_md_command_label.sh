#!/usr/bin/env bash
#
# AC(c) — CLAUDE.md must include the "(command)" parenthetical on the
# commits → git-commit mapping (line ~9), matching the style used in the
# routing table at line ~39.
#
set -euo pipefail

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
CLAUDE_MD="$REPO_ROOT/CLAUDE.md"

pass() { echo "PASS: $(basename "$0")"; exit 0; }
fail() { echo "FAIL: $(basename "$0") — $1" >&2; exit 1; }

test -f "$CLAUDE_MD" || fail "CLAUDE.md not found at $CLAUDE_MD"

grep -q 'commits.*git-commit.*(command)' "$CLAUDE_MD" \
  || fail "CLAUDE.md 'commits → git-commit' mapping is missing the '(command)' parenthetical"

pass
