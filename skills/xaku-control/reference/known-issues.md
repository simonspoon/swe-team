# Known Issues & Notes

## Shell Initialization Timing

**Issue:** After `xaku new-workspace`, the shell (zsh/bash) needs time to initialize. Commands sent immediately may arrive before the shell is ready to process them.

**Workaround:** Wait 1-3 seconds after creating a workspace before sending commands or reading output:
```bash
xaku new-workspace --cwd /path
sleep 2
xaku send --workspace workspace:N "echo hello"
xaku send-key --workspace workspace:N Enter
```

The `--command` flag handles this internally with a small delay, but heavy shell configs may still need extra time.

## Screen Content Includes Prompt Decorations

**Issue:** `read-screen` returns raw terminal text including prompt decorations (starship, powerlevel10k, etc.) as unicode characters. This can make output harder to parse programmatically.

**Workaround:** Look for your command's output between prompt lines. Or send commands that produce clean, parseable output (JSON, etc.).

## Single-Character Keys

**Note:** For single-character keypresses (like `q` to quit a TUI, or `j`/`k` for navigation), use `send` instead of `send-key`:
```bash
# Correct — use send for single chars
xaku send --workspace workspace:N "q"

# send-key is for special keys only
xaku send-key --workspace workspace:N Enter
```

## Daemon Socket

The daemon socket is at `/tmp/xaku-{uid}.sock`. If the daemon crashes without cleaning up, the stale socket may prevent restart. Fix by removing it:
```bash
rm /tmp/xaku-*.sock
```

## No Browser Support

xaku is a terminal multiplexer only. For browser automation, use the `web-verify` skill with the `khora` CLI.
