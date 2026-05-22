#!/usr/bin/env bash
#
# Shared fixture setup for install.sh tests.
#
# Sourcing this file:
#   - resolves REPO_ROOT and INSTALL_SH (path to the script under test)
#   - creates an isolated TMPDIR with a fake repo tree and a fake ~/.claude
#   - exports REPO_DIR and CLAUDE_DIR so install.sh targets the temp tree only
#     and never touches the real ~/.claude
#   - registers a trap EXIT teardown that removes TMPDIR
#
# install.sh reads REPO_DIR as ${REPO_DIR:-...} and CLAUDE_DIR as
# ${CLAUDE_DIR:-$HOME/.claude}, so exporting both via env is sufficient to
# fully isolate a test run.
#
set -euo pipefail

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
INSTALL_SH="$REPO_ROOT/install.sh"

TMPDIR=$(mktemp -d)

teardown() { rm -rf "$TMPDIR"; }
trap teardown EXIT

# Fake repo tree (the "source") and fake ~/.claude (the "destination").
# Strip any trailing slash from REPO_DIR — a trailing slash breaks the
# "$REPO_DIR/"* prefix check inside install.sh (it becomes //*, never matches).
REPO_DIR="${TMPDIR%/}/repo"
CLAUDE_DIR="${TMPDIR%/}/claude"
export REPO_DIR CLAUDE_DIR

mkdir -p "$REPO_DIR/skills" "$REPO_DIR/agents" "$REPO_DIR/commands"

pass() { echo "PASS: $(basename "$0")"; exit 0; }
fail() { echo "FAIL: $(basename "$0") — $1" >&2; exit 1; }

# run_install [args...] — run install.sh with the isolated env, capturing
# stdout+stderr into $OUT and the exit code into $RC. Never aborts the test.
run_install() {
  set +e
  OUT=$(REPO_DIR="$REPO_DIR" CLAUDE_DIR="$CLAUDE_DIR" bash "$INSTALL_SH" "$@" 2>&1)
  RC=$?
  set -e
}
