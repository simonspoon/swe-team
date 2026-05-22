#!/bin/bash
# PostToolUse hook for Skill: sets a flag when a routable skill is invoked.
# Input comes via stdin as JSON.

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('session_id','unknown'))" 2>/dev/null)
STATE_DIR="/tmp/claude-skill-state"
mkdir -p "$STATE_DIR"

# Extract the skill name from tool_input
SKILL_NAME=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('skill',''))" 2>/dev/null)

# Map skill names to flag names (handle both short and namespaced forms)
case "$SKILL_NAME" in
  docs|swe-team:docs)
    touch "${STATE_DIR}/${SESSION_ID}-docs"
    ;;
  test-authoring|swe-team:test-authoring)
    touch "${STATE_DIR}/${SESSION_ID}-test-authoring"
    ;;
  code-review|swe-team:code-review)
    touch "${STATE_DIR}/${SESSION_ID}-code-review"
    ;;
  engineering-standards|swe-team:engineering-standards)
    touch "${STATE_DIR}/${SESSION_ID}-engineering-standards"
    ;;
esac

exit 0
