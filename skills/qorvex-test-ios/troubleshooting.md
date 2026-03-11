# Troubleshooting qorvex iOS Testing

## Physical Device Issues

### "Unlock X to Continue"
**Cause**: Device is locked during deployment or test execution.
**Fix**: Unlock the device and retry. Keep the device unlocked during the entire test session.

### "Timed out while enabling automation mode"
**Cause**: UI Automation is disabled on the device.
**Fix**: On the device, go to **Settings > Developer > Enable UI Automation** and toggle it on. Restart the qorvex session.

### Code signing errors
**Cause**: Physical devices require explicit code signing (simulators don't).
**Fix**: Build with these flags:
```bash
CODE_SIGNING_ALLOWED=YES \
CODE_SIGN_IDENTITY="Apple Development" \
DEVELOPMENT_TEAM=<YOUR_TEAM_ID> \
CODE_SIGN_STYLE=Automatic \
-allowProvisioningUpdates
```

### LaunchServicesDataMismatch
**Symptom**: `start-agent` fails with "LaunchServices GUID and sequence number do not match expected values".
**Cause**: iOS launch services cache is stale after a recent deploy.
**Fix**: Retry `qorvex start-agent` — the second attempt almost always succeeds. If it persists, uninstall the test runner app from the device and retry.

### Agent startup timeout on physical device
**Symptom**: `start-agent` fails with "Agent failed to become ready within timeout".
**Cause**: Multiple possible causes:
1. Device is **locked** — xcodebuild waits indefinitely for unlock, but qorvex times out at 30s
2. First deploy after a build takes longer than expected
3. WiFi latency or connectivity issues

**Fix**:
1. Ensure device is **unlocked and stays unlocked**
2. Retry `qorvex start-agent` — if the agent is already running from a previous attempt, it will detect and reuse it
3. If retries fail, start the agent manually and then run `qorvex start-agent` to connect:
   ```bash
   cd <agent-project-dir>
   TEST_RUNNER_QORVEX_PORT=8080 xcodebuild test-without-building \
     -project QorvexAgent.xcodeproj -scheme QorvexAgentUITests \
     -destination "id=<UDID>" -derivedDataPath .build \
     -only-testing QorvexAgentUITests/QorvexAgentTests/testRunAgent &
   # Wait for "Server listening on port 8080" in output, then:
   qorvex start-agent
   ```

### Agent not reachable on physical device
**Cause**: WiFi connectivity or hostname resolution failure.
**Checks**:
1. Device and Mac on same WiFi network?
2. Can you resolve the hostname? `dns-sd -G v4 <DeviceName>.local`
3. Is the agent port open? `nc -z <DeviceName>.local <port>`

**Important**: Use `<DeviceName>.local` (Bonjour mDNS), NOT `<DeviceName>.coredevice.local`. The `.coredevice.local` hostnames are internal to Apple's CoreDevice framework and don't resolve via standard DNS.

### screen-info hangs on physical device
**Cause**: Querying the home screen (SpringBoard) accessibility tree, which has thousands of elements.
**Fix**: Always launch your target app BEFORE calling `screen-info`. If stuck, Ctrl+C and launch the app first:
```bash
xcrun devicectl device process launch --device <UDID> <BUNDLE_ID>
qorvex screen-info  # Now queries only the app's element tree
```

## Simulator Issues

### Stale session
**Symptom**: Commands return errors or no response.
**Fix**: `qorvex status` to check, then `qorvex start` to restart the session.

### Wrong architecture
**Symptom**: App crashes on launch or fails to install.
**Fix**:
- Apple Silicon Mac: build for `iossimulator-arm64`
- Intel Mac: build for `iossimulator-x64`

### Simulator not detected
**Symptom**: `qorvex start` fails to find a device.
**Fix**: Boot a simulator first: `xcrun simctl boot <udid>` or open Simulator.app.

## Common Command Issues

### Keyboard covers elements — tap fails with "not found"
**Symptom**: After typing into a text field, subsequent taps on elements (especially tab bar buttons) fail with "not found".
**Cause**: The on-screen keyboard covers the bottom portion of the screen. Elements behind the keyboard are not hittable and won't be found by `tap` or `wait-for`.
**Fix**:
1. Dismiss the keyboard first: `qorvex swipe down`
2. Then retry the tap
3. Alternative: tap a non-interactive area above the keyboard to dismiss it, then retry

### Switch/Toggle tap reports success but doesn't change value
**Symptom**: `qorvex tap <switch-id>` returns success, but `get-value` shows the switch didn't toggle.
**Cause**: iOS Switch elements have accessibility frames spanning the full row width (e.g., 408px wide). The tap center hits the label text area, not the actual switch control on the right side.
**Fix**: Use coordinate tap targeting the switch control:
```bash
# From screen-info, get the switch frame (e.g., x:16, y:290, width:408, height:28)
# Tap the right side: x + width - 30, y + height/2
qorvex tap-location 394 304
```

### Tap fails with "not found"
**Cause**: Using accessibility ID when the element only has a label (or vice versa).
**Fix**: Use `-l` flag for label matching. Run `screen-info` first to see what identifiers exist.

### Multiple elements match
**Cause**: Several elements share the same label.
**Fix**: Add `-T <Type>` to filter by element type (e.g., `-T Button`, `-T StaticText`).

### Screenshot appears blank or corrupted
**Cause**: Missing `base64 -d` decode step.
**Fix**: Always pipe: `qorvex screenshot 2>/dev/null | base64 -d > /tmp/screenshot.png`

Back to [SKILL.md](SKILL.md)
