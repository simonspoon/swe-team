#!/bin/bash
# PreToolUse hook for Edit and Write: block manual edits to files that should go through skills.
# Input comes via stdin as JSON. Output permissionDecision to deny.

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('session_id','unknown'))" 2>/dev/null)
STATE_DIR="/tmp/claude-skill-state"

# Resolve the plugin root from the script's own location (physical path, to
# neutralize symlinks anywhere in the script path). Used below to anchor the
# skills/ bypass guard so it matches ONLY this plugin's skills/ directory,
# not any mid-tree directory named "skills".
PLUGIN_ROOT=$(cd -P "$(dirname "$0")/.." 2>/dev/null && pwd)
[ -z "$PLUGIN_ROOT" ] && exit 0

# Extract file_path from tool_input
FILE_PATH=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))" 2>/dev/null)

# If we can't parse the file path, allow (don't block on parse failures)
if [ -z "$FILE_PATH" ]; then
  exit 0
fi

BASENAME=$(basename "$FILE_PATH")
DIRPATH=$(dirname "$FILE_PATH")

# --- Documentation file detection ---
# DIRPATH is the output of `dirname` (no trailing slash), so a bare "docs"
# from a relative path like "docs/README.md" must match via ^docs$, not ^docs\b
# (^docs\b would also false-positive on a "docs-extra" directory).
IS_DOC=false
if echo "$DIRPATH" | grep -q "/docs\b\|/docs/\|^docs$\|^docs/"; then
  IS_DOC=true
fi
if echo "$BASENAME" | grep -qi "^README"; then
  IS_DOC=true
fi
# Don't flag CLAUDE.md, SKILL.md, or other config docs
if echo "$BASENAME" | grep -qi "CLAUDE.md\|SKILL.md\|REFERENCE.md\|INDEX.md\|plugin.json\|hooks.json"; then
  IS_DOC=false
fi
# Files under THIS plugin's skills/ are skill content, not project documentation —
# never gate them as docs even when the path contains a "docs" segment (e.g. the
# docs skill itself). The guard is anchored to $PLUGIN_ROOT so a mid-tree
# directory named "skills" (e.g. /usr/local/project/modules/skills/...) does
# NOT suppress the doc gate. Claude Code emits absolute file_path values in
# PreToolUse tool_input, so no relative-path branch is needed.
if echo "$FILE_PATH" | grep -q "^$PLUGIN_ROOT/skills/"; then
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

# --- Source code file detection ---
# Real programming-language source. Excludes config/markup (.json .toml .yaml
# .md .css .html) and shell scripts, so editing hooks/config is never gated.
IS_CODE=false
case "$BASENAME" in
  *.rs|*.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs|*.go|*.py|*.c|*.cc|*.cpp|*.h|*.hpp|*.java|*.kt|*.rb|*.swift|*.cs|*.scala)
    IS_CODE=true
    ;;
esac

# --- Check skill flags ---
check_skill_flag() {
  local skill_name="$1"
  local flag_file="${STATE_DIR}/${SESSION_ID}-${skill_name}"
  [ -f "$flag_file" ] && return 0
  return 1
}

# --- Enforce ---
if [ "$IS_DOC" = true ]; then
  if ! check_skill_flag "docs"; then
    echo "BLOCKED: You are editing a documentation file without having invoked /swe-team:docs first. Call the Skill tool with skill=\"swe-team:docs\" BEFORE editing documentation files." >&2
    exit 2
  fi
fi

if [ "$IS_TEST" = true ]; then
  if ! check_skill_flag "test-authoring"; then
    echo "BLOCKED: You are editing a test file without having invoked /swe-team:test-authoring first. Call the Skill tool with skill=\"swe-team:test-authoring\" BEFORE writing or editing tests." >&2
    exit 2
  fi
fi

# Plain source files (not tests, not docs) require the engineering-standards skill —
# it loads project conventions before any code is written.
if [ "$IS_CODE" = true ] && [ "$IS_TEST" = false ] && [ "$IS_DOC" = false ]; then
  if ! check_skill_flag "engineering-standards"; then
    echo "BLOCKED: You are editing a source file without having invoked /swe-team:engineering-standards first. Call the Skill tool with skill=\"swe-team:engineering-standards\" BEFORE writing or modifying code — it loads project conventions that must inform the change." >&2
    exit 2
  fi
fi

exit 0
