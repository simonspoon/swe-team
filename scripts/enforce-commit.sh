#!/bin/bash
# PreToolUse hook: block Co-Authored-By in git commits
# Input comes via stdin as JSON.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('command',''))" 2>/dev/null)

if echo "$COMMAND" | grep -qi "git commit" && echo "$COMMAND" | grep -qi "Co-Authored-By\|Signed-off-by"; then
  echo "BLOCKED: Do not add Co-Authored-By or Signed-off-by to commits. Use /swe-team:git-commit skill instead." >&2
  exit 2
fi

exit 0
