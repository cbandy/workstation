---
name: reflect
description: Analyze journal entries to identify cross-session patterns and propose durable updates to AGENTS.md and canonical instructions
disable-model-invocation: true

# Semantic Memory

# https://github.com/rlancemartin/claude-diary
---

# Reflect on Journal Entries and Synthesize Insights

Analyze accumulated journal entries to identify recurring patterns across sessions,
then route durable learning to the canonical instruction source.

## Parameters

The user can provide:

- **Date Range**: "from YYYY-MM-DD to YYYY-MM-DD" or "last N days"
- **Entry Count**: "last N entries" (for example, "last 10 entries")
- **Pattern Filter**: "related to {keyword}"

Default: analyze **all unprocessed journal entries**.

## Runtime Paths

- journal input: `.agents/memory/journal/`
- reflections: `.agents/memory/reflections/`
- processed index: `.agents/memory/reflections/processed.log`
- memory: `.agents/MEMORY.md`
- operating guidance source: `AGENTS.md`

## Processing Workflow

1. Resolve the filter set from user parameters.
2. Load matching journal entries from `./.agents/memory/journal/`.
3. Skip entries already listed in `processed.log` unless the user explicitly requests reprocessing.
4. Read supporting context relevant to the filtered corpus:
   - Recent reflections
   - `.agents/memory/reflections/processed.log`
   - `.agents/MEMORY.md`
   - `AGENTS.md` when operating-guidance candidates are being considered
5. Group repeated patterns, explicit rule violations, contradictions, and one-off observations.
6. Carry forward recent one-off observations from prior reflections when the same signal reappears.
7. Prioritize repeated violation of existing guidance over inventing a new rule.
8. Route each repeated learning by scope and destination, strengthening weak existing guidance before proposing a brand-new durable rule.
9. Write the reflection file to `.agents/memory/reflections/YYYY-MM-DD-reflection-N.md`.
10. Present proposed durable edits with destination, evidence, and confidence.
11. If the user approves any durable edits, apply them in the same flow.
12. Update `processed.log` only after the user accepts the reflection pass as complete and any approved durable edits for that pass were applied.

## Carry-Forward Rule

- Read recent `One-Off Observations` before scoring new patterns.
- If a current signal matches a recent one-off observation, count that prior occurrence toward the current confidence threshold.
- Use carry-forward only for clearly similar signals.
- Note the carry-forward when it materially affects confidence.

## Rule Violation Priority

- Check whether journal entries show the agent violating an existing rule.
- Repeated violation of an existing rule is higher priority than inventing a new rule.
- If patterns are contradictory, surface the contradiction instead of forcing a confident promotion.

## Confidence Rules

- 1 occurrence: keep as a one-off observation only
- 2 or more occurrences: candidate
- Repeated violation of an existing rule raises promotion priority

## Signal vs Noise

Treat a pattern as signal when it has durable evidence and future decision value.

Repeated signal examples:

- The same operating-rule lesson appears in two journal entries
- The same workflow violation appears across multiple sessions
- A technology-specific workflow repeats and reads like reusable guidance

Treat a pattern as noise when it is isolated, temporary, or not durable enough to promote.

Noise examples:

- A one-off workaround tied to a single broken tool invocation
- An abandoned idea that appears once and never returns
- A transient preference that does not materially affect future execution

## Approval Model

No durable edit is automatic until the user approves it.

- auto-write:
  - reflection Markdown file
- require approval:
  - `AGENTS.md` edits
  - new skill or hook creation
- Update `processed.log` only after the user accepts the reflection pass as complete and approved actions are resolved.

Every proposed promotion must include:

- The proposed learning
- Supporting evidence
- Confidence
- Proposed destination

## `processed.log` Semantics

- Store processed journal entry identifiers in `.agents/memory/reflections/processed.log`
- Canonical line format: `<journal-filename> | <processed-date> | <reflection-filename> | accepted`
- Reflection acceptance is required before advancing `processed.log`
- Approved durable edits must be applied in the same flow before advancing `processed.log`
- Declining all durable edits does not block `processed.log` advancement if the user still accepts the reflection as complete
- `include all entries` analyzes both processed and unprocessed entries for the selected scope without deleting prior reflections
- Targeted `reprocess` analyzes a named entry or filtered subset again when the user explicitly asks

## Exact Template

```markdown
# Reflection: <scope>

**Generated**: YYYY-MM-DD HH:MM
**Entries Analyzed**: N
**Date Range**: …

## Summary
{2-3 paragraph overview of key insights discovered across these entries}

## Rule Violations Detected
{Omit this section if none.}

1. **Rule**: …
   - **Frequency**: …
   - **Violation pattern**: …
   - **Root Cause**: …
   - **Impact**: …
   - **Strengthening action**: …

## Patterns Identified

### Persistent Preferences
1. …

### Design Decisions That Worked
1. …

### Anti-Patterns To Avoid
1. …

## Efficiency Lessons
1. …

## Notable Mistakes and Learnings
1. …

## One-Off Observations
1. …

## Proposed Promotions

### `AGENTS.md` candidates
- …

### Skill / Hook candidates
- …

## Metadata
- Journal entries analyzed: …
- Prior one-offs carried forward: …
- Reprocessing requested: …
- Processed log status: …
- Processed log entries to append: …
```

## Completion Summary

At the end, report:

- Rule violations detected and strengthened
- Reflection filename and location
- Pattern count
- Whether `AGENTS.md` edits were proposed or applied
- `processed.log` confirmation

## Error Handling

- No journal entries -> suggest running `/journal` first
- All entries processed -> inform the user and suggest `include all entries`
- Filter matches nothing -> show options (remove filter, include processed, try different filter)
- Fewer than 3 entries -> proceed but note low pattern confidence
- Malformed entries -> skip and document which had issues
- `AGENTS.md` read/write failure -> report error but continue with reflection
