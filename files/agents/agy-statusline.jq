#!/usr/bin/env -S jq --raw-output --from-file
#
# https://antigravity.google/docs/cli/statusline

def duration($limit; $separator; $default):
  if type != "number"
  then $default
  else
    . as $value
    | [[31536000, "y"], [86400, "d"], [3600, "h"], [60, "m"], [1, "s"]]
    | [label $out | foreach .[] as $item (
        [$value, 1];
        if $limit > 0 and .[1] > $limit
        then break $out
        elif .[0] >= $item[0]
        then [.[0] % $item[0], .[1] + 1] + [(.[0] / $item[0] | floor | tostring) + $item[1]]
        else .[0:2]
        end;
        if length > 2
        then .[2]
        else empty
        end)
      ]
    | if length > 0 then join($separator) else "0s" end
  end;
def duration($limit; $separator): duration($limit; $separator; "-");
def duration($limit): duration($limit; " "; "-");
def duration: duration(0; " "; "-");

select(.model? and .quota?) |
{
 reset: "\u001b[0m", bold: "\u001b[1m", dim: "\u001b[2m", italic: "\u001b[3m",
 black:   "\u001b[30m", gray:           "\u001b[90m",
 red:     "\u001b[31m", bright_red:     "\u001b[91m",
 green:   "\u001b[32m", bright_green:   "\u001b[92m",
 yellow:  "\u001b[33m", bright_yellow:  "\u001b[93m",
 blue:    "\u001b[34m", bright_blue:    "\u001b[94m",
 magenta: "\u001b[35m", bright_magenta: "\u001b[95m",
 cyan:    "\u001b[36m", bright_cyan:    "\u001b[96m",
 white:   "\u001b[37m", bright_white:   "\u001b[97m",
} as $ANSI |
{ "low": $ANSI.green, "medium": $ANSI.yellow, "high": $ANSI.bright_red } as $EFFORT_COLORS |
{ "accept-edits": $ANSI.bright_green, "plan": $ANSI.bright_blue } as $MODE_COLORS |
{
 "idle":     [$ANSI.bright_green,   "● READY" ],
 "thinking": [$ANSI.bright_yellow,  "THINKING"],
 "working":  [$ANSI.bright_cyan,    "WORKING" ],
 "tool_use": [$ANSI.bright_magenta, "🔧 TOOL" ],
} as $STATES |
"·░▒▓█" as $PROGRESS |
"\($ANSI.gray) │ \($ANSI.reset)" as $BAR |
"\($ANSI.gray) · \($ANSI.reset)" as $DOT |
"\($ANSI.gray) ╱ \($ANSI.reset)" as $SLASH |

((.workspace.project_dir // "") | if startswith(env.HOME) then "~" + ltrimstr(env.HOME) else . end) as $project |
($STATES[.agent_state][0]? // $ANSI.white) as $agent_state_color | ($STATES[.agent_state][1]? // "⏳ \(.agent_state)") as $agent_state |
($MODE_COLORS[.cycle_mode]? // $ANSI.white) as $cycle_mode_color | (.cycle_mode? // null) as $cycle_mode |
($EFFORT_COLORS[.model.effort]? // null) as $model_effort_color |
((.context_window.remaining_percentage // 0) | floor / 100) as $context_remaining |
(.subagents? | if type == "array" then length else 0 end) as $agent_count |
(.model.display_name // "") as $model_name |
(.model.effort? // null) as $model_effort |
(.terminal_width // 80) as $terminal_width |
(.task_count // 0) as $task_count |
(
 if (.model.id // "") | startswith("Gemini") then
 {
  daily: (.quota["gemini-5h"].remaining_fraction),
  weekly: (.quota["gemini-weekly"].remaining_fraction),
  timeout: (.quota | [to_entries[] | select(.key | startswith("gemini-")) | .value.reset_in_seconds] | min),
 }
 else
 {
  daily: (.quota["3p-5h"].remaining_fraction),
  weekly: (.quota["3p-weekly"].remaining_fraction),
  timeout: (.quota | [to_entries[] | select(.key | startswith("3p-")) | .value.reset_in_seconds] | min),
 }
 end
) as $quota |
(
 " " +
 "\($ANSI.dim + $project + $ANSI.reset)" + $BAR +
 "\($ANSI.bright_magenta + $ANSI.italic + $model_name + $ANSI.reset)" +
 if $model_effort and ($model_name | test($model_effort; "i") | not) then "\($DOT + $model_effort_color + $model_effort + $ANSI.reset)" else null end + $BAR +
 "\($agent_state_color + $ANSI.bold + $agent_state + $ANSI.reset)" + $BAR +
 "\($ANSI.dim + "C:" + $ANSI.reset) \($context_remaining * 100 | floor)%" + $BAR +
 "\($ANSI.dim + "Q:" + $ANSI.reset) \($quota.daily * 100 | floor)%" + $DOT + "\($quota.weekly * 100 | floor)%" + $DOT + "\($quota.timeout | duration(1))" +
 if $cycle_mode then "\($BAR + $cycle_mode_color + $cycle_mode + $ANSI.reset)" else null end
)
