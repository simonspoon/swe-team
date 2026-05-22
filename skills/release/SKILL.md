---
name: release
description: >
  Release engineering expert. ALWAYS invoke this skill when cutting a release, bumping
  versions, or tagging. Do NOT run version bumps or git tag commands directly — use this
  skill. Triggers: release, cut a release, bump version, tag and push, publish to Homebrew.
---

# Release

Cut a versioned release for a project with CI-driven binary builds and Homebrew distribution.

## CRITICAL — never skip pre-flight

A release tag is permanent and triggers binary builds across multiple platforms. A release cut from the wrong branch or a dirty tree ships the wrong code and cannot be quietly undone.

- **Run Step 0 (Pre-flight) first, every time.** Do not detect versions, bump, commit, or tag until it passes.
- **Release only from the repo's default branch** (`main`/`master`). On any other branch → **STOP and ask the user.**
- **Release only from a clean working tree.** Uncommitted changes present → **STOP and ask the user.**
- Never resolve a wrong-branch or dirty-tree situation on your own judgement. The user decides.

## When to Use

- User says "release", "cut a release", "bump version", "tag and push"
- A tool is ready for a new version

## Prerequisites

- `gh` CLI authenticated
- Project has `.github/workflows/release.yml` triggered by `v*` tags
- Project has a Homebrew formula in a tap repo (detect from `.github/workflows/release.yml` or ask the user)

If this is the **first release** of a new project, some prerequisites may not be met yet. See Step 1.

## Activation Protocol

### Step 0: Pre-flight checks (MANDATORY — before anything else)

These take seconds and prevent a permanent, broken release. Run all three **before** version detection. If any check fails, STOP at that check — do not continue until it is resolved by the user.

**0.1 — On the default branch?**
```bash
gh repo view --json defaultBranchRef -q .defaultBranchRef.name   # e.g. main
git branch --show-current                                        # current branch
```
- They match → pass.
- Current branch is empty (detached HEAD) **or** differs from the default branch → **STOP.** Ask the user:
  > "You're on `<current>`, not the default branch `<default>`. Tagging here releases `<current>`'s HEAD, not `<default>`. Do you want to (a) switch to `<default>` and release from there, or (b) deliberately release from `<current>`?"

  Proceed only after the user explicitly picks a path. Never tag a non-default branch on your own judgement — surfacing it *after* tagging is too late.

**0.2 — Working tree clean?**
```bash
git status --porcelain
```
- Empty output → pass.
- Any uncommitted or untracked changes → **STOP.** Show the user the dirty files and ask:
  > "The working tree has uncommitted changes: <list>. Should these (a) be part of this release — commit them first via /swe-team:git-commit, (b) be committed separately or excluded, or (c) be stashed?"

  Do NOT bump the version until the tree is clean or the user has explicitly decided. Never sweep unrelated changes into the version-bump commit. (A harness-managed local file such as `.claude/settings.json` may be left untracked — mention it and continue.)

**0.3 — In sync with origin, and not in a stray worktree?**
```bash
git fetch origin
git status -sb                  # header shows "ahead"/"behind"
git rev-parse --git-common-dir  # not ".git" → you are in a linked worktree
```
- Branch is **behind** origin → **STOP**, ask the user to pull first (otherwise you tag stale code).
- You are in a **linked worktree** → confirm with the user that this worktree is the intended place to cut the release. It must still be on the default branch per 0.1; a worktree created for unrelated feature work is not a release location.

### Step 1: Detect first release

Check if any releases exist:
```bash
gh release list --limit 1
```

If no releases exist AND no Homebrew formula exists for this project, follow the **First Release** path:
1. Verify `.github/workflows/release.yml` exists. If not, create one from the project's CI pattern.
2. Note that the Homebrew formula will need to be created AFTER the release produces binaries (can't compute SHA256 checksums without artifacts).
3. Warn: "The `HOMEBREW_TAP_TOKEN` secret must be set on this repo for automatic tap updates. If not configured, the tap update will fail and you'll need to update it manually."
4. Proceed with Steps 2-8 as normal, then handle formula creation in Step 9.

### Step 2: Determine Version

Ask if not provided. Use semver: patch for fixes, minor for features, major for breaking changes.

### Step 3: Detect Project Type and Find Version Files

Detect the project language, then find version files:

| Indicator | Project type | Version files | Lock file to stage |
|---|---|---|---|
| `Cargo.toml` | Rust | `Cargo.toml` (root only if workspace) | `Cargo.lock` |
| `Cargo.toml` + `tauri.conf.json` | Tauri | `Cargo.toml` + `tauri.conf.json` + `package.json` | `Cargo.lock` |
| `go.mod` | Go | None (version injected via ldflags at build time) | — |

**Rust:** Check for workspace: `grep -rn 'version.workspace = true' **/Cargo.toml 2>/dev/null`. If members inherit, only bump root `[workspace.package] version`.

**Go:** Check release workflow for `-ldflags` with `-X ...Version=`. If present, no files to bump — the tag IS the version. Skip Step 4.

### Step 4: Bump Versions

Update ALL version files found in Step 3. Verify each change with a diff.

- **Rust:** Run `cargo check` after bumping to regenerate `Cargo.lock`, then stage both files.
- **Go:** Skip this step (version comes from the git tag via ldflags).

### Step 5: Run Checks

Run language-appropriate checks. If any fail, fix before proceeding.

| Project type | Commands |
|---|---|
| Rust | `cargo fmt --check && cargo clippy --workspace --all-targets -- -D warnings && cargo test --workspace` |
| Go | `go fmt ./... && go vet ./... && golangci-lint run && go test ./...` |

**Go note:** If `golangci-lint` panics due to toolchain mismatch (not your code), proceed — CI will use the correct toolchain. But if it reports actual lint issues, fix them before tagging.

### Step 6: Commit and Tag

Re-confirm pre-flight still holds — you are on the default branch (0.1) with no unexpected uncommitted changes beyond the version bump (0.2). Then:

Use `/swe-team:git-commit` for the commit. Message format: `bump version to X.Y.Z for release`

Then tag:
```bash
git tag vX.Y.Z
```

### Step 7: Push

```bash
git push && git push --tags
```

This triggers the release workflow.

### Step 8: Verify Release

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

### Step 9: Verify Homebrew Tap

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

- **Wrong branch / dirty tree.** The most common way a release goes bad is cutting it from a feature branch or with uncommitted changes. Step 0 catches both — never skip it, and never "note it and continue." STOP and let the user decide.
- **Docs drift in batch releases.** When cutting multiple releases in one session, the per-commit docs freshness gate (in the commit skill) fires once and can be dismissed, letting README/docs drift accumulate silently. After finishing a batch of releases, explicitly check: "Have docs been updated to reflect all the changes across these releases?" If not, run `/swe-team:docs` before ending the session.
- **Formula name may differ from tool name.** wisp uses `wisp-cli` as the formula name. Check the tap repo's `Formula/` directory for the actual filename.
- **Workspace versions.** If `Cargo.toml` uses `[workspace.package] version = "X"`, member crates may use `version.workspace = true`. Only bump the workspace root.
- **Tag format.** Always `vX.Y.Z` with the `v` prefix. Release workflows trigger on `v*` tags.
- **Don't skip tests.** A failed release wastes CI minutes and creates a broken tag. Always run tests locally first.
