#!/usr/bin/env bash
#
# Shared fixture setup for limbodrain tests.
#
# Sourcing this file:
#   - resolves REPO_ROOT and LIMBODRAIN (path to the script under test)
#   - creates an isolated TMPDIR with its own .limbo store inside a git repo
#   - registers a trap EXIT teardown that removes TMPDIR
#   - prepends $TMPDIR/bin to PATH so a stubbed `claude` shadows the real one
#
# Each test must still write its own $TMPDIR/bin/claude stub via
# `install_claude_stub` or `default_claude_stub`.
#
set -euo pipefail

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
LIMBODRAIN="$REPO_ROOT/bin/limbodrain"

TMPDIR=$(mktemp -d)
export LIMBO_DIR="$TMPDIR/.limbo"

teardown() { rm -rf "$TMPDIR"; }
trap teardown EXIT

cd "$TMPDIR"

# limbodrain resolves its working dir via `git rev-parse --show-toplevel`, so the
# throwaway store must live inside a git repo of its own.
git init -q "$TMPDIR"
git -C "$TMPDIR" config user.email test@example.com
git -C "$TMPDIR" config user.name test

limbo init --no-climb >/dev/null

mkdir -p "$TMPDIR/bin"
export PATH="$TMPDIR/bin:$PATH"

# install_claude_stub <<'EOF' ... EOF  — write a stubbed claude from stdin.
install_claude_stub() {
  cat > "$TMPDIR/bin/claude"
  chmod +x "$TMPDIR/bin/claude"
}

# Default stub: parse the task id from the last argument ("Execute limbo task <id>")
# and flip that task to done.
default_claude_stub() {
  install_claude_stub <<'EOF'
#!/usr/bin/env bash
ID="${!#}"
ID="${ID##* }"
limbo status "$ID" done --by stub
EOF
}

pass() { echo "PASS: $(basename "$0")"; exit 0; }
fail() { echo "FAIL: $(basename "$0") — $1" >&2; exit 1; }

# assert_status <id> <expected-status>
assert_status() {
  local got
  got=$(limbo show "$1" | python3 -c "import sys,json; print(json.load(sys.stdin).get('status',''))")
  [ "$got" = "$2" ] || fail "task $1 status is '$got', expected '$2'"
}
