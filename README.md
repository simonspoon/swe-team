<p align="center">
  <img src="icon.png" width="128" height="128" alt="swe-team">
</p>

# swe-team

A Claude Code plugin that provides agents, skills, and commands for autonomous software engineering workflows.

## Installation

### As a Plugin (recommended)

Add the marketplace and install:

```bash
# Add the marketplace
claude plugin marketplace add simonspoon/swe-team

# Install the plugin
claude plugin install swe-team
```

Skills are namespaced: `/swe-team:engineering-standards`, `/swe-team:code-review`, etc.

### From Local Marketplace (for development)

```bash
# Register local marketplace (point to your local clone)
claude plugin marketplace add /path/to/local/marketplace

# Install
claude plugin install swe-team@local

# After editing skills, sync the cache
claude plugin update swe-team@local
```

---

## Agents

The Specialist Guild is a 9-agent autonomous team. Each agent is a lean shell — a soul block plus a mandate — that loads skills on demand. MAESTRO is the front door and pure router; every other agent is a specialist dispatched into a single lifecycle stage.

| Agent | Description |
|-------|-------------|
| **maestro** | Front door and pure router. Intakes the request, sizes the task, drives the 8-stage lifecycle one stage at a time, validates each gate, rolls back when a gate fails, and dispatches COMMITTER at the end. Authors zero technical content; the only agent with the Agent tool. |
| **scout** | Owns captured → refined. Investigates the codebase to ground the task, writes at least one testable acceptance criterion, proposes a sizing (trivial or full), and flags ambiguity or high blast radius for the risk-weighted gate. |
| **planner** | Owns refined → planned. Owns the `approach` field and the test-strategy — both concrete, with real, runnable test commands. Also raises ambiguity and high-blast-radius flags. |
| **risk** | Owns refined → planned alongside PLANNER. Writes the `risks` field ONLY. Never rewrites the `approach` — if the approach itself is flawed, that is recorded as a risk. |
| **adversary** | Attacks the plan (pre-build pass, planned → ready) and then attacks the real `git diff` (pre-ship pass, in-review). Produces one verdict from KILL, DEMOTE, REVISE, PASS that gates or rolls back the task. |
| **engineer** | Owns ready → in-progress → in-review. Implements the change, writes its tests, runs a self-verify against the test-strategy, and writes a `report` note. The ONLY agent with Write and Edit; never commits. |
| **reviewer** | Runs at in-review. Reviews the diff for correctness, convention adherence, and scope discipline. Verdict: APPROVE, REQUEST_CHANGES, or COMMENT. |
| **verifier** | Runs at in-review. Runs the built artifact through a platform-matched QA skill selected by the verification router. Verdict: PASS, FAIL, or SKIPPED. |
| **committer** | Owns commit. Stages the change, writes the commit message, commits, verifies the commit landed, and records the SHA in a limbo note. Runs on haiku — a deterministic mechanical step. |

## Skills

Skills are specialized capabilities invoked with `/swe-team:skill-name`. They are the single source of truth — agents load them on demand. The Guild ships 15 skills.

| Skill | Command | Description |
|-------|---------|-------------|
| **adversarial-review** | `/swe-team:adversarial-review` | Attack a plan (pre-build) or a git diff (pre-ship); produce a KILL/DEMOTE/REVISE/PASS verdict. |
| **code-review** | `/swe-team:code-review` | Review a diff for correctness, convention adherence, and scope discipline. |
| **codebase-research** | `/swe-team:codebase-research` | Investigate an unfamiliar codebase to ground a task before design decisions. |
| **commit** | `/swe-team:commit` | Stage, message, commit, and verify a change with mandatory checks. |
| **desktop-verify** | `/swe-team:desktop-verify` | QA a macOS desktop artifact via the loki CLI. |
| **docs** | `/swe-team:docs` | Author or update project documentation to reflect code changes. |
| **engineering-standards** | `/swe-team:engineering-standards` | Engineering conventions for implementation and planning; static conventions KB, reads project CLAUDE.md at load time. |
| **ios-verify** | `/swe-team:ios-verify` | QA an iOS artifact on simulator or device. |
| **lifecycle** | `/swe-team:lifecycle` | The 8-stage task machine, gate criteria, rollback rules, risk-weighted gate, fast-path rubric, and fan-out logic. |
| **project-orientation** | `/swe-team:project-orientation` | Read project conventions, layout, and entry points via progressive-disclosure docs. |
| **risk-analysis** | `/swe-team:risk-analysis` | Enumerate and weight the risks of a planned change before code is written. |
| **test-authoring** | `/swe-team:test-authoring` | Write the tests that satisfy the strategy, run suites, analyze coverage, report results. |
| **test-strategy** | `/swe-team:test-strategy` | Detect the test framework and plan the test cases with real, runnable commands before any test is written. |
| **verification** | `/swe-team:verification` | Router — auto-detect the project type and route to the platform-matched QA skill. |
| **web-verify** | `/swe-team:web-verify` | QA a web artifact via the khora CLI and Chrome DevTools Protocol. |

## Commands

| Command | Description |
|---------|-------------|
| **git-commit** | `/swe-team:git-commit` — Stages and commits changes with a clear, concise commit message. |

---

## Tool Setup

Several skills depend on external CLI tools. Install them so the skills work out of the box.

All tools are available via Homebrew:

```bash
brew tap simonspoon/tap
brew install limbo qorvex loki khora
```

Or download pre-built binaries from each tool's GitHub Releases page.

### [limbo](https://github.com/simonspoon/limbo) — Task Manager for Agents

Hierarchical task manager designed for LLMs and AI agents. Stores tasks in a single JSON file (`.limbo/tasks.json`), outputs JSON for easy parsing, and supports progressive decomposition workflows. Used by the **maestro** agent to drive the 8-stage lifecycle and by the external orchestrator for sequencing execution.

### [qorvex](https://github.com/simonspoon/qorvex) — iOS Automation Toolkit

Native iOS Simulator and physical device automation via a Swift XCTest agent. Supports tap, swipe, type, screenshot, accessibility tree inspection, long-press, and JSONL log-to-script conversion. Connects to simulators over localhost and to physical devices over WiFi/USB via mDNS. Used by the **ios-verify** skill.

### [loki](https://github.com/simonspoon/loki) — Desktop QA Automation

macOS desktop app automation via the Accessibility API. Launch apps, inspect accessibility trees, find elements, click, type, drag, and take screenshots — all from the command line. Built for CI/CD pipelines and agent workflows. Used by the **desktop-verify** skill.

### [khora](https://github.com/simonspoon/khora) — Web QA Automation

Cross-platform web app automation via Chrome DevTools Protocol. Launch headless or headed Chrome sessions, navigate pages, find elements by CSS selector, click, type, screenshot, and evaluate JavaScript. Used by the **web-verify** skill.

---

## Documentation

The [`docs/`](docs/index.html) folder contains self-contained HTML flowcharts of the agents, skills, and workflows — open `docs/index.html` in any browser (no build step or server required). It links to an agents/skills reference map and diagrams for the task lifecycle and verification pipeline.

## CLAUDE.md

The included `CLAUDE.md` configures Claude Code with mandatory pre-task steps and routing to the maestro agent for all code-producing tasks. The limbodrain skill (or an external orchestrator) watches limbo for unblocked leaf tasks and spawns sessions to handle them.

## Git Hooks

A pre-commit hook validates skill files before they reach the index. See [`hooks/README.md`](hooks/README.md) for setup.
