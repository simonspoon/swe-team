#!/usr/bin/env bash
#
# Static / structural checks.
# Proves AC#3: bash -n install.sh passes (no syntax errors introduced).
#
set -euo pipefail

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
SCRIPT="$REPO_ROOT/install.sh"

pass() { echo "PASS: $(basename "$0")"; exit 0; }
fail() { echo "FAIL: $(basename "$0") — $1" >&2; exit 1; }

test -f "$SCRIPT"            || fail "install.sh does not exist"
test -x "$SCRIPT"            || fail "install.sh is not executable"
head -1 "$SCRIPT" | grep -qE '^#!/' || fail "install.sh has no shebang"

bash -n "$SCRIPT" || fail "install.sh has a bash syntax error"

pass
