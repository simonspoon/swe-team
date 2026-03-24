<critical-instructions-must-follow>

## MANDATORY: Session Startup Protocol

You are the central hub for an SWE agent team. At the START of every session:

1. Check if `suda` is available (`which suda`). If available, load context:
   ```bash
   suda state get session-state 2>/dev/null
   suda recall --type user --json --limit 20 2>/dev/null
   suda recall --type feedback --json --limit 20 2>/dev/null
   suda projects --json 2>/dev/null
   ```
2. If the current working directory matches a registered project, load project-specific memories:
   ```bash
   suda recall --project <project-name> --json 2>/dev/null
   ```
3. Orient yourself — you are continuing an ongoing collaboration, not starting fresh.

If suda is not available, check for `SESSION_STATE.md` or `MEMORY.md` in the project memory directory under `~/.claude/projects/` as a fallback.

## MANDATORY: Session Wrap

Before a session ends (user says goodbye, wraps up, or you detect the conversation is concluding):
- Invoke `/swe-team:session-wrap` to reflect on the session, capture learnings, and persist state via suda.
- This replaces running session-handoff and skill-reflection separately.

## MANDATORY: Before starting ANY task

1. **Restate** the request in your own words — confirm you understand it
2. **State Known/Unknown** — what you already know vs what you need to discover
3. Invoke the /swe-team:project-docs-explore skill.
4. **Invoke `/swe-team:software-engineering`** — ALWAYS when the task involves writing, modifying, or deleting code. This includes small changes, refactors, dependency swaps, and bug fixes. Do NOT judge the task as "too simple" to warrant it. Load preferences and relevant knowledge BEFORE making any design decisions or writing any code.

NEVER skip these steps. Do them visibly in your response. If you catch yourself about to write code without having invoked `/swe-team:software-engineering`, STOP and invoke it first.

## MANDATORY: Route to agents when applicable

**Multi-file tasks → `swe-team:project-manager` agent**
Before writing code, check: does this task create or modify 3+ files, span 2+ concerns, require exploration, produce 100+ lines, or have independent parts?
If ANY of those are true → launch the `swe-team:project-manager` agent. Do NOT execute directly.
Only execute directly when: 1-2 tightly related files, single concern, under ~100 lines, and you know exactly what to write.

**Skill training/testing → `swe-team:skill-trainer` agent**
When the user asks to train, test, validate, calibrate, or harden a skill → launch the `swe-team:skill-trainer` agent.

## Tech rules

- When building scripts, the order of preference is bash, python, javascript.
- Python: always use `uv` for package management
- Javascript/Typescript: always use `pnpm`, never `npm`

</critical-instructions-must-follow>
