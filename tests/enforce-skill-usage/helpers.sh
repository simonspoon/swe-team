#!/usr/bin/env bash
#
# Shared fixture for enforce-skill-usage.sh tests.
#
# Sourcing this file:
#   - resolves REPO_ROOT and HOOK (path to the script under test)
#   - points STATE_DIR at an isolated tmpdir (NOT the real /tmp/claude-skill-state)
#     by overriding it in the JSON payload's session_id — see note below
#   - registers a trap EXIT teardown that removes TMPDIR
#
# Note on isolation: the hook hardcodes STATE_DIR=/tmp/claude-skill-state. We
# can't override that without editing the hook. Instead, each test uses a
# unique SESSION_ID and cleans its own flag file before invoking the hook, so
# test runs do not collide with one another or with real Claude sessions.
#
set -euo pipefail

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
HOOK="$REPO_ROOT/scripts/enforce-skill-usage.sh"

STATE_DIR="/tmp/claude-skill-state"
mkdir -p "$STATE_DIR"

# Unique per-test session id, used to namespace the flag file.
TEST_SESSION="enforce-skill-usage-test-$$-$RANDOM"

teardown() {
  rm -f "$STATE_DIR/$TEST_SESSION"-*
}
trap teardown EXIT

pass() { echo "PASS: $(basename "$0")"; exit 0; }
fail() { echo "FAIL: $(basename "$0") — $1" >&2; exit 1; }

# run_hook <file_path> — feed a JSON payload to the hook, capturing exit code in $RC.
# Uses the test's TEST_SESSION so flag-file state stays isolated.
run_hook() {
  local file_path="$1"
  local payload
  payload=$(python3 -c "import json,sys; print(json.dumps({'session_id': sys.argv[1], 'tool_input': {'file_path': sys.argv[2]}}))" "$TEST_SESSION" "$file_path")
  set +e
  echo "$payload" | bash "$HOOK" >/dev/null 2>&1
  RC=$?
  set -e
}

# clear_flag <skill> — remove the flag file for this test's session.
clear_flag() {
  rm -f "$STATE_DIR/$TEST_SESSION-$1"
}
