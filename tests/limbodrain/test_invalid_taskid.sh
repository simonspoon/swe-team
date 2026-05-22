#!/usr/bin/env bash
#
# Phase 2 — invalid task id.
# Proves AC#5: an unknown taskid produces a clear error and a non-zero exit.
#
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

default_claude_stub

# Empty limbo, no tasks added. Run once; capture both exit code and output.
set +e
OUTPUT=$("$LIMBODRAIN" NOTEXIST 2>&1)
EXITCODE=$?
set -e

[ "$EXITCODE" -ne 0 ] || fail "expected non-zero exit for invalid taskid, got 0"

echo "$OUTPUT" | grep -qiE "(not found|invalid|does not exist|NOTEXIST)" \
  || fail "error message did not mention the invalid taskid: $OUTPUT"

pass
