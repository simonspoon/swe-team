# docs/INDEX.md Template

Copy this into your project's `docs/INDEX.md` and fill in the rows.

```markdown
# Project Documentation Index

| Topic | File | When to read |
|-------|------|--------------|
| Architecture overview | [architecture.md](dev/architecture.md) | Starting work on any subsystem |
| API conventions | [api.md](dev/api.md) | Adding or modifying API endpoints |
| Testing strategy | [testing.md](dev/testing.md) | Writing or modifying tests |
| Deployment | [deployment.md](dev/deployment.md) | Changing CI/CD or release process |
| Getting started | [getting-started.md](user/getting-started.md) | Onboarding new developers |
```

## Column Guide

- **Topic**: Short name for the area (1-3 words)
- **File**: Relative path from `docs/` — use `dev/` for developer docs, `user/` for end-user docs
- **When to read**: Describe the task or situation that makes this doc relevant. Be specific — "Adding API endpoints" is better than "API work"
