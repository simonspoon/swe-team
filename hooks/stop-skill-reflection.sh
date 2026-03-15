#!/usr/bin/env bash
# Guard: only trigger skill-reflection once per user-prompt cycle
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
GUARD_FILE="/tmp/claude-skill-reflection-guard-$(echo "$REPO_ROOT" | md5 -q)"

# If guard flag exists, we already triggered for this cycle → skip
[ -f "$GUARD_FILE" ] && exit 0

# Set guard flag and trigger
touch "$GUARD_FILE"
echo "You just finished a task. Check if any skills (slash commands like /update-docs, /software-engineering, /project-manager, etc.) were invoked during this session. If skills were used, run /skill-reflection now to review the session and improve skill quality."
