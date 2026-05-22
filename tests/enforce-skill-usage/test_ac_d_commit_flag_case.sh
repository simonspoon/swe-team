#!/usr/bin/env bash
#
# AC(d) — the dead 'commit|swe-team:commit' case must be REMOVED from
# scripts/skill-flag-set.sh. Single-branch check: only the "removed" outcome
# passes (a documented-but-still-present case is NOT acceptable per the
# PLANNER approach).
#
set -euo pipefail

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
SCRIPT="$REPO_ROOT/scripts/skill-flag-set.sh"

pass() { echo "PASS: $(basename "$0")"; exit 0; }
fail() { echo "FAIL: $(basename "$0") — $1" >&2; exit 1; }

test -f "$SCRIPT" || fail "skill-flag-set.sh not found at $SCRIPT"

# Must be zero occurrences of the case pattern.
COUNT=$(grep -cE 'commit\|swe-team:commit' "$SCRIPT" || true)
[ "$COUNT" -eq 0 ] || fail "'commit|swe-team:commit' case still present ($COUNT occurrence(s))"

pass
