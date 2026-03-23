# claude-setup

A curated collection of agents, skills, and commands for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) that turn it into a capable SWE agent team.

## Installation

Copy or symlink the contents into your Claude Code configuration directory (`~/.claude/`):

```
agents/   → ~/.claude/agents/
skills/   → ~/.claude/skills/
commands/ → ~/.claude/commands/
CLAUDE.md → ~/.claude/CLAUDE.md   (or merge into your existing one)
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

Skills are specialized capabilities invoked with `/skill-name`. They provide domain knowledge and structured workflows.

### Core Workflow

| Skill | Command | Description |
|-------|---------|-------------|
| **software-engineering** | `/software-engineering` | Self-evolving knowledge base for architecture, debugging, design patterns, testing, performance, and security. Loaded before any code task. |
| **code-reviewer** | `/code-reviewer` | Reviews diffs, PRs, and files for quality, bugs, security issues, and project conventions. |
| **test-engineer** | `/test-engineer` | Generates tests, runs suites, analyzes coverage, and reports results across languages (pytest, vitest, jest, cargo test, etc.). |
| **simplify** | `/simplify` | Analyzes code for unnecessary complexity using 7 refactoring patterns and applies focused fixes. |
| **code-index** | `/code-index` | Generates a structural index of a codebase showing files and their exported symbols. |

### Project & Session Management

| Skill | Command | Description |
|-------|---------|-------------|
| **project-manager** | `/project-manager` | Orchestrates complex projects using limbo for task management and parallel subagent execution. Includes built-in templates (`bug-fix`, `feature`, `swe-full-cycle`) for scaffolding common workflows. |
| **session-handoff** | `/session-handoff` | Preserves strategic context, decisions, and priorities in SESSION_STATE.md for the next session. |
| **project-docs-explore** | `/project-docs-explore` | Discovers and reads a project's documentation structure for quick onboarding. |

### Documentation

| Skill | Command | Description |
|-------|---------|-------------|
| **update-docs** | `/update-docs` | Detects recent code changes and makes targeted updates to affected documentation. |
| **setup-docs** | `/setup-docs` | Creates a progressive disclosure documentation system with dev/ and user/ subdirectories. |

### Skill & Agent Authoring

| Skill | Command | Description |
|-------|---------|-------------|
| **skill-creator** | `/skill-creator` | Creates new skills with proper structure, YAML frontmatter, and best practices. |
| **skill-reflection** | `/skill-reflection` | Analyzes session history to identify skill usage patterns and improvement opportunities. |
| **skill-trainer** | `/skill-trainer` | Validates and hardens skills through automated testing and weak-model calibration. |
| **agent-composer** | `/agent-composer` | Generates agent definition files from role descriptions, capabilities, and existing skills. |
| **team-evaluator** | `/team-evaluator` | Benchmarks the SWE agent team's capabilities, scores results, and identifies gaps. |

### DevOps & Infrastructure

| Skill | Command | Description |
|-------|---------|-------------|
| **devops** | `/devops` | Creates and manages CI/CD pipelines, Docker configs, deployment scripts, Terraform, and infrastructure. |

### Desktop Testing (Loki)

| Skill | Command | Description |
|-------|---------|-------------|
| **loki-test-desktop** | `/loki-test-desktop` | Tests and verifies desktop apps on macOS using loki CLI automation via the Accessibility API. |

### Web Testing (Khora)

| Skill | Command | Description |
|-------|---------|-------------|
| **khora-test-web** | `/khora-test-web` | Tests and verifies web apps using khora CLI automation via Chrome DevTools Protocol. |

### iOS Testing (Qorvex)

| Skill | Command | Description |
|-------|---------|-------------|
| **qorvex-test-ios** | `/qorvex-test-ios` | Tests and verifies iOS apps in simulators or on physical devices using qorvex CLI automation. |
| **qorvex-app-explorer** | `/qorvex-app-explorer` | Systematically explores and maps an iOS app's UI, producing screen hierarchies and automation scripts. |

### Utilities

| Skill | Command | Description |
|-------|---------|-------------|
| **cmux-control** | `/cmux-control` | Controls terminals and browsers via cmux CLI -- spawn shells, run REPLs, automate web pages. |
| **nyx** | `/nyx` | Searches past Claude Code conversation history to recall prior decisions and context. |

## Commands

Commands are lightweight, single-purpose instructions invoked with `/command-name`.

| Command | Description |
|---------|-------------|
| **git-commit** | Stages and commits changes with a clear, concise commit message following conventional style. |

---

## Tool Setup

Several skills depend on external CLI tools. Install them so the skills work out of the box.

### Homebrew (recommended)

All tools are available from the `simonspoon/tap` tap:

```bash
brew tap simonspoon/tap

# Task management (used by project-manager)
brew install simonspoon/tap/limbo

# Conversation search (used by nyx skill)
brew install simonspoon/tap/nyx

# iOS testing (used by qorvex-test-ios, qorvex-app-explorer)
brew install simonspoon/tap/qorvex

# Desktop testing (used by loki-test-desktop)
brew install simonspoon/tap/loki

# Web testing (used by khora-test-web)
brew install simonspoon/tap/khora

# UI design canvas (used by wisp skills)
brew install simonspoon/tap/wisp-cli
```

### From GitHub Releases

Each tool publishes pre-built binaries on its GitHub Releases page:

| Tool | Repository |
|------|------------|
| limbo | [simonspoon/limbo](https://github.com/simonspoon/limbo/releases) |
| nyx | [simonspoon/nyx](https://github.com/simonspoon/nyx/releases) |
| qorvex | [simonspoon/qorvex](https://github.com/simonspoon/qorvex/releases) |
| loki | [simonspoon/loki](https://github.com/simonspoon/loki/releases) |
| khora | [simonspoon/khora](https://github.com/simonspoon/khora/releases) |
| wisp | [simonspoon/wisp](https://github.com/simonspoon/wisp/releases) |

---

## CLAUDE.md

The included `CLAUDE.md` configures Claude Code with a session startup/handoff protocol, mandatory pre-task steps (restate, discover, load knowledge), and automatic routing to the appropriate agent based on task complexity. See the file for full details.
