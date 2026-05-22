#!/usr/bin/env bash
#
# Phase 6 — sequential enforcement (one agent at a time).
# Proves AC#4: the next task is not spawned until the prior one reaches done.
# The stub logs start/end markers; correct sequencing yields strictly
# non-interleaved start/end/start/end ordering.
#
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

T1=$(limbo add "task one")
T2=$(limbo add "task two")
limbo status "$T1" refined >/dev/null
limbo status "$T2" refined >/dev/null

install_claude_stub <<EOF
#!/usr/bin/env bash
ID="\${!#}"; ID="\${ID##* }"
echo "start \$ID" >> "$TMPDIR/seq.log"
limbo status "\$ID" done --by stub
echo "end \$ID" >> "$TMPDIR/seq.log"
EOF

set +e
"$LIMBODRAIN" >/dev/null 2>&1
SCRIPT_EXIT=$?
set -e

[ "$SCRIPT_EXIT" -eq 0 ] || fail "limbodrain exited $SCRIPT_EXIT, expected 0"

test -f "$TMPDIR/seq.log" || fail "no seq.log — claude stub never ran"

LINES=$(wc -l < "$TMPDIR/seq.log" | tr -d ' ')
[ "$LINES" -eq 4 ] || fail "expected 4 log lines (start/end x2), got $LINES"

sed -n '1p' "$TMPDIR/seq.log" | grep -q '^start ' || fail "line 1 is not a start"
sed -n '2p' "$TMPDIR/seq.log" | grep -q '^end '   || fail "line 2 is not an end"
sed -n '3p' "$TMPDIR/seq.log" | grep -q '^start ' || fail "line 3 is not a start"
sed -n '4p' "$TMPDIR/seq.log" | grep -q '^end '   || fail "line 4 is not an end"

pass
