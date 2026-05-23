#!/usr/bin/env bash
#
# AC(e) — IS_DOC regex must catch absolute project-root doc paths.
# A file_path of "$REPO_ROOT/docs/CHANGELOG.md" yields dirname="$REPO_ROOT/docs"
# (absolute, no trailing slash). The hook must classify this as IS_DOC=true via
# the /docs\b branch and exit 2 when no docs flag is set. Confirms the
# absolute-path coverage that the relative-path AC(a) test does not exercise.
#
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

clear_flag docs
run_hook "$REPO_ROOT/docs/CHANGELOG.md"

[ "$RC" -eq 2 ] || fail "absolute '\$REPO_ROOT/docs/CHANGELOG.md' did not block (exit=$RC, expected 2)"

pass
