# Evolution Log

Tracks additions and changes to the knowledge base.

| Date | Action | File | Details |
|------|--------|------|---------|
| 2026-03-14 | created | (all) | Initial seed structure |
| 2026-03-14 | added | knowledge/architecture/rust-cli-patterns.md | Seeded from dante project session — blocking HTTP, untyped returns, module structure, error handling, crate stack |
| 2026-03-14 | modified | SKILL.md | Fixed activation protocol: skip empty preference files, clarified empty-state behavior, relaxed modification rule to allow /skill-reflection edits |
| 2026-03-15 | added | knowledge/tooling/rust-dependency-management.md | Current crate versions, semver guidance, upgrade workflow, breaking change patterns |
| 2026-03-15 | modified | knowledge/architecture/rust-cli-patterns.md | Updated crate stack table with versions, linked to dependency management file |
| 2026-03-15 | modified | SKILL.md | Added critical requirement: ask before upgrading deps. Added staleness tracking (Last researched date, 3-month threshold for tooling). Added tooling domain to activation protocol |
| 2026-03-15 | modified | knowledge/architecture/rust-cli-patterns.md | Added: feature-gated optional subsystems, transparent backend routing via constructors, mixing blocking reqwest with async axum |
| 2026-03-15 | modified | preferences/lessons.md | Added 2 lessons: prefer stdlib over heavyweight deps, mutex poison recovery in servers |
