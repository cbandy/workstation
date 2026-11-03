---
name: slack-formatted-send
description: >-
  Send agent-authored Slack messages with rendered tables, headers, and syntax-highlighted code.
  Use when the user asks to send, post, share, or draft a Slack message with nice formatting, tables, or highlighted code,
  or when turning a chat writeup into a Slack message.
  Do not use for Slack canvases or editing already-sent messages.

compatibility: Requires Slack MCP server with slack_send_message or slack_send_message_draft tools.
allowed-tools: slack_send_message slack_send_message_draft slack_search_channels slack_search_users
disable-model-invocation: false

metadata:
  category: communication
  tags: slack, messaging, markdown, tables

# https://docs.slack.dev/ai/slack-mcp-server
# https://docs.slack.dev/reference/block-kit
---

# Slack Formatted Send

Render structured data (such as comparisons, status lists, metrics, and multi-attribute summaries) as Markdown pipe tables.
Keep narrative and explanations in paragraphs outside the table.

## Safety and Targets

- **preview first**: Show the formatted message in chat before sending.
- **explicit confirmation**: Send only when they explicitly ask to send.
- **target & mention IDs**: Tools and mentions require IDs (`C…` for channels, `U…` for users), not names like `#general` or `@alice`.
  If given names, resolve them via `slack_search_channels` and `slack_search_users` (or extract them from recent thread history).
- **threads**: If replying in a thread, pass `thread_ts`.

## Which Tool

Read the Slack tool schema before calling it.

| Intent | Tool | Notes |
|--------|------|-------|
| They will edit the wording before it goes out, and a table is unnecessary | `slack_send_message_draft` | Pipe tables stay plain text in composer drafts. |
| The message should show rendered tables or headers | `slack_send_message` | Renders standard Markdown into Block Kit. |

`slack_send_message` accepts standard Markdown, including pipe tables, headers, and fenced code, and posts it as Block Kit.
Do not build raw Block Kit JSON. The send tool has no field for a `data_table` block.

## How to Write the Message

- **pipe tables**: Use a Markdown pipe table for anything that was a table in chat.
  Do not escape the `|` characters that form the table. Escape a literal pipe inside a cell as `\|`.
  Leave one blank line before and after each table.
- **table limits**: Static rendered tables support at most 100 rows, 20 columns, and 10,000 total characters across cells. Split a larger table.
- **code fences**: Fence code with a language tag (e.g., `json`, `python`, `yaml`). These are highlighted and get a copy button. A fence with no language stays plain monospace.
- **headings & prose**: Lead sections with a short bold label or Markdown heading (`#`, `##`). Keep the argument in paragraphs. Do not put every sentence in a table.
- **links**: `slack_send_message` accepts standard Markdown links `[text](url)`. When writing drafts (`slack_send_message_draft`), use Slack mrkdwn `<url|text>` instead.
- **images**: Markdown images (`![alt](url)`) do not render as inline images in the Markdown block; they degrade to plain text links.
- **mentions**: Both users and channels require IDs: `<@U12345678>` and `<#C12345678>`. Never use names like `<@alice>` or `<#general>`. Broadcasts use `<!here>` or `<!channel>`.
- **message length**: Stay under 5,000 characters per section. The cumulative payload limit across markdown blocks is 12,000 characters. Split longer notes into multiple messages.

## Table Block and Data Table

A Markdown pipe table automatically becomes a static `table` block.
Interactive `data_table` blocks (with pagination, sorting, or buttons) require raw Block Kit JSON and are not supported by this tool.
Stick to Markdown pipe tables.

## Example

~~~~markdown
## Weekly Infrastructure Review

The latency regression from Wednesday has stabilized. Key service metrics:

| Service | P50 (ms) | P99 (ms) | Status |
|---------|----------|----------|--------|
| Auth    | 12       | 45       | Normal |
| Billing | 85       | 310      | Investigating: <@U012345678> in <#C098765432> |

Updated config in [`billing-service`](https://example.com/org/billing):

```yaml
timeout_ms: 500
retry_budget: 3
```
~~~~

## After it is Sent

A rendered table cannot be edited in the Slack UI. **Edit message** rewrites the text fallback and drops the blocks.
Nothing in this tool updates a sent message. A correction is a new message.
Warn the user once before the first send: *"Rendered Slack tables cannot be edited in-place; corrections will require posting a new message."*
