#!/usr/bin/env bash
#
# Phase 5 — full-queue drain (no-arg run).
# Proves AC#2: a no-arg run drains every unblocked leaf and exits 0.
#
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

default_claude_stub

T1=$(limbo add "task one")
T2=$(limbo add "task two")
limbo status "$T1" refined >/dev/null
limbo status "$T2" refined >/dev/null

set +e
"$LIMBODRAIN" >/dev/null 2>&1
SCRIPT_EXIT=$?
set -e

[ "$SCRIPT_EXIT" -eq 0 ] || fail "limbodrain exited $SCRIPT_EXIT, expected 0"

assert_status "$T1" done
assert_status "$T2" done

pass
