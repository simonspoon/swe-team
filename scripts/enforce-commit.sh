#!/bin/bash
# PreToolUse hook: block Co-Authored-By in git commits
# Parses CLAUDE_TOOL_INPUT JSON for the command field and rejects commits with attribution trailers.

COMMAND=$(echo "$CLAUDE_TOOL_INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('command',''))" 2>/dev/null)

if echo "$COMMAND" | grep -qi "git commit" && echo "$COMMAND" | grep -qi "Co-Authored-By\|Signed-off-by"; then
  echo "BLOCKED: Do not add Co-Authored-By or Signed-off-by to commits. Use /swe-team:git-commit skill instead."
  exit 1
fi

exit 0
