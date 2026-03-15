#!/usr/bin/env bash
# Clear the skill-reflection guard so it can trigger again after this new prompt
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
GUARD_FILE="/tmp/claude-skill-reflection-guard-$(echo "$REPO_ROOT" | md5 -q)"
rm -f "$GUARD_FILE"
