
AI development environments have shifted away from a single, messy monolithic file in favor of highly organized, localized structures.
The focus has turned to isolating human-readable engineering guidelines from rigid machine permissions.
Some cross-tool standardizations are beginning to emerge.

- https://agentclientprotocol.com
- https://agentskills.io
- https://dotagentsprotocol.com
- https://modelcontextprotocol.io


# Project Root (main)

| Files             | Tools |
|-------------------|-------|
| `AGENTS.md`       | **Antigravity** (Google)<br>**Codex** (OpenAI)<br>**Jules** (Google)<br>**Kiro** (AWS)<br>**Open Interpreter**
| `CLAUDE.md`       | **Claude Code** (Anthropic)
| `.windsurfrules`  | **Windsurf** (Codeium)
|      *None*       | **Gemini** (Code Assist)

## `AGENTS.md`

Loaded automatically when a session starts.

- High-Level Architecture Overview; the big picture; how the system is structured, what services exits, how they communicate
- Build Steps; how to install, run, test, and deploy the project
- Coding Conventions; style rules that always apply; naming patterns, file organization, commit message format; "What should the code look like when you write it?"
- Integration Points; external APIs, third-party services, key environment variables and what they control
- Behavior Guidance; what the agent should and shouldn't do autonomously


# Project Root (modular)

| Files             | Formats | Tools |
|-------------------|---------|-------|
| `.agents/rules`<br>`.agents/skills`              | Markdown                        | **Antigravity** (Google)
| `.claude/settings.json`<br>`.claude/skills`      | Markdown, JSON for config       | **Claude Code** (Anthropic)
| `.codex/rules`                                   | Starlark to restrict commands   | **Codex** (OpenAI)
| `.cursor/rules`                                  | Markdown with YAML frontmatter  | **Cursor**
| `.gemini/config.yaml`<br>`.gemini/styleguide.md` | Markdown, YAML for config       | **Gemini** (Code Assist)
| `.kiro/steering`<br>`.kiro/prompts`              | Markdown with YAML frontmatter  | **Kiro** (AWS)
| `.windsurf/rules`                                | Markdown with `<XML>` groupings | **Windsurf** (Codeium)

## `.agents/MEMORY.md`

Usually automated; a persistent log of decisions, corrections, and project evolution.
Include guidance in `AGENTS.md` for how to use:

```markdown
## Long-Term Memory
- Project memory, past decisions, and environment quirks are stored in `.agents/MEMORY.md`.
- Read `.agents/MEMORY.md` when starting tasks to understand prior decisions.
- When explicitly instructed to "remember" or "note" something, append or update `.agents/MEMORY.md`.
- Keep memory entries concise, timestamped, and categorized (e.g., Decisions, Quirks, Current State).
```

## `.agents/CONTEXT.md`

Not automated; overall project structure, business rules, life cycles.
Include guidance in `AGENTS.md` for this to be recognized:

```markdown
## Architectural Context & Domain Reference
System architecture, module boundaries, and domain models are documented in `.agents/CONTEXT.md`.
- **When**: Consult `.agents/CONTEXT.md` before:
  - Creating new files or modules.
  - Designing API contracts or database schema changes.
  - Making changes that touch cross-module boundaries or state flows.
- **Why**: Ensure all new implementations adhere to established domain models, naming conventions, and layer boundaries.
```

Humans also benefit from this information; consider keeping it in `docs/architecture.md` (or `docs/domain-model.md` or `docs/concepts.md`) instead.
If you want both, tailor `CONTEXT.md` for agents and keep both accurate!

## `.agents/skills/*/SKILL.md`

Specific instructions for a particular (type of) task.
Loaded dynamically, either by keyword or slash-command.

## What to Commit

```gitignore
# Exclude the content of `.agents` except for specifically curated files.
.agents/*
!.agents/rules/
!.agents/skills/
```
