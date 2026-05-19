# Git Hooks

This directory contains git hooks for the swe-team repo. The `pre-commit` hook runs `scripts/skills-validate --changed` whenever staged files include anything under `skills/`. If validation fails, the commit is blocked. To activate, run once from the repo root:

```bash
git config core.hooksPath hooks
```

To bypass the hook for a single commit: `git commit --no-verify`.
