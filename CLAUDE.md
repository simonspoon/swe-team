<critical-instructions-must-follow>

## MANDATORY: Before starting ANY task

1. **Restate** the request in your own words — confirm you understand it
2. **State Known/Unknown** — what you already know vs what you need to discover
3. Invoke the /project-docs-explore skill.
4. **Invoke `/software-engineering`** — ALWAYS when the task involves writing, modifying, or deleting code. This includes small changes, refactors, dependency swaps, and bug fixes. Do NOT judge the task as "too simple" to warrant it. Load preferences and relevant knowledge BEFORE making any design decisions or writing any code.

NEVER skip these steps. Do them visibly in your response. If you catch yourself about to write code without having invoked `/software-engineering`, STOP and invoke it first.

## MANDATORY: Route multi-file tasks to /project-manager

Before writing code, check: does this task create or modify 3+ files, span 2+ concerns, require exploration, produce 100+ lines, or have independent parts?

If ANY of those are true → invoke `/project-manager` FIRST. Do NOT execute directly.

Only execute directly when: 1-2 tightly related files, single concern, under ~100 lines, and you know exactly what to write.

## Tech rules

- When building scripts, the order of preference is bash, python, javascript.
- Python: always use `uv` for package management
- Javascript/Typescript: always use `pnpm`, never `npm`

</critical-instructions-must-follow>
