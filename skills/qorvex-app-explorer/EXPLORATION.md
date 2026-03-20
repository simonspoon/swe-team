# Exploration Strategies

Advanced techniques for thoroughly mapping complex apps.

## Handling Authentication Walls

Many apps require login before showing main content.

1. Screenshot the login/signup screen and record all fields and options.
2. If test credentials are available, log in and continue exploration.
3. If no credentials, record the auth screens as the entry point and note that deeper exploration requires authentication.
4. Check for "Skip" or "Continue as Guest" options.
5. Record social login options (Apple, Google, etc.) as features but don't tap them.

## Tab-Based Apps

Most iOS apps use a tab bar. Explore systematically:

1. Count tabs and record their labels/icons.
2. Start with tab 1 — fully explore its screen tree.
3. Move to tab 2 — fully explore, noting any screens shared with tab 1.
4. Repeat for all tabs.
5. Record cross-tab navigation (e.g., tapping an item in Search navigates to a Detail screen that also appears under Home).

## Deep Navigation Hierarchies

For apps with deeply nested navigation:

1. Track your navigation depth as a breadcrumb trail.
2. After exploring a deep screen, navigate back step by step, verifying each screen.
3. Use screenshots to confirm you're at the expected screen before continuing.
4. If back navigation fails (no back button, gesture doesn't work), restart the app and navigate from root.

## Scrollable Content

Screens may extend beyond the visible viewport:

1. Run screen-info to get initial elements.
2. `qorvex swipe up` and run screen-info again.
3. Compare element lists — if new elements appeared, continue swiping.
4. Repeat until no new elements appear (or the same elements repeat, indicating bounce).
5. Record the full element list as the union of all scroll positions.
6. Swipe back down to return to top before navigating away.

## Dynamic Content

Some screens change based on state:

- **Empty states** — screens with no data (e.g., empty cart, no messages). Note these.
- **Loading states** — use `wait-for` to let content load before screen-info.
- **Error states** — toggling airplane mode can reveal error UIs (only if safe to do).
- **Conditional UI** — some elements appear only after certain actions. Record conditions.

## Complex Controls

### Segmented Controls / Tab Views
Tap each segment and record the content change. Treat each as a sub-view of the same screen.

### Action Sheets / Context Menus
Long-press or tap option buttons to reveal. Screenshot the sheet, record all options, dismiss.

### Swipe Actions on Cells
Swipe left (and right) on list cells to discover hidden actions (delete, archive, flag, etc.).

### Pull-to-Refresh
Swipe down from the top of scrollable content. Note if new content loads or a spinner appears.

## Cycle Detection

Avoid infinite loops by tracking visited screens:

1. Create a screen signature: `"{nav_title}|{first_5_element_labels}"`.
2. Before recording a "new" screen, check if its signature matches a known screen.
3. If it matches, record the navigation link but don't re-explore the screen.
4. Some screens look identical but have different content (e.g., detail screens for different items). In this case, record the screen template once and note it's parameterized.

## Physical Device Considerations

- Commands have ~1-2s latency over WiFi. Add brief pauses in scripts.
- Use `wait-for` liberally instead of fixed delays.
- `start-target`/`stop-target` don't work — use `xcrun devicectl` instead.
- Agent deploy takes 30-60s on first connection.

## When to Stop Exploring

Stop when:
- All tab bar items have been explored.
- All navigation targets from every discovered screen have been visited.
- Scrolling reveals no new interactive elements.
- Remaining untapped elements are clearly destructive or require real accounts/data.

Record what was left unexplored and why (e.g., "Delete Account — skipped, destructive").

## Non-Tab-Bar Apps

Some apps use navigation controllers, sidebars, or single-screen layouts instead of a tab bar.

1. Start from the root screen and identify the primary navigation mechanism (hamburger menu, sidebar, nav buttons, or inline links).
2. If a hamburger/sidebar menu exists, open it and treat each menu item as equivalent to a tab — explore each fully.
3. For single-screen apps (e.g., calculators, utilities), focus on interaction testing rather than screen discovery.
4. For navigation-only apps (push/pop), follow the depth-first path from root, backing out at each dead end.

## Session Recovery

If qorvex becomes unresponsive or the app crashes mid-exploration:

1. Run `qorvex status` to check session health.
2. **Save the action log before restarting** — `qorvex -f json log` may still work even if the session is unhealthy. Save it so you don't lose script generation data.
3. If the session is dead, restart: `qorvex start` (or `qorvex start -d <UDID>` for physical).
4. Re-set the target: `qorvex set-target <BUNDLE_ID>` and `qorvex start-target`.
5. Resume exploration from the last known screen — use your existing screen map to navigate back to where you left off.
6. Do not re-explore already-mapped screens.

## WebView-Only Apps

Apps built entirely with WebViews (React Native WebView, Cordova, etc.) have limited accessibility tree data.

1. `screen-info` may return few or no labeled elements. Rely on screenshots for visual identification.
2. Use `tap-location` with coordinates derived from the screenshot to interact with web content.
3. Record screens by visual appearance rather than element labels.
4. Note in the output that the app uses WebViews and element data is limited.
