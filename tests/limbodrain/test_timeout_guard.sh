#!/usr/bin/env bash
#
# Phase 11 — poll-timeout guard (B2).
# If the spawned agent launches cleanly but never resolves the task (no done,
# no block, no decomposition), drain_one must hit the MAX_WAIT timeout and exit
# non-zero. The guard uses wall-clock time, so it must fire even at
# LIMBODRAIN_POLL_INTERVAL=0 — the case where a counter-based elapsed value
# would never advance and the loop would spin forever.
#
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

T=$(limbo add "never resolves")
limbo status "$T" refined >/dev/null

# Stub exits 0 (clean launch) but does NOT touch the task — it never reaches
# done, never gets blocked, never decomposed. drain_one must time out.
install_claude_stub <<'EOF'
#!/usr/bin/env bash
exit 0
EOF

# POLL_INTERVAL=0 is the load-bearing case for B2. MAX_WAIT=2 keeps the run
# short; the outer `timeout 15` is a hard safety net — if it has to kill the
# process the wall-clock guard failed to fire.
START=$(date +%s)
set +e
OUTPUT=$(LIMBODRAIN_POLL_INTERVAL=0 LIMBODRAIN_MAX_WAIT=2 timeout 15 "$LIMBODRAIN" 2>&1)
EXITCODE=$?
set -e
ELAPSED=$(( $(date +%s) - START ))

# timeout(1) exits 124 if it had to kill limbodrain — that means the guard
# never fired and the script hung.
[ "$EXITCODE" -ne 124 ] || fail "limbodrain hung — timeout guard never fired at POLL_INTERVAL=0"

# A timed-out task is not a clean drain — exit must be non-zero.
[ "$EXITCODE" -ne 0 ] || fail "limbodrain exited 0 despite a task that never resolved"

# The guard must have fired on its own, well before the 15s outer net.
[ "$ELAPSED" -lt 15 ] || fail "limbodrain ran ${ELAPSED}s — guard did not self-terminate"

# Output must surface the timeout.
echo "$OUTPUT" | grep -qiE "timed out" \
  || fail "output did not surface the timeout: $OUTPUT"

pass
