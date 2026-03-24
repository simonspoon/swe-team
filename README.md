# swe-team

A Claude Code plugin that provides agents, skills, and commands for autonomous software engineering workflows.

## Installation

### As a Plugin (recommended)

Add the marketplace and install:

```bash
# Add the marketplace (replace with the marketplace URL or path)
claude plugin marketplace add <marketplace-source>

# Install the plugin
claude plugin install swe-team
```

Skills are namespaced: `/swe-team:software-engineering`, `/swe-team:code-reviewer`, etc.

### From Local Marketplace (for development)

```bash
# Register local marketplace
claude plugin marketplace add /path/to/claudehub/marketplace

# Install
claude plugin install swe-team@claudehub

# After editing skills, sync the cache
claude plugin update swe-team@claudehub
```

---

## Agents

Agents are autonomous subprocesses that handle complex, multi-step tasks. They are launched automatically when Claude Code detects a matching request.

| Agent | Description |
|-------|-------------|
| **project-manager** | Orchestrates multi-file projects using hierarchical task management and parallel subagent execution. Automatically invoked when a task spans 3+ files or multiple concerns. |
| **code-review-agent** | Performs thorough, convention-aware code reviews combining security analysis, bug detection, performance checks, and style enforcement. |
| **researcher-agent** | Conducts deep research across codebases, documentation, and the web. Produces structured, actionable reports. |
| **skill-trainer** | Tests, validates, and hardens skills through structured multi-phase training and weak-model (Haiku) calibration. |

## Skills

Skills are specialized capabilities invoked with `/swe-team:skill-name`. They provide domain knowledge and structured workflows.

### Core Workflow

| Skill | Command | Description |
|-------|---------|-------------|
| **software-engineering** | `/swe-team:software-engineering` | Self-evolving knowledge base for architecture, debugging, design patterns, testing, performance, and security. |
| **code-reviewer** | `/swe-team:code-reviewer` | Reviews diffs, PRs, and files for quality, bugs, security issues, and project conventions. |
| **test-engineer** | `/swe-team:test-engineer` | Generates tests, runs suites, analyzes coverage, and reports results across languages. |
| **simplify** | `/swe-team:simplify` | Analyzes code for unnecessary complexity using 7 refactoring patterns and applies focused fixes. |
| **code-index** | `/swe-team:code-index` | Generates a structural index of a codebase showing files and their exported symbols. |

### Project & Session Management

| Skill | Command | Description |
|-------|---------|-------------|
| **project-manager** | `/swe-team:project-manager` | Orchestrates complex projects using limbo for task management and parallel subagent execution. |
| **session-handoff** | `/swe-team:session-handoff` | Preserves strategic context, decisions, and priorities in SESSION_STATE.md for the next session. |
| **project-docs-explore** | `/swe-team:project-docs-explore` | Discovers and reads a project's documentation structure for quick onboarding. |

### Verification & Testing

| Skill | Command | Description |
|-------|---------|-------------|
| **verification-orchestrator** | `/swe-team:verification-orchestrator` | Auto-detects project type (iOS/desktop/web) and routes to the appropriate QA tool. |
| **qorvex-test-ios** | `/swe-team:qorvex-test-ios` | Tests iOS apps in simulators or on physical devices using qorvex CLI. |
| **qorvex-app-explorer** | `/swe-team:qorvex-app-explorer` | Systematically explores and maps an iOS app's UI. |
| **loki-test-desktop** | `/swe-team:loki-test-desktop` | Tests desktop apps on macOS using loki CLI via the Accessibility API. |
| **khora-test-web** | `/swe-team:khora-test-web` | Tests web apps using khora CLI via Chrome DevTools Protocol. |

### Design

| Skill | Command | Description |
|-------|---------|-------------|
| **wisp-design** | `/swe-team:wisp-design` | Builds and iterates on visual UI layouts using the Wisp desktop canvas and CLI. |

### Documentation

| Skill | Command | Description |
|-------|---------|-------------|
| **update-docs** | `/swe-team:update-docs` | Detects recent code changes and makes targeted updates to affected documentation. |
| **setup-docs** | `/swe-team:setup-docs` | Creates a progressive disclosure documentation system. |

### Skill & Agent Authoring

| Skill | Command | Description |
|-------|---------|-------------|
| **skill-creator** | `/swe-team:skill-creator` | Creates new skills with proper structure, YAML frontmatter, and best practices. |
| **skill-reflection** | `/swe-team:skill-reflection` | Analyzes session history to identify skill usage patterns and improvement opportunities. |
| **skill-trainer** | `/swe-team:skill-trainer` | Validates and hardens skills through automated testing and weak-model calibration. |
| **agent-composer** | `/swe-team:agent-composer` | Generates agent definition files from role descriptions, capabilities, and existing skills. |
| **team-evaluator** | `/swe-team:team-evaluator` | Benchmarks the SWE agent team's capabilities, scores results, and identifies gaps. |

### DevOps & Infrastructure

| Skill | Command | Description |
|-------|---------|-------------|
| **devops** | `/swe-team:devops` | Creates and manages CI/CD pipelines, Docker configs, deployment scripts, and infrastructure. |

### Utilities

| Skill | Command | Description |
|-------|---------|-------------|
| **cmux-control** | `/swe-team:cmux-control` | Controls terminals and browsers via cmux CLI. |
| **nyx** | `/swe-team:nyx` | Searches past Claude Code conversation history. |

## Commands

| Command | Description |
|---------|-------------|
| **git-commit** | `/swe-team:git-commit` — Stages and commits changes with a clear, concise commit message. |

---

## Tool Setup

Several skills depend on external CLI tools. Install them so the skills work out of the box.

All tools below (except cmux) are available via Homebrew:

```bash
brew tap simonspoon/tap
brew install limbo nyx qorvex loki khora wisp-cli suda
```

Or download pre-built binaries from each tool's GitHub Releases page.

### [limbo](https://github.com/simonspoon/limbo) — Task Manager for Agents

Hierarchical task manager designed for LLMs and AI agents. Stores tasks in a single JSON file (`.limbo/tasks.json`), outputs JSON for easy parsing, and supports progressive decomposition workflows. Used by the **project-manager** skill to orchestrate multi-file projects with parallel subagent execution.

### [nyx](https://github.com/simonspoon/nyx) — Conversation History Search

Indexes and searches Claude Code conversation history stored in `~/.claude/projects/`. Build a full-text index with `nyx index`, then search across all past sessions. Used by the **nyx** skill to recall prior decisions, find code patterns from earlier sessions, and answer "did we already..." questions.

### [qorvex](https://github.com/simonspoon/qorvex) — iOS Automation Toolkit

Native iOS Simulator and physical device automation via a Swift XCTest agent. Supports tap, swipe, type, screenshot, accessibility tree inspection, long-press, and JSONL log-to-script conversion. Connects to simulators over localhost and to physical devices over WiFi/USB via mDNS. Used by the **qorvex-test-ios** and **qorvex-app-explorer** skills.

### [loki](https://github.com/simonspoon/loki) — Desktop QA Automation

macOS desktop app automation via the Accessibility API. Launch apps, inspect accessibility trees, find elements, click, type, drag, and take screenshots — all from the command line. Built for CI/CD pipelines and agent workflows. Used by the **loki-test-desktop** skill.

### [khora](https://github.com/simonspoon/khora) — Web QA Automation

Cross-platform web app automation via Chrome DevTools Protocol. Launch headless or headed Chrome sessions, navigate pages, find elements by CSS selector, click, type, screenshot, and evaluate JavaScript. Used by the **khora-test-web** skill.

### [wisp](https://github.com/simonspoon/wisp) — Visual Design Canvas for Agents

A desktop design surface that agents control through a CLI over WebSocket. The Wisp desktop app renders a live canvas; the `wisp` CLI sends JSON-RPC commands to create, edit, and arrange design nodes. Both human and agent share the same real-time view. Available for macOS, Windows, and Linux. Used by the **wisp-design** skill.

### [suda](https://github.com/simonspoon/suda) — Structured Memory for Agents

SQLite-backed memory and knowledge management CLI. Stores typed memories (user, feedback, project, reference), manages session state, and maintains a project registry. Used by the session startup protocol and **session-handoff** skill to persist context across conversations.

### [cmux](https://cmux.dev) — Terminal & Browser Multiplexer

Third-party tool for spawning and controlling terminals, Claude Code sessions, and browser windows. Used by the **cmux-control** skill to run REPLs, TUIs, interactive shells, and browser-based testing from within agent workflows.

---

## CLAUDE.md

The included `CLAUDE.md` configures Claude Code with a session startup/handoff protocol, mandatory pre-task steps, and automatic routing to the appropriate agent based on task complexity.
