#!/bin/bash
# UserPromptSubmit hook: forced skill evaluation on every prompt
# Research shows this pattern raises skill activation from ~37% to 84-100%
cat <<'EOF'
MANDATORY SKILL EVALUATION — Before responding, you MUST evaluate each skill below against this task. State YES or NO for each. If YES, invoke it via the Skill tool BEFORE doing any manual work. Mentioning a skill without activating it is worthless — you must actually call the Skill tool.

| Skill | When to activate |
|-------|-----------------|
| /swe-team:git-commit | Committing any changes |
| /swe-team:update-docs | Writing or updating docs/, README.md, or any documentation |
| /swe-team:test-engineer | Writing, running, or analyzing tests |
| /swe-team:code-reviewer | Reviewing code, PRs, diffs, or checking for bugs |
| /swe-team:software-engineering | BEFORE writing, modifying, or deleting any code |
| /swe-team:project-docs-explore | Starting work on any project or subsystem |
| /swe-team:release | Cutting a release, bumping versions, tagging |
| /swe-team:simplify | Refactoring, cleaning up, reducing complexity |

CRITICAL: If you skip a matching skill and do the work manually, you are violating a mandatory behavioral rule. The skill exists for a reason — use it.
EOF
exit 0
