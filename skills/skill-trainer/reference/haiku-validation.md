# Phase 3: Haiku Validation

## Goal

Verify that a weaker model (Haiku) can follow the skill's instructions to complete real tasks without errors. This is the ultimate test — if Haiku can do it, the docs are clear enough.

## Prerequisites

- cmux must be running (`cmux ping` → `PONG`)
- The `/swe-team:cmux-control` skill must be available
- The target skill must be installed in `~/.claude/skills/`

## Reducing Approval Friction

Both YOU (the trainer monitoring Haiku) and HAIKU (running inside cmux) will hit permission prompts. To minimize friction:

- When approving Haiku's commands via cmux, always use option "2" (don't ask again) for tool-specific commands
- Advise the user before starting: "Phase 3 involves many cmux commands. Consider pre-approving `cmux` commands in your settings."
- Your own cmux commands (send, read-screen, etc.) should ideally be pre-approved from Phase 2 or earlier in the session

## Step-by-Step

### 1. Select Test Tasks

Choose 3-5 tasks from your Phase 2 test scenarios. Prioritize:
- **Core operations** — the skill's most important use cases
- **Multi-step workflows** — tests that require chaining steps correctly
- **Tasks that broke during Phase 2** — verify your fixes work for weaker models

Each task should be expressible as a single natural-language prompt.

**Good task prompts:**
- Specific: "Create a workspace at /tmp, run `echo TEST`, read the output"
- Self-contained: doesn't require prior context
- Verifiable: has a clear success/failure signal
- Scoped: completable in under 2 minutes

**Bad task prompts:**
- Vague: "Try out the skill"
- Multi-part without structure: "Do a bunch of things and tell me what happens"
- Requires external state: "Check the database for user 123"

### 2. Launch Haiku via cmux

```bash
# Create a workspace for the test
cmux new-workspace --cwd /path/to/relevant/directory
# Returns: OK workspace:N

# Wait for shell to initialize
sleep 3

# Start Claude with Haiku model
cmux send --workspace workspace:N "claude --model haiku"
cmux send-key --workspace workspace:N Enter

# Wait for Claude to initialize (Haiku is fast, but give it time)
sleep 8

# Verify it's ready by reading the screen
cmux read-screen --workspace workspace:N --lines 10
# Should show the Claude Code welcome screen with "Haiku" in the model info
```

### 3. Send a Task

Craft the prompt to be explicit about using the skill:

```bash
cmux send --workspace workspace:N 'Use the /[skill-name] skill to [specific task]. Report your results when done.'
cmux send-key --workspace workspace:N Enter
```

**Prompt design tips:**
- Start with "Use the /[skill-name] skill" so Haiku loads it
- Be specific about what to do, but don't tell it HOW — let the skill guide it
- Ask it to "report results" so you can verify success
- One task at a time is cleaner than batching

### 4. Monitor Execution

Haiku will need permission approvals. Monitor and approve them:

```bash
# Check progress periodically
cmux read-screen --workspace workspace:N --scrollback --lines 50

# When you see a permission prompt, approve it:
# Option "1" = approve once
# Option "2" = approve and don't ask again for this command pattern
cmux send --workspace workspace:N "2"
# (Use "2" to avoid re-approving the same command type repeatedly)
```

**Timing guidance:**
- Check every 8-15 seconds during active execution
- Haiku thinks fast but cmux commands take time
- A 3-step task typically takes 30-60 seconds including approvals

### 5. Capture and Analyze the Transcript

After Haiku completes the task:

```bash
# Read the full transcript
cmux read-screen --workspace workspace:N --scrollback --lines 200
```

Analyze the transcript for:

**Correct patterns (skill docs worked):**
- Did Haiku load the skill first?
- Did it follow the documented command syntax?
- Did it use the right flags (e.g., `--workspace` not `--surface`)?
- Did it follow multi-step patterns correctly (e.g., send + Enter)?
- Did it handle output correctly (parsing refs, etc.)?
- Did it clean up?

**Incorrect patterns (skill docs failed):**
- Did Haiku use a wrong command or flag?
- Did it skip a step the docs say is required?
- Did it get stuck and not know how to recover?
- Did it use the old/wrong approach instead of the documented best practice?
- Did it hallucinate a command that doesn't exist?

### 6. Score Each Task

| Result | Meaning |
|---|---|
| **PASS** | Haiku completed the task correctly by following skill docs |
| **PASS (slow)** | Completed correctly but took unnecessary extra steps |
| **PARTIAL** | Some steps worked, others failed. Haiku recovered or got partial results |
| **FAIL (doc)** | Failed because skill docs were unclear or wrong |
| **FAIL (model)** | Failed because Haiku misunderstood clear instructions (not a doc issue) |

**FAIL (doc)** → fix the docs
**FAIL (model)** → make the docs even MORE explicit (shorter sentences, more examples, clearer decision points)

### 7. Apply Final Fixes

For any FAIL or PARTIAL results:
1. Identify what the docs should have said differently
2. Apply the fix
3. Do NOT re-run Haiku unless you made major changes to the skill's core instructions

One Haiku run is usually enough. The goal is validation, not perfection.

### 8. Clean Up

```bash
# Exit Haiku's Claude session
cmux send --workspace workspace:N "/exit"
cmux send-key --workspace workspace:N Enter
sleep 3

# Close the test workspace
cmux close-workspace --workspace workspace:N
```

Verify nothing is left behind:
```bash
cmux tree --all
# Should not show any test workspaces
```

## Multi-Task Testing

If you have 3-5 tasks, you can either:

**Sequential (recommended):** Send one task, wait for completion, analyze, then send the next. Cleaner transcripts, easier to analyze.

**Batched:** Send all tasks in one prompt ("Do these 3 things in order: (1)... (2)... (3)..."). Faster but harder to analyze if something fails mid-way.

For the first Haiku validation of a skill, use sequential. For re-validation after fixes, batched is fine.

## What Success Looks Like

A skill passes Haiku validation when:
- Haiku loads the skill and follows its patterns (not its own instincts)
- Haiku uses the correct command syntax on the first try
- Haiku follows multi-step patterns in the right order
- Haiku handles the output correctly (saves refs, reads results)
- Haiku cleans up when done
- No errors that required improvisation outside the skill's guidance

If all 3-5 tasks pass, the skill is **READY**.
If 1-2 tasks have minor issues, the skill **NEEDS MINOR FIXES**.
If multiple tasks fail, the skill **NEEDS WORK** — go back to Phase 2.
