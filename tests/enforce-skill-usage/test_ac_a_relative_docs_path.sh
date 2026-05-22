#!/usr/bin/env bash
#
# AC(a) — IS_DOC regex must catch relative project-root doc paths.
# A file_path of "docs/README.md" yields dirname="docs" (no slash). The hook
# must classify this as IS_DOC=true and exit 2 when no docs flag is set.
#
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

clear_flag docs
run_hook "docs/README.md"

[ "$RC" -eq 2 ] || fail "relative 'docs/README.md' did not block (exit=$RC, expected 2)"

pass
