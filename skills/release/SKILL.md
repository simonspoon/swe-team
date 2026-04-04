---
name: release
description: >
  Release engineering expert. ALWAYS invoke this skill when cutting a release, bumping
  versions, or tagging. Do NOT run version bumps or git tag commands directly — use this
  skill. Triggers: release, cut a release, bump version, tag and push, publish to Homebrew.
---

# Release

Cut a versioned release for a project with CI-driven binary builds and Homebrew distribution.

## When to Use

- User says "release", "cut a release", "bump version", "tag and push"
- A tool is ready for a new version

## Prerequisites

- `gh` CLI authenticated
- Project has `.github/workflows/release.yml` triggered by `v*` tags
- Project has a Homebrew formula in a tap repo (detect from `.github/workflows/release.yml` or ask the user)

If this is the **first release** of a new project, some prerequisites may not be met yet. See "First Release" section below.

## Activation Protocol

### Step 0: Detect first release

Check if any releases exist:
```bash
gh release list --limit 1
```

If no releases exist AND no Homebrew formula exists for this project, follow the **First Release** path:
1. Verify `.github/workflows/release.yml` exists. If not, create one from the project's CI pattern.
2. Note that the Homebrew formula will need to be created AFTER the release produces binaries (can't compute SHA256 checksums without artifacts).
3. Warn: "The `HOMEBREW_TAP_TOKEN` secret must be set on this repo for automatic tap updates. If not configured, the tap update will fail and you'll need to update it manually."
4. Proceed with Steps 1-7 as normal, then handle formula creation in Step 8.

### Step 1: Determine Version

Ask if not provided. Use semver: patch for fixes, minor for features, major for breaking changes.

### Step 2: Detect Project Type and Find Version Files

Detect the project language, then find version files:

| Indicator | Project type | Version files | Lock file to stage |
|---|---|---|---|
| `Cargo.toml` | Rust | `Cargo.toml` (root only if workspace) | `Cargo.lock` |
| `Cargo.toml` + `tauri.conf.json` | Tauri | `Cargo.toml` + `tauri.conf.json` + `package.json` | `Cargo.lock` |
| `go.mod` | Go | None (version injected via ldflags at build time) | — |

**Rust:** Check for workspace: `grep -rn 'version.workspace = true' **/Cargo.toml 2>/dev/null`. If members inherit, only bump root `[workspace.package] version`.

**Go:** Check release workflow for `-ldflags` with `-X ...Version=`. If present, no files to bump — the tag IS the version. Skip Step 3.

### Step 3: Bump Versions

Update ALL version files found in Step 2. Verify each change with a diff.

- **Rust:** Run `cargo check` after bumping to regenerate `Cargo.lock`, then stage both files.
- **Go:** Skip this step (version comes from the git tag via ldflags).

### Step 4: Run Checks

Run language-appropriate checks. If any fail, fix before proceeding.

| Project type | Commands |
|---|---|
| Rust | `cargo fmt --check && cargo clippy --workspace --all-targets -- -D warnings && cargo test --workspace` |
| Go | `go fmt ./... && go vet ./... && go test ./...` |

**Go note:** If `golangci-lint` is available, also run `golangci-lint run`. If it panics due to toolchain mismatch (not your code), proceed — CI will use the correct toolchain.

### Step 5: Commit and Tag

Use `/swe-team:git-commit` for the commit. Message format: `bump version to X.Y.Z for release`

Then tag:
```bash
git tag vX.Y.Z
```

### Step 6: Push

```bash
git push && git push --tags
```

This triggers the release workflow.

### Step 7: Verify Release

1. Wait for CI to complete:
   ```bash
   gh run list --limit 3
   ```
2. Check all jobs passed:
   ```bash
   gh run view <RUN_ID> --json jobs -q '.jobs[] | "\(.name): \(.conclusion)"'
   ```
3. Verify release assets exist:
   ```bash
   gh release view vX.Y.Z --json assets -q '.assets[].name'
   ```

### Step 8: Verify Homebrew Tap

The release workflow typically dispatches an auto-update to a Homebrew tap repo. Detect the tap repo from `.github/workflows/release.yml` (look for `repository_dispatch` or `workflow_dispatch` targeting a `homebrew-tap` repo). If not found, ask the user.

Verify the tap update succeeded:

```bash
# Replace <TAP_REPO> with the detected owner/homebrew-tap repo
gh run list --repo <TAP_REPO> --limit 3
```

If the tap update failed (common on first release — secret may not be configured), update manually:
```bash
# Find the local tap repo path
brew --repository <tap-owner>/<tap-name>
# Or ask the user for the local tap repo path

cd <LOCAL_TAP_REPO>
```

**If a formula already exists:**
```bash
bash scripts/update-formula.sh <FORMULA_NAME> <VERSION_WITHOUT_V> <OWNER/REPO>
# IMPORTANT: VERSION must NOT have the v prefix (use 0.2.0, not v0.2.0)
```

**If this is the first release (no formula exists):**
Create a new formula file at `Formula/<TOOL_NAME>.rb` using an existing formula as a template. Then run `update-formula.sh` to fill in the correct SHA256 checksums.

```bash
git add -A && git commit -m "add/update <FORMULA_NAME> to <VERSION>" && git push
```

## Gotchas

- **Formula name may differ from tool name.** wisp uses `wisp-cli` as the formula name. Check the tap repo's `Formula/` directory for the actual filename.
- **Workspace versions.** If `Cargo.toml` uses `[workspace.package] version = "X"`, member crates may use `version.workspace = true`. Only bump the workspace root.
- **Tag format.** Always `vX.Y.Z` with the `v` prefix. Release workflows trigger on `v*` tags.
- **Don't skip tests.** A failed release wastes CI minutes and creates a broken tag. Always run tests locally first.
