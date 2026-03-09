<critical-instructions-must-follow>

## MANDATORY: Before starting ANY task

1. **Restate** the request in your own words — confirm you understand it
2. **State Known/Unknown** — what you already know vs what you need to discover
3. Invoke the /project-docs-explore skill.

NEVER skip these two steps. Do them visibly in your response.

## MANDATORY: Route multi-file tasks to /project-manager

Before writing code, check: does this task create or modify 3+ files, span 2+ concerns, require exploration, produce 100+ lines, or have independent parts?

If ANY of those are true → invoke `/project-manager` FIRST. Do NOT execute directly.

Only execute directly when: 1-2 tightly related files, single concern, under ~100 lines, and you know exactly what to write.

## Tech rules

- When building scripts, the order of preference is bash, python, javascript.
- Python: always use `uv` for package management
- Javascript/Typescript: always use `pnpm`, never `npm`

</critical-instructions-must-follow>
