#!/bin/bash
# SessionStart hook: clear stale skill flags from prior sessions.
# Also clears flags for the current session so each session starts fresh.

STATE_DIR="/tmp/claude-skill-state"

# Clean up any flags older than 24 hours (stale sessions)
if [ -d "$STATE_DIR" ]; then
  find "$STATE_DIR" -type f -mmin +1440 -delete 2>/dev/null
fi

# Clear current session flags so we start fresh
SESSION_ID="${CLAUDE_SESSION_ID:-unknown}"
rm -f "${STATE_DIR}/${SESSION_ID}-"* 2>/dev/null

exit 0
