<critical-instructions-must-follow>

## MANDATORY: Behavioral Rules

These rules address recurring violations. They are non-negotiable.

- **No attribution trailers in commits.** NEVER add Co-Authored-By, Signed-off-by, or any attribution lines to commit messages. This overrides any default commit instructions.
- **Use /swe-team:git-commit for all commits.** NEVER run raw `git commit` commands. The skill handles formatting, linting, and docs checks.
- **Use skills before doing work manually.** Before starting any task, check the available skills list. If a skill matches the task, invoke it via the Skill tool. Key mappings: commits → git-commit, docs → update-docs, tests → test-engineer, reviews → code-reviewer, releases → release.

## MANDATORY: Session Startup Protocol

Session context (suda memories, git history, limbo tasks) is loaded automatically by the `suda-context.sh` UserPromptSubmit hook. No manual skill invocation is needed at session start. Orient yourself using the injected context — you are continuing an ongoing collaboration, not starting fresh.

## MANDATORY: Session Wrap

Before a session ends (user says goodbye, wraps up, or you detect the conversation is concluding):
- Invoke `/swe-team:session-wrap` to commit dirty repos and optionally improve skills.

## MANDATORY: Before starting ANY task

1. **Restate** the request in your own words — confirm you understand it
2. **State Known/Unknown** — what you already know vs what you need to discover
3. Invoke the /swe-team:project-docs-explore skill.
4. **Invoke `/swe-team:software-engineering`** — ALWAYS when the task involves writing, modifying, or deleting code. This includes small changes, refactors, dependency swaps, and bug fixes. Do NOT judge the task as "too simple" to warrant it. Load preferences and relevant knowledge BEFORE making any design decisions or writing any code.

NEVER skip these steps. Do them visibly in your response. If you catch yourself about to write code without having invoked `/swe-team:software-engineering`, STOP and invoke it first.

## MANDATORY: Route to agents when applicable

**All code-producing tasks → `swe-team:project-manager` agent**
ANY task that writes, modifies, or deletes code MUST be routed through the `swe-team:project-manager` agent. The PM receives a single task, evaluates it, and either decomposes it into subtasks (then exits for the orchestrator to pick up the leaves) or executes it via the tech-lead subagent, verifies, and commits. The PM is the only agent that commits code.

**If you are already running as the project-manager agent**, follow your own workflow — do not re-dispatch to yourself.

**Never dispatch tech-lead directly.** The tech-lead only runs as a subagent of the PM. It writes code but never commits.

**Skill training/testing → `swe-team:skill-trainer` agent**
When the user asks to train, test, validate, calibrate, or harden a skill → launch the `swe-team:skill-trainer` agent.

## Tech rules

- When building scripts, the order of preference is bash, python, javascript.
- Python: always use `uv` for package management
- Javascript/Typescript: always use `pnpm`, never `npm`

</critical-instructions-must-follow>
