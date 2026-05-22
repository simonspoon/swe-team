# Skills Index

Quick reference for all active skills — when to use each and how they compose.

| Skill | Purpose | When to invoke | Composes with |
|-------|---------|----------------|---------------|
| **tech-lead** | Single-task code executor — implements one task, verifies, returns (no commits) | Dispatched by PM to execute a single leaf task | engineering-standards (conventions), project-orientation (codebase context) |
| **project-orientation** | Orient via progressive-disclosure docs before coding | Starting work on unfamiliar subsystem or onboarding to project | tech-lead (Phase 0 research) |
| **ios-verify** | Automate and verify iOS app UI on simulator or physical device | Testing iOS apps, verifying UI behavior, taking screenshots | verification (router) |
| **setup-docs** | Create docs/ structure with INDEX.md for progressive disclosure | New project needs documentation scaffolding | project-orientation (consumer of its output) |
| **docs** | Update existing docs to reflect code changes | After code changes that affect documented behavior | project-orientation (reads what docs writes) |
| **skill-creator** | Create new skills with proper structure and frontmatter | User wants a new custom skill | skill-reflection (improve after creation) |
| **skill-reflection** | Analyze skill quality and implement improvements | After sessions where skills underperformed | All skills (meta-improvement) |
| **engineering-standards** | Self-evolving engineering conventions KB; reads project CLAUDE.md at load time | Architecture, debugging, code review, patterns, testing, performance, security | skill-reflection (meta-improvement) |
| **risk-analysis** | Enumerate and weight the risks of a planned change before code is written | Pre-implementation risk assessment, approach validation, security review of a plan | engineering-standards (conventions), code-review (shares the security checklist) |
| **codebase-research** | Investigate an unfamiliar codebase to ground a task before design decisions | Researching how something works, exploring unfamiliar code, deep-dive investigation | project-orientation (docs orientation), engineering-standards (knowledge capture) |
| **code-review** | Review code diffs, PRs, and files for quality, bugs, and security | Reviewing code, PRs, diffs, checking code quality, security review | engineering-standards (conventions), risk-analysis (shared security checklist), test-authoring (coverage check) |
| **test-strategy** | Detect the test framework and plan the test cases before any test is written | Designing a test strategy, deciding what to test, planning test cases | engineering-standards (conventions), test-authoring (implements the strategy) |
| **test-authoring** | Write tests, run suites, analyze coverage, report results | Writing tests, running tests, analyzing coverage, test quality audit | engineering-standards (conventions), test-strategy (consumes its strategy), code-review (coverage verification) |
| **devops** | CI/CD pipelines, Docker, deployment scripts, infrastructure | GitHub Actions, CI/CD, Docker, deployment, infrastructure, pipelines | test-authoring (CI test step), code-review (PR checks) |
| **agent-composer** | Generate agent .md definitions from role descriptions and skills | Creating a new agent, composing an agent from skills, generating agent definitions | skill-creator (skill structure), SKILLS-INDEX.md (skill discovery) |
| **team-evaluator** | Benchmark and score team capabilities, identify gaps | Evaluating team performance, running benchmarks, auditing capabilities, gap analysis | All skills (benchmarks exercise them), skill-reflection (improvement loop) |
| **simplify** | Analyze code for unnecessary complexity and apply focused refactorings | Simplifying code, refactoring, cleanup, reducing complexity, extracting modules, removing duplication | engineering-standards (conventions), test-authoring (verify tests), code-review (review result) |
| **code-index** | Generate structural index of codebase (files + exported symbols) | Indexing a project, generating code map, understanding project structure | project-orientation (complements docs with code structure) |
| **session-wrap** | End-of-session cleanup — commits dirty repos and optionally improves skills | End of session, wrapping up, user says goodbye, significant milestone | engineering-standards (lessons), skill-reflection (skill issues) |
| **nyx** | Search past Claude Code conversation history | Recalling prior decisions, finding past discussions, "did we already…" questions, locating context from previous sessions | engineering-standards (find past architecture decisions) |
| **desktop-verify** | Automate and verify macOS desktop application UI via the loki CLI | Testing desktop apps, verifying UI behavior, macOS app testing, accessibility testing, taking screenshots, clicking buttons, inspecting UI trees | verification (router), ios-verify (sibling pattern) |
| **web-verify** | Automate and verify web application UI via the khora CLI and Chrome DevTools Protocol | Testing web apps, browser testing, Chrome automation, verifying web pages, clicking buttons, taking screenshots, checking page content | verification (router), desktop-verify (sibling pattern) |
| **xaku-control** | Control terminals via the xaku headless terminal multiplexer | Spawning interactive terminals, starting Claude Code sessions, running REPLs/TUIs, reading terminal output, sending commands | tech-lead (interactive tasks), web-verify (browser complement) |
| **qorvex-app-explorer** | Systematically explore and map an iOS app's UI via qorvex | Mapping app screens, exploring app functionality, discovering UI flows, building screen maps, generating automation scripts | ios-verify (uses same tool), project-orientation (produces documentation) |
| **skill-trainer** | Validate and harden skills through automated testing and weak-model calibration | Training skills, testing skills, validating skill instructions, calibrating for weaker models, stress-testing before deployment | skill-reflection (improvement loop), all skills (target of training) |
| **verification** | Auto-detects project type (iOS, desktop, web) and routes to the appropriate QA skill (ios-verify, desktop-verify, web-verify) | verify, test, QA, auto-detect platform, check your work | ios-verify, desktop-verify, web-verify, tech-lead |
| **wisp-design** | Design and build visual UI layouts using the Wisp desktop canvas and CLI | Designing UI, building layouts, creating mockups, visual design, placing components, arranging elements, iterating on designs | tech-lead (design tasks), desktop-verify (verify desktop app showing design) |
| **commit** | Stage, message, commit, and verify a change with mandatory checks | Committing changes, saving progress, staging and committing | devops (CI pipeline), release (version bump commit) |
| **release** | Cut a versioned release with CI builds and Homebrew distribution | Releasing a tool, cutting a release, bumping version, tagging, publishing to Homebrew | devops (CI pipeline), commit (version bump commit) |
| **global-backlog** | Cross-project task management via `limbo -g` | Global backlog, cross-project tasks, "add to backlog", "what's on the backlog", triage work across projects | tech-lead (can pick up backlog items) |
| **status** | Force-refresh all project state — live git, simaris, limbo data | "status", "where are we", "catch me up", start of session, verifying state | global-backlog (reads backlog) |
| **dream** | Offline knowledge-store hygiene — runs simaris lint/cluster/decay/vacuum, consolidates near-duplicates, synthesizes recommendations | Manually via `/dream`, on schedule, when simaris search/prime output is noisy | simaris (operates on knowledge units), skill-reflection (acts on improvement recommendations) |

## Composition Patterns

### Multi-file feature work
1. PM decomposes feature into leaf tasks in limbo
2. Orchestrator picks up each leaf → PM dispatches tech-lead per task
3. PM verifies and commits each completed task
4. `/swe-team:ios-verify` or `/swe-team:desktop-verify` or `/swe-team:web-verify` → platform-specific verification

### Bug fix
1. PM receives bug task, dispatches tech-lead to investigate and fix
2. PM verifies fix, commits
3. Platform QA skill (qorvex/loki/khora) → verify fix on device/desktop/browser

### New project setup
1. `/swe-team:setup-docs` → create docs/ structure
2. PM decomposes implementation into tasks → orchestrator handles execution
3. `/swe-team:docs` → keep docs current as code evolves

### Code review workflow
1. `/swe-team:engineering-standards` → load project conventions
2. `/swe-team:code-review` → review diff/PR against security, bugs, style, conventions
3. `/swe-team:test-authoring` → verify test coverage for changed code

### CI/CD setup
1. `/swe-team:devops` → create GitHub Actions workflow, Docker config
2. `/swe-team:test-strategy` → ensure the planned test commands match the CI pipeline
3. `/swe-team:code-review` → review the pipeline config itself

### Test-driven development
1. `/swe-team:engineering-standards` → load project conventions
2. `/swe-team:test-strategy` → plan the test cases for the new feature
3. `/swe-team:test-authoring` → generate the tests
4. `/swe-team:code-review` → review implementation against tests

### SWE Full Cycle (issue → merge)
1. PM analyzes issue, decomposes into leaf tasks in limbo
2. Orchestrator picks each leaf → PM dispatches tech-lead per task
3. PM verifies each task (includes test-authoring, code-review as needed)
4. PM commits after verification
5. `/swe-team:devops` → update CI pipeline if needed
6. Deliver: create PR

The orchestrator drives the outer loop. Each PM session handles one task end-to-end.

### New agent creation
1. `/swe-team:agent-composer` → generate agent definition from requirements
2. `/swe-team:skill-creator` → create any new skills the agent needs
3. `/swe-team:team-evaluator` → benchmark the new agent's capabilities

### Simplify/Refactor workflow
1. `/swe-team:engineering-standards` → load project conventions
2. `/swe-team:simplify` → analyze code, identify opportunities, present findings
3. User approves specific refactorings
4. `/swe-team:simplify` → apply refactorings one at a time, verify tests after each
5. `/swe-team:test-authoring` → run full test suite, confirm no regressions
6. `/swe-team:code-review` → review the refactored code for quality

### Recall prior context
1. `/swe-team:nyx` → search conversation history for past decisions, discussions, or patterns
2. Combine findings to inform current task

### End of session
1. `/swe-team:session-wrap` → commits dirty repos, opportunistically captures learnings into simaris, improves skills if requested

### UI design workflow
1. `/swe-team:wisp-design` → build the visual layout on the Wisp canvas using CLI commands
2. `/swe-team:wisp-design` → screenshot and inspect, iterate on positioning and styling
3. `/swe-team:wisp-design` → save the final design to a JSON file
4. `/swe-team:tech-lead` → if the design informs code generation, orchestrate implementation from the saved design

### Release a tool
1. `/swe-team:release` → bump version, commit, tag, push, verify CI + Homebrew tap update
2. `/swe-team:devops` → if release workflow needs changes

### Memory maintenance
1. `/swe-team:dream` → inventory, consolidate duplicates, prune stale entries, synthesize recommendations
2. `/swe-team:skill-reflection` → act on skill improvement recommendations from dream report

### Team improvement cycle
1. `/swe-team:team-evaluator` → run benchmarks, identify gaps
2. `/swe-team:skill-reflection` → improve weak skills based on evaluation findings
3. `/swe-team:team-evaluator` → re-run benchmarks to verify improvement
