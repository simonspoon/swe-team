#!/usr/bin/env bash
#
# Phase 10 — decomposition detection (risk H4).
# If the spawned agent decomposes a task (adds children) instead of completing
# it, drain_one must detect the child-count increase, stop polling the parent,
# return 0, and let the main loop pick up the new leaves.
#
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

PARENT=$(limbo add "will be decomposed")
limbo status "$PARENT" refined >/dev/null

# Counter-driven stub:
#   first invocation  — decompose: add a child under the target task
#   later invocations — mark the task done normally
install_claude_stub <<EOF
#!/usr/bin/env bash
ID="\${!#}"; ID="\${ID##* }"
COUNTER_FILE="$TMPDIR/invocation_count"
COUNT=\$(cat "\$COUNTER_FILE" 2>/dev/null || echo 0)
COUNT=\$((COUNT + 1))
echo "\$COUNT" > "\$COUNTER_FILE"
if [ "\$COUNT" -eq 1 ]; then
  CHILD=\$(limbo add "spawned child" --parent "\$ID")
  limbo status "\$CHILD" refined
else
  limbo status "\$ID" done --by stub
fi
EOF

# Bounded run.
set +e
LIMBODRAIN_POLL_INTERVAL=0 LIMBODRAIN_MAX_WAIT=10 timeout 30 "$LIMBODRAIN" "$PARENT" >/dev/null 2>&1
EXITCODE=$?
set -e

[ "$EXITCODE" -ne 124 ] || fail "limbodrain hung on a decomposed task"
[ "$EXITCODE" -eq 0 ]   || fail "limbodrain exited $EXITCODE, expected 0 after decomposition"

# Parent eventually drained.
assert_status "$PARENT" done

# The spawned child also drained. --show-all is required: `limbo list` excludes
# done tasks by default, so a drained child would otherwise be invisible.
CHILD_DONE=$(limbo list --show-all --parent "$PARENT" | python3 -c "
import sys, json
tasks = json.load(sys.stdin) or []
if not tasks:
    exit(1)
exit(0 if all(t.get('status') == 'done' for t in tasks) else 1)
" && echo yes || echo no)
[ "$CHILD_DONE" = yes ] || fail "spawned child task was not drained"

pass
