#!/usr/bin/env bash
# suda-observer.sh — reads NEW conversation exchanges, stores worthy memories
# Uses byte-offset tracking to avoid re-analyzing already-observed content.
[ "$SUDA_OBSERVER_ACTIVE" = "1" ] && exit 0

payload="$(cat)"
transcript="$(echo "$payload" | jq -r '.transcript_path // empty')"
session_id="$(echo "$payload" | jq -r '.session_id // empty')"
[ -z "$transcript" ] || [ ! -f "$transcript" ] && exit 0
[ -z "$session_id" ] && exit 0

(
  export SUDA_OBSERVER_ACTIVE=1

  # --- Offset tracking ---
  OFFSET_DIR="/tmp/suda-observer-offsets"
  mkdir -p "$OFFSET_DIR"
  OFFSET_FILE="$OFFSET_DIR/$session_id"

  file_size=$(wc -c < "$transcript" | tr -d ' ')
  last_offset=0
  if [ -f "$OFFSET_FILE" ]; then
    last_offset=$(cat "$OFFSET_FILE")
  fi

  # Nothing new to read
  [ "$file_size" -le "$last_offset" ] && exit 0

  # Minimum new content threshold (skip tiny increments like tool results)
  new_bytes=$((file_size - last_offset))
  [ "$new_bytes" -lt 500 ] && exit 0

  # --- Read new content with trailing context ---
  # Get ~20 lines of context before the offset for Sonnet to understand the conversation
  context_window=""
  if [ "$last_offset" -gt 0 ]; then
    # Read some content before the offset for context
    # Take up to 4000 bytes before the offset as context
    context_start=$((last_offset - 4000))
    [ "$context_start" -lt 0 ] && context_start=0
    context_bytes=$((last_offset - context_start))
    context_window=$(dd if="$transcript" bs=1 skip="$context_start" count="$context_bytes" 2>/dev/null)
  fi

  # Read new content from the offset
  new_content=$(dd if="$transcript" bs=1 skip="$last_offset" 2>/dev/null)

  # Update the offset to current file size
  echo "$file_size" > "$OFFSET_FILE"

  # --- Build the prompt for Sonnet ---
  sonnet_input=""
  if [ -n "$context_window" ]; then
    sonnet_input="=== PRIOR CONTEXT (for reference only — already observed) ===
$context_window

=== NEW CONTENT (analyze this for memory-worthy items) ===
$new_content"
  else
    sonnet_input="$new_content"
  fi

  echo "$sonnet_input" | claude --bare -p --model sonnet \
    --tools "Bash" \
    --system-prompt 'You are a memory observer analyzing a Claude Code conversation transcript.

Your job: identify genuinely memory-worthy items from the NEW CONTENT section and store them via suda. Prior context is provided only for understanding — do not store items from it.

## What to store

Only store items that would be USEFUL IN FUTURE SESSIONS. Ask: "Would a future Claude instance benefit from knowing this?"

Categories and when to use them:
- **feedback**: User corrections, explicit preferences, confirmed approaches, "do/don'"'"'t do X" instructions. These are the highest value — they prevent repeating mistakes.
- **user**: Role info, expertise signals, working style observations. Only store if it reveals something that would change how you interact.
- **project**: Architecture decisions with reasoning, non-obvious technical constraints, project status changes. Skip routine implementation details.
- **reference**: External resources, tool locations, API gotchas. Only if hard to rediscover.

## How to store

```bash
suda store --type <type> --name <kebab-case-name> --description '"'"'<one-line summary>'"'"' '"'"'<detailed content>'"'"'
```

## Quality rules for stored memories

- **Name**: kebab-case, descriptive, searchable. Include the key concept. Good: "no-co-authored-by-in-commits". Bad: "user-preference-1".
- **Description**: One line that tells you whether to read the full content. Should be grep-friendly.
- **Content**: For feedback type, ALWAYS include Why (what triggered this) and How-to-apply (specific actionable instruction). For project type, include enough context that a future session can act on it without re-investigating.
- **Append-only**: Do NOT check for duplicates or update existing entries. A separate consolidation agent handles dedup offline.

## What NOT to store

- Routine code changes, file edits, test runs
- Information that is already in the codebase (README, comments, docs)
- Vague observations ("the user seems to prefer X" — only store if explicitly stated)
- Tool output or error messages (unless they reveal a non-obvious gotcha)
- Anything from the PRIOR CONTEXT section

Be highly selective. Most conversation turns produce ZERO memory-worthy items. If nothing is noteworthy, output nothing and do nothing.' \
    "Analyze this conversation excerpt for memory-worthy items:" 2>/dev/null
) &
