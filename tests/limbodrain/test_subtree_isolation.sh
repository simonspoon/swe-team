#!/usr/bin/env bash
#
# Phase 4 — subtree scope isolation.
# Proves AC#3: a task outside the targeted subtree is left untouched.
#
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

default_claude_stub

PARENT=$(limbo add "target parent")
CHILD=$(limbo add "target child" --parent "$PARENT")
OUTSIDER=$(limbo add "outsider task")
limbo status "$PARENT" refined >/dev/null
limbo status "$CHILD" refined >/dev/null
limbo status "$OUTSIDER" refined >/dev/null

set +e
"$LIMBODRAIN" "$PARENT" >/dev/null 2>&1
SCRIPT_EXIT=$?
set -e

[ "$SCRIPT_EXIT" -eq 0 ] || fail "limbodrain exited $SCRIPT_EXIT, expected 0"

# In-subtree tasks drained.
assert_status "$PARENT" done
assert_status "$CHILD" done

# Out-of-subtree task untouched.
STATUS=$(limbo show "$OUTSIDER" | python3 -c "import sys,json; print(json.load(sys.stdin).get('status',''))")
[ "$STATUS" != "done" ] || fail "outsider task was drained — subtree scope leaked"

pass
