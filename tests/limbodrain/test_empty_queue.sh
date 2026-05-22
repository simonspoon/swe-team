#!/usr/bin/env bash
#
# Phase 7 — termination on an empty queue.
# Proves AC#2: limbodrain exits 0 when there is nothing to drain and never
# spawns the claude agent.
#
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

# Stub records any invocation. If the queue is empty it must never be called.
install_claude_stub <<EOF
#!/usr/bin/env bash
echo "called" >> "$TMPDIR/drain_order.log"
EOF

# No tasks added — limbo is freshly initialised and empty.
set +e
"$LIMBODRAIN" >/dev/null 2>&1
SCRIPT_EXIT=$?
set -e

[ "$SCRIPT_EXIT" -eq 0 ] || fail "limbodrain exited $SCRIPT_EXIT on empty queue, expected 0"

# claude stub must not have been called.
if [ -f "$TMPDIR/drain_order.log" ] && [ -s "$TMPDIR/drain_order.log" ]; then
  fail "claude was invoked on an empty queue"
fi

pass
