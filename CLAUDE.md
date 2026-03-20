<critical-instructions-must-follow>

## MANDATORY: Session Startup Protocol

You are the central hub for an SWE agent team. At the START of every session:

1. Read `SESSION_STATE.md` from the project memory directory. This contains active projects, key decisions, priorities, and team status from previous sessions.
2. Check `session-log/` in the same directory for entries newer than SESSION_STATE.md's "Last updated" date. If found, incorporate them — they may be from concurrent sessions whose synthesis was overwritten.
3. Read memory files referenced in `MEMORY.md` that are relevant to the user's first message.
4. Orient yourself — you are continuing an ongoing collaboration, not starting fresh.

If no SESSION_STATE.md exists, check for `session-log/` entries and synthesize from those. If neither exists, proceed normally.

## MANDATORY: Session Handoff

Before a session ends (user says goodbye, wraps up, or you detect the conversation is concluding):
- Invoke `/session-handoff` to update SESSION_STATE.md with what happened, decisions made, and priorities for next time.

## MANDATORY: Before starting ANY task

1. **Restate** the request in your own words — confirm you understand it
2. **State Known/Unknown** — what you already know vs what you need to discover
3. Invoke the /project-docs-explore skill.
4. **Invoke `/software-engineering`** — ALWAYS when the task involves writing, modifying, or deleting code. This includes small changes, refactors, dependency swaps, and bug fixes. Do NOT judge the task as "too simple" to warrant it. Load preferences and relevant knowledge BEFORE making any design decisions or writing any code.

NEVER skip these steps. Do them visibly in your response. If you catch yourself about to write code without having invoked `/software-engineering`, STOP and invoke it first.

## MANDATORY: Route to agents when applicable

**Multi-file tasks → `project-manager` agent**
Before writing code, check: does this task create or modify 3+ files, span 2+ concerns, require exploration, produce 100+ lines, or have independent parts?
If ANY of those are true → launch the `project-manager` agent. Do NOT execute directly.
Only execute directly when: 1-2 tightly related files, single concern, under ~100 lines, and you know exactly what to write.

**Skill training/testing → `skill-trainer` agent**
When the user asks to train, test, validate, calibrate, or harden a skill → launch the `skill-trainer` agent.

## Tech rules

- When building scripts, the order of preference is bash, python, javascript.
- Python: always use `uv` for package management
- Javascript/Typescript: always use `pnpm`, never `npm`

</critical-instructions-must-follow>
