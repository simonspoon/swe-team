#!/usr/bin/env bash
#
# Phase 3 — leaf-first ordering / sequential drain (subtree scope).
# Proves AC#3 (children drain before parent) and AC#2 (exits 0 when drained).
#
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

PARENT=$(limbo add "parent task")
CHILD1=$(limbo add "child 1" --parent "$PARENT")
CHILD2=$(limbo add "child 2" --parent "$PARENT")
limbo status "$PARENT" refined >/dev/null
limbo status "$CHILD1" refined >/dev/null
limbo status "$CHILD2" refined >/dev/null

# Stub logs call order, then flips the task to done.
install_claude_stub <<EOF
#!/usr/bin/env bash
ID="\${!#}"; ID="\${ID##* }"
echo "\$ID" >> "$TMPDIR/drain_order.log"
limbo status "\$ID" done --by stub
EOF

set +e
"$LIMBODRAIN" "$PARENT" >/dev/null 2>&1
SCRIPT_EXIT=$?
set -e

[ "$SCRIPT_EXIT" -eq 0 ] || fail "limbodrain exited $SCRIPT_EXIT, expected 0"

test -f "$TMPDIR/drain_order.log" || fail "no drain_order.log — claude stub never ran"

PARENT_LINE=$(grep -n "$PARENT" "$TMPDIR/drain_order.log" | head -1 | cut -d: -f1)
CHILD1_LINE=$(grep -n "$CHILD1" "$TMPDIR/drain_order.log" | head -1 | cut -d: -f1)
CHILD2_LINE=$(grep -n "$CHILD2" "$TMPDIR/drain_order.log" | head -1 | cut -d: -f1)

[ -n "$PARENT_LINE" ] || fail "parent never drained"
[ -n "$CHILD1_LINE" ] || fail "child 1 never drained"
[ -n "$CHILD2_LINE" ] || fail "child 2 never drained"

[ "$CHILD1_LINE" -lt "$PARENT_LINE" ] || fail "child 1 drained after parent"
[ "$CHILD2_LINE" -lt "$PARENT_LINE" ] || fail "child 2 drained after parent"

assert_status "$PARENT" done
assert_status "$CHILD1" done
assert_status "$CHILD2" done

pass
