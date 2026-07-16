
AI development environments have shifted away from a single, messy monolithic file in favor of highly organized, localized structures.
The focus has turned to isolating human-readable engineering guidelines from rigid machine permissions.
Some cross-tool standardizations are beginning to emerge.

# Project Root (main)

| Files             | Tools |
|-------------------|-------|
| `AGENTS.md`       | **Antigravity** (Google)<br>**Codex** (OpenAI)<br>**Jules** (Google)<br>**Kiro** (AWS)
| `CLAUDE.md`       | **Claude Code** (Anthropic)
| `.windsurfrules`  | **Windsurf** (Codeium)
|      *None*       | **Gemini** (Code Assist)

# Project Root (modular)

| Files             | Formats | Tools |
|-------------------|---------|-------|
| `.agents/rules`<br>`.agents/workflows`<br>`.agents/skils` | Markdown               | **Antigravity** (Google)
| `.claude/settings.json`<br>`.claude/skills`      | Markdown, JSON for config       | **Claude Code** (Anthropic)
| `.codex/rules`                                   | Starlark to restrict commands   | **Codex** (OpenAI)
| `.cursor/rules`                                  | Markdown with YAML frontmatter  | **Cursor**
| `.gemini/config.yaml`<br>`.gemini/styleguide.md` | Markdown, YAML for config       | **Gemini** (Code Assist)
| `.kiro/steering`<br>`.kiro/prompts`              | Markdown with YAML frontmatter  | **Kiro** (AWS)
| `.windsurf/rules`                                | Markdown with `<XML>` groupings | **Windsurf** (Codeium)
