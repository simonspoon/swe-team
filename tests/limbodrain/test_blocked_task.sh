#!/usr/bin/env bash
#
# Phase 9 — blocked-task guard.
# Proves drain_one detects a non-empty manualBlockReason, surfaces the blocker,
# and exits non-zero without hanging.
#
# IMPORTANT: limbodrain is invoked exactly ONCE. After the first run the task
# is blocked and excluded from `limbo list --unblocked`; a second run would
# drain nothing and false-fail the output assertion.
#
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

T=$(limbo add "will block")
limbo status "$T" refined >/dev/null

# Stub blocks the task instead of completing it. A non-empty manualBlockReason
# is how limbo expresses a blocked task — 'blocked' is not a valid status.
install_claude_stub <<'EOF'
#!/usr/bin/env bash
ID="${!#}"; ID="${ID##* }"
limbo block "$ID" --reason stub
EOF

# Bounded run: zero poll interval, short max-wait, hard timeout wrapper.
set +e
OUTPUT=$(LIMBODRAIN_POLL_INTERVAL=0 LIMBODRAIN_MAX_WAIT=5 timeout 10 "$LIMBODRAIN" 2>&1)
EXITCODE=$?
set -e

# timeout(1) exits 124 if it had to kill the process — that means it hung.
[ "$EXITCODE" -ne 124 ] || fail "limbodrain hung on a blocked task"

# A blocked task is not a clean drain — exit must be non-zero.
[ "$EXITCODE" -ne 0 ] || fail "limbodrain exited 0 despite a blocked task"

# Output must surface the blocked task id or the word 'blocked'.
echo "$OUTPUT" | grep -qiE "(blocked|$T)" \
  || fail "output did not surface the blocked task: $OUTPUT"

# The task really is blocked (manualBlockReason set).
limbo show "$T" | python3 -c "import sys,json; d=json.load(sys.stdin); exit(0 if d.get('manualBlockReason') else 1)" \
  || fail "task $T has no manualBlockReason — stub did not block it"

pass
