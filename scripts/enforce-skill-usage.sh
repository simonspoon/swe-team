#!/bin/bash
# PreToolUse hook for Edit and Write: block manual edits to files that should go through skills.
# Input comes via stdin as JSON. Output permissionDecision to deny.

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('session_id','unknown'))" 2>/dev/null)
STATE_DIR="/tmp/claude-skill-state"

# Extract file_path from tool_input
FILE_PATH=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))" 2>/dev/null)

# If we can't parse the file path, allow (don't block on parse failures)
if [ -z "$FILE_PATH" ]; then
  exit 0
fi

BASENAME=$(basename "$FILE_PATH")
DIRPATH=$(dirname "$FILE_PATH")

# --- Documentation file detection ---
IS_DOC=false
if echo "$DIRPATH" | grep -q "/docs\b\|/docs/"; then
  IS_DOC=true
fi
if echo "$BASENAME" | grep -qi "^README"; then
  IS_DOC=true
fi
# Don't flag CLAUDE.md, SKILL.md, or other config docs
if echo "$BASENAME" | grep -qi "CLAUDE.md\|SKILL.md\|REFERENCE.md\|INDEX.md\|plugin.json\|hooks.json"; then
  IS_DOC=false
fi

# --- Test file detection ---
IS_TEST=false
if echo "$FILE_PATH" | grep -qi "_test\.go\|_test\.rs\|\.test\.ts\|\.test\.js\|\.spec\.ts\|\.spec\.js\|test_.*\.py\|.*_test\.py"; then
  IS_TEST=true
fi
if echo "$DIRPATH" | grep -qi "/tests\b\|/test\b\|/__tests__"; then
  IS_TEST=true
fi

# --- Check skill flags ---
check_skill_flag() {
  local skill_name="$1"
  local flag_file="${STATE_DIR}/${SESSION_ID}-${skill_name}"
  [ -f "$flag_file" ] && return 0
  return 1
}

# --- Enforce ---
if [ "$IS_DOC" = true ]; then
  if ! check_skill_flag "update-docs"; then
    echo "BLOCKED: You are editing a documentation file without having invoked /swe-team:update-docs first. Call the Skill tool with skill=\"swe-team:update-docs\" BEFORE editing documentation files." >&2
    exit 2
  fi
fi

if [ "$IS_TEST" = true ]; then
  if ! check_skill_flag "test-engineer"; then
    echo "BLOCKED: You are editing a test file without having invoked /swe-team:test-engineer first. Call the Skill tool with skill=\"swe-team:test-engineer\" BEFORE writing or editing tests." >&2
    exit 2
  fi
fi

exit 0
