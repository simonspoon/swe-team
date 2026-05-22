#!/usr/bin/env bash
#
# Phase 1 — static / structural checks.
# Proves AC#1: bin/limbodrain exists, is executable, has a shebang.
#
set -euo pipefail

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
SCRIPT="$REPO_ROOT/bin/limbodrain"

pass() { echo "PASS: $(basename "$0")"; exit 0; }
fail() { echo "FAIL: $(basename "$0") — $1" >&2; exit 1; }

test -f "$SCRIPT"            || fail "bin/limbodrain does not exist"
test -x "$SCRIPT"            || fail "bin/limbodrain is not executable"
head -1 "$SCRIPT" | grep -qE '^#!/' || fail "bin/limbodrain has no shebang"

# bash -n syntax check — catches structural breakage cheaply.
bash -n "$SCRIPT" || fail "bin/limbodrain has a bash syntax error"

pass
