---
name: wisp-design
description: Design and build visual UI layouts using the Wisp desktop design tool and its CLI. Use when the user mentions wisp, designing UI, building layouts, creating mockups, visual design, placing components, arranging elements on a canvas, or iterating on a design visually.
---

# Designing UI with Wisp

Build, inspect, and iterate on visual UI layouts using the `wisp` CLI to control a live desktop canvas.

## How It Works

Wisp is a desktop design canvas controlled via CLI. The Wisp desktop app runs a WebSocket server on `ws://127.0.0.1:9847/ws`. The `wisp` CLI sends JSON-RPC commands to create, edit, and arrange design nodes. Changes appear on the canvas instantly. Humans can also drag/resize nodes directly on the canvas.

## Setup Checklist

1. The Wisp desktop app must be running (it starts the WebSocket server on port 9847)
2. The `wisp` CLI must be available (`wisp` or path to `target/release/wisp`)
3. `jq` must be installed (used to capture node IDs from JSON output)
4. Test connectivity: `wisp tree` should return the document tree without errors

## Quick Start

```bash
HEADER=$(wisp node add "Header" -t frame --width 800 --height 60 --fill "#1e40af" --json | jq -r .id)
wisp node add "Title" -t text --parent $HEADER -x 16 -y 16 --text "Dashboard" --font-size 24
wisp tree
wisp screenshot --out design.png
```

## Node Types

| Type | Flag | Use for |
|------|------|---------|
| `frame` | `-t frame` | Containers, panels, cards, sections (default) |
| `text` | `-t text` | Labels, headings, body text |
| `rectangle` | `-t rectangle` | Decorative shapes, bars, dividers |
| `ellipse` | `-t ellipse` | Circles, avatars, indicators |
| `group` | `-t group` | Logical grouping without visual style |

## Core Commands

| Command | Purpose |
|---------|---------|
| `wisp node add "<name>" -t <type> [opts]` | Create a node |
| `wisp node edit <id> [opts]` | Partial update (only set fields change) |
| `wisp node delete <id>` | Remove node + children |
| `wisp node show <id>` | Full node JSON |
| `wisp tree` | Print document tree |
| `wisp components list` | List component templates |
| `wisp components use <name> [opts]` | Instantiate a template |
| `wisp screenshot -o <path>` | Capture canvas as PNG (default: `wisp-screenshot.png`) |
| `wisp save <path>` / `wisp load <path>` | Persist / restore document |
| `wisp undo` / `wisp redo` | Undo/redo (100 levels) |
| `wisp session` | REPL mode (keeps connection open) |
| `wisp watch` | Stream change notifications |

### Node Options (for `add` and `edit`)

**Hierarchy (add only):** `-p, --parent <id>` (parent node ID, defaults to root)
**Layout:** `-x`, `-y`, `--width`, `--height`
**Style:** `--fill <hex>`, `--stroke <hex>`, `--stroke-width`, `--radius`, `--opacity`, `--z-index <int>`, `--clip`
**Text:** `--text <string>`, `--font-size`, `--font-family`, `--font-weight`, `--color <hex>`, `--text-align <left|center|right>`, `--text-wrap`
**Rename (edit only):** `--name <string>`
**Auto-layout:** `--layout-mode <none|flex>`, `--direction <row|column>`, `--align`, `--justify`, `--gap`, `--padding`
**Global:** `--json` (raw JSON output), `--url <ws-url>`

Always capture IDs: `ID=$(wisp node add "X" -t frame --json | jq -r .id)`

## Decision Tree

- **Building a list, stack, toolbar, or card with vertical content?** Read [reference/auto-layout.md](reference/auto-layout.md) for flexbox layout
- **Need color palette, positioning tips, z-index, or text wrapping?** Read [reference/design-reference.md](reference/design-reference.md)
- **Building a full page layout from scratch?** Read [reference/design-workflow.md](reference/design-workflow.md)
- **Something not working?** Read [troubleshooting/INDEX.md](troubleshooting/INDEX.md)

## Component Templates

| Template | Nodes | Use for |
|----------|-------|---------|
| `stat-card` | 4 | Statistics card (label + value + change) |
| `nav-item` | 3 | Navigation menu item |
| `button` | 2 | Rounded button with label |
| `chart-bar` | 3 | Single bar chart element |

```bash
wisp components use stat-card --parent $MAIN -x 20 -y 20 --label "Revenue" --value "$12,400"
```

## Gotchas

- **App must be running first.** CLI connects to the desktop app's WebSocket server.
- **IDs are UUIDs.** Capture from `--json` output. Root is `00000000-0000-0000-0000-000000000000`.
- **Partial edits are safe.** Only specified fields change; everything else preserved.
- **Flex children ignore x/y.** Auto-positioned by the flex container.
- **Screenshot for verification.** Always screenshot after significant changes to verify visually.
- **Session mode for bulk work.** Use `wisp session` when creating many nodes to avoid reconnection overhead.
