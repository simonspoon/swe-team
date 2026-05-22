#!/usr/bin/env bash
#
# Phase 8 — exact claude command shape.
# Proves AC#2: the spawn command is exactly
#   claude --dangerously-skip-permissions --agent project-manager --bg "Execute limbo task <id>"
#
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

T=$(limbo add "single task")
limbo status "$T" refined >/dev/null

# Stub records the full argv (one line per invocation), then flips to done.
install_claude_stub <<EOF
#!/usr/bin/env bash
echo "\$@" >> "$TMPDIR/invocations.log"
ID="\${!#}"; ID="\${ID##* }"
limbo status "\$ID" done --by stub
EOF

set +e
"$LIMBODRAIN" >/dev/null 2>&1
SCRIPT_EXIT=$?
set -e

[ "$SCRIPT_EXIT" -eq 0 ] || fail "limbodrain exited $SCRIPT_EXIT, expected 0"

test -f "$TMPDIR/invocations.log" || fail "no invocations.log — claude stub never ran"

LINES=$(wc -l < "$TMPDIR/invocations.log" | tr -d ' ')
[ "$LINES" -eq 1 ] || fail "expected exactly 1 claude invocation, got $LINES"

INVOCATION=$(cat "$TMPDIR/invocations.log")
EXPECTED="--dangerously-skip-permissions --agent project-manager --bg Execute limbo task $T"
[ "$INVOCATION" = "$EXPECTED" ] \
  || fail "unexpected claude argv: '$INVOCATION' (expected '$EXPECTED')"

pass
