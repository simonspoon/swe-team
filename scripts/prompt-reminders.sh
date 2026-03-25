#!/bin/bash
# UserPromptSubmit hook: inject skill routing reminders on every prompt
cat <<'EOF'
SKILL ROUTING: commits → /swe-team:git-commit | docs → /swe-team:update-docs | tests → /swe-team:test-engineer | reviews → /swe-team:code-reviewer
EOF
exit 0
