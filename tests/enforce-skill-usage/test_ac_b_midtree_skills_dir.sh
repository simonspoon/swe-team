#!/usr/bin/env bash
#
# AC(b) — skills/ guard must be anchored to the plugin root.
#
#   Sub-check 1 (false-positive blocked): an absolute path with a mid-tree
#   directory named "skills" (e.g. /usr/local/project/modules/skills/docs/foo.md)
#   must NOT suppress the doc gate. Expect exit 2.
#
#   Sub-check 2 (project skills/ allowed): a file under THIS repo's skills/
#   directory must suppress the doc gate. Expect exit 0. The injected path
#   is derived from `git rev-parse --show-toplevel` so the test is portable
#   across machines and CI.
#
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

# --- Sub-check 1: mid-tree "skills" is NOT a bypass ---
clear_flag docs
run_hook "/usr/local/project/modules/skills/docs/foo.md"
[ "$RC" -eq 2 ] || fail "mid-tree '/skills/' incorrectly suppressed doc gate (exit=$RC, expected 2)"

# --- Sub-check 2: project skills/ IS a bypass ---
REPO_TOP=$(git rev-parse --show-toplevel)
clear_flag docs
run_hook "$REPO_TOP/skills/docs/foo.md"
[ "$RC" -eq 0 ] || fail "project '$REPO_TOP/skills/' did not bypass doc gate (exit=$RC, expected 0)"

pass
