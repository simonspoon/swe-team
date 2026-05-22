#!/usr/bin/env bash
#
# Run every limbodrain test and aggregate results.
# Exits 0 only if all tests pass.
#
set -uo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

PASS=0
FAIL=0

for t in test_*.sh; do
  if bash "$t"; then
    PASS=$((PASS + 1))
  else
    echo "FAIL: $t" >&2
    FAIL=$((FAIL + 1))
  fi
done

echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
