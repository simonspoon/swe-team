#!/bin/bash
# UserPromptSubmit hook: inject the plugin's CLAUDE.md as the mandatory protocol.
# Single source of truth — edit CLAUDE.md, next prompt sees the change.
cat "${CLAUDE_PLUGIN_ROOT}/CLAUDE.md"
exit 0
