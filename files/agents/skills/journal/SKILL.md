---
name: journal
description: Create a structured journal entry from the current session
disable-model-invocation: true

# Episodic Memory

# https://github.com/rlancemartin/claude-diary
---

# Create Journal Entry

Capture a structured journal entry documenting the current session.
This entry is raw material for `/reflect` to mine later for cross-session patterns.
It is not analyzed or routed here.

## Approach

Reflect on the conversation history loaded in this session. You have access to:

- User messages and requests
- Your responses and tool invocations
- Files you read, edited, or wrote
- Errors encountered and solutions applied
- Design decisions discussed
- User preferences expressed

## Runtime Paths

- journal output: `.agents/memory/journal/YYYY-MM-DD-session-N.md`
- memory that may already exist: `.agents/MEMORY.md`

## Session Number Source of Truth

- Preferred source of truth: `.agents/MEMORY.md`
- Fallback: scan matching journal files for the same date only when `MEMORY.md` is missing or uninitialized.
- Include a `Session ID` line only when a runtime session identifier is actually available.

## Steps

### 1. Create journal entry from context

Review the current conversation and create the journal entry from what happened.
No tool invocations are needed for typical sessions.

Use this exact template:

```markdown
# Session Journal Entry

**Date**: YYYY-MM-DD
**Time**: HH:MM:SS
**Session**: N
**Session ID**: {optional; when available}

## Task Summary
{2-3 sentences: What was the user trying to accomplish based on the user messages?}

## Time
- Session timing:
- Sequence or milestones:

## Work Summary
- …

## Design Decisions Made
- …

## Actions Taken
- Files created: …
- Files edited: …
- Commands executed: …
- Verification performed: …

## Challenges Encountered
- …

## Solutions Applied
- …

## User Preferences Observed

### Communication & Workflow
- …

### Code Quality Preferences
- …

### Technical Preferences
- …

## Code Patterns and Decisions
- …

## Context and Technologies
- …

## Notes
- {any other observations}
```

### 2. Save the journal entry

Write the journal entry to:

- `.agents/memory/journal/YYYY-MM-DD-session-N.md`

### 3. Confirm completion

Display:

- The path where the journal entry was saved
- A brief one-line summary of what was captured

## Data Security

Apply the same PII rules as the project's instruction files.
Do not include raw financial amounts, IBANs, merchant names, or personal identifiers in journal entries.
Use redacted or generic descriptions instead.

## Guidelines

- Be factual and specific — include concrete details when available
- Capture the "why" behind decisions, not just the "what"
- Document user preferences observed, especially around workflow and style
- Include failures — what did not work is valuable learning material
- Keep it structured — follow the template consistently
- If context is incomplete, say so instead of inventing details

## Error Handling

- If context seems incomplete, mention what is missing
- If uncertain about details, document the uncertainty instead of fabricating precision
- If no session identifier is available, omit `Session ID`
